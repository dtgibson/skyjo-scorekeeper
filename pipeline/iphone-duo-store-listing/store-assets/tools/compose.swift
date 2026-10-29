// compose.swift: builds the App Store screenshots and the product page header
// for Scorekeeper for Skyjo 1.7.1 from raw simulator captures and Apple's bezels.
//
// Geometry, colours and captions follow pipeline/iphone-duo-store-listing/
// design-refinement.md and the approved mockup (design.html). Where the two
// differ, the mockup's rendered values are used (no screen shadow in framed
// mode, the header's radial glow, the header headline wrapping inside its 28%
// text block).
//
// Build and run (see README.md):
//   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
//     xcrun swiftc -O compose.swift -o /tmp/skyjo-compose
//   /tmp/skyjo-compose <captures-dir> <bezel-dir> <out-dir>

import AppKit
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let srgb = CGColorSpace(name: CGColorSpace.sRGB)!

func fail(_ message: String) -> Never {
    FileHandle.standardError.write((message + "\n").data(using: .utf8)!)
    exit(1)
}

func color(_ hex: String, _ alpha: CGFloat = 1) -> CGColor {
    var value: UInt64 = 0
    Scanner(string: String(hex.dropFirst())).scanHexInt64(&value)
    let r = CGFloat((value >> 16) & 0xFF) / 255, g = CGFloat((value >> 8) & 0xFF) / 255, b = CGFloat(value & 0xFF) / 255
    return CGColor(colorSpace: srgb, components: [r, g, b, alpha])!
}

func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> CGColor {
    CGColor(colorSpace: srgb, components: [r / 255, g / 255, b / 255, a])!
}

func loadImage(_ path: String) -> CGImage {
    guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
          let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { fail("cannot read \(path)") }
    return img
}

func writePNG(_ img: CGImage, _ path: String) {
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    guard let dst = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { fail("cannot write \(path)") }
    CGImageDestinationAddImage(dst, img, nil)
    guard CGImageDestinationFinalize(dst) else { fail("cannot finalize \(path)") }
}

// MARK: - Canvas (top-left coordinates, opaque sRGB)

final class Canvas {
    let ctx: CGContext
    let width: CGFloat, height: CGFloat

    init(_ w: Int, _ h: Int) {
        guard let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: srgb,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { fail("no context") }
        ctx = c; width = CGFloat(w); height = CGFloat(h)
        ctx.interpolationQuality = .high
        ctx.setShouldSmoothFonts(false)
        ctx.translateBy(x: 0, y: height)
        ctx.scaleBy(x: 1, y: -1)
    }

    func image() -> CGImage { ctx.makeImage()! }

    /// Draws an image upright into a rect given in top-left coordinates.
    func draw(_ img: CGImage, in rect: CGRect) {
        ctx.saveGState()
        ctx.translateBy(x: rect.minX, y: rect.maxY)
        ctx.scaleBy(x: 1, y: -1)
        ctx.draw(img, in: CGRect(origin: .zero, size: rect.size))
        ctx.restoreGState()
    }

    func linearGradient(_ stops: [(CGColor, CGFloat)], from a: CGPoint, to b: CGPoint) {
        let g = CGGradient(colorsSpace: srgb, colors: stops.map(\.0) as CFArray, locations: stops.map(\.1))!
        ctx.drawLinearGradient(g, start: a, end: b, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    }

    /// CSS `radial-gradient(rx ry at cx cy, colour, transparent 70%)`, all in pixels.
    func ellipseGlow(_ c: CGColor, center: CGPoint, rx: CGFloat, ry: CGFloat) {
        let comps = c.components!
        let clear = CGColor(colorSpace: srgb, components: [comps[0], comps[1], comps[2], 0])!
        let g = CGGradient(colorsSpace: srgb, colors: [c, clear] as CFArray, locations: [0, 0.7])!
        ctx.saveGState()
        ctx.translateBy(x: center.x, y: center.y)
        ctx.scaleBy(x: 1, y: ry / rx)
        ctx.drawRadialGradient(g, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: rx, options: [])
        ctx.restoreGState()
    }
}

// MARK: - Text (CSS line boxes: line-height × size, content area centred in it)

struct TextStyle {
    var size: CGFloat
    var weight: NSFont.Weight
    var tracking: CGFloat      // em
    var color: CGColor
    var lineHeight: CGFloat    // factor

    var font: CTFont {
        let base = NSFont.systemFont(ofSize: size, weight: weight)
        guard let d = base.fontDescriptor.withDesign(.rounded) else { fail("SF Rounded unavailable") }
        return NSFont(descriptor: d, size: size)! as CTFont
    }
}

func ctLine(_ s: String, _ st: TextStyle) -> CTLine {
    let attrs: [NSAttributedString.Key: Any] = [.font: st.font, .kern: st.tracking * st.size,
                                                 NSAttributedString.Key(kCTForegroundColorAttributeName as String): st.color]
    return CTLineCreateWithAttributedString(NSAttributedString(string: s, attributes: attrs))
}

func width(_ s: String, _ st: TextStyle) -> CGFloat {
    CGFloat(CTLineGetTypographicBounds(ctLine(s, st), nil, nil, nil))
}

/// Greedy lines for one paragraph.
func greedy(_ words: [String], _ st: TextStyle, _ maxW: CGFloat) -> [String] {
    var lines: [String] = [], cur = ""
    for w in words {
        let t = cur.isEmpty ? w : cur + " " + w
        if cur.isEmpty || width(t, st) <= maxW { cur = t } else { lines.append(cur); cur = w }
    }
    if !cur.isEmpty { lines.append(cur) }
    return lines
}

/// `text-wrap: balance`: the fewest lines greedy needs, with breaks chosen so the
/// longest line is as short as possible.
func balanced(_ words: [String], _ st: TextStyle, _ maxW: CGFloat) -> [String] {
    let n = greedy(words, st, maxW).count
    guard n > 1 else { return [words.joined(separator: " ")] }
    var best: [String] = greedy(words, st, maxW), bestW = best.map { width($0, st) }.max()!
    func search(_ start: Int, _ remaining: Int, _ acc: [String]) {
        if remaining == 1 {
            let last = words[start...].joined(separator: " ")
            let lines = acc + [last]
            let w = lines.map { width($0, st) }.max()!
            if w <= maxW && w < bestW { best = lines; bestW = w }
            return
        }
        guard start < words.count - remaining + 1 else { return }
        for end in (start + 1)...(words.count - remaining + 1) {
            search(end, remaining - 1, acc + [words[start..<end].joined(separator: " ")])
        }
    }
    search(0, n, [])
    return best
}

/// Lines for a block: "\n" is a forced break (the mockup's <br>); each paragraph wraps.
func layout(_ text: String, _ st: TextStyle, _ maxW: CGFloat, balance: Bool) -> [String] {
    text.components(separatedBy: "\n").flatMap { p -> [String] in
        let words = p.split(separator: " ").map(String.init)
        return balance ? balanced(words, st, maxW) : greedy(words, st, maxW)
    }
}

enum Align { case left, center }

/// Draws lines from `top`; returns the bottom of the last line box.
@discardableResult
func drawLines(_ lines: [String], _ st: TextStyle, on cv: Canvas, left: CGFloat, width avail: CGFloat,
               top: CGFloat, align: Align, alpha: CGFloat = 1) -> CGFloat {
    let f = st.font
    let ascent = CTFontGetAscent(f), descent = CTFontGetDescent(f)
    let lh = st.lineHeight * st.size
    var y = top
    cv.ctx.saveGState()
    cv.ctx.setAlpha(alpha)
    cv.ctx.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
    for s in lines {
        let line = ctLine(s, st)
        let w = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
        let x = align == .center ? left + (avail - w) / 2 : left
        let baseline = y + (lh - (ascent + descent)) / 2 + ascent
        cv.ctx.textPosition = CGPoint(x: x, y: baseline)
        CTLineDraw(line, cv.ctx)
        y += lh
    }
    cv.ctx.restoreGState()
    return y
}

// MARK: - Bezels

struct Bezel {
    let image: CGImage
    let mask: CGImage          // the display area, white
    let cutout: CGRect         // where the capture goes, bezel pixels, top-left
}

func rasterAlpha(_ img: CGImage) -> [UInt8] {
    let w = img.width, h = img.height
    var buf = [UInt8](repeating: 0, count: w * h)
    let ctx = CGContext(data: &buf, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w, space: CGColorSpaceCreateDeviceGray(),
                        bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue)!
    ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
    return buf  // row 0 = top
}

func flood(_ open: (Int) -> Bool, seeds: [Int], w: Int, h: Int) -> [Bool] {
    var seen = [Bool](repeating: false, count: w * h), stack = seeds.filter(open)
    for s in stack { seen[s] = true }
    while let p = stack.popLast() {
        let x = p % w, y = p / w
        for q in [x > 0 ? p - 1 : -1, x < w - 1 ? p + 1 : -1, y > 0 ? p - w : -1, y < h - 1 ? p + w : -1]
        where q >= 0 && !seen[q] && open(q) { seen[q] = true; stack.append(q) }
    }
    return seen
}

/// Finds the display area (the transparent region around the bezel's centre, with
/// cut-outs such as the Dynamic Island filled in), and centres the capture on it.
func loadBezel(_ path: String, capture: CGSize) -> Bezel {
    let img = loadImage(path)
    let w = img.width, h = img.height
    let alpha = rasterAlpha(img)
    let inside = flood({ alpha[$0] < 128 }, seeds: [(h / 2) * w + w / 2], w: w, h: h)
    var x0 = w, y0 = h, x1 = 0, y1 = 0
    for p in 0..<(w * h) where inside[p] {
        let x = p % w, y = p / w
        x0 = min(x0, x); x1 = max(x1, x); y0 = min(y0, y); y1 = max(y1, y)
    }
    let bw = x1 - x0 + 1, bh = y1 - y0 + 1
    guard abs(CGFloat(bw) - capture.width) <= 6, abs(CGFloat(bh) - capture.height) <= 6 else {
        fail("\(path): display area \(bw)×\(bh) doesn't match capture \(Int(capture.width))×\(Int(capture.height))")
    }
    // Fill holes (the island): within the display's box, everything not reachable
    // from the box edge through non-display pixels belongs to the display.
    let inBox = { (p: Int) -> Bool in let x = p % w, y = p / w; return x >= x0 && x <= x1 && y >= y0 && y <= y1 }
    var edge: [Int] = []
    for x in x0...x1 { edge.append(y0 * w + x); edge.append(y1 * w + x) }
    for y in y0...y1 { edge.append(y * w + x0); edge.append(y * w + x1) }
    let outside = flood({ inBox($0) && !inside[$0] }, seeds: edge, w: w, h: h)
    // Grow by 3px so the anti-aliased inner edge of the frame sits over the capture.
    var display = [Bool](repeating: false, count: w * h)
    for p in 0..<(w * h) where inBox(p) && !outside[p] { display[p] = true }
    for _ in 0..<3 {
        var grown = display
        for p in 0..<(w * h) where display[p] {
            let x = p % w, y = p / w
            if x > 0 { grown[p - 1] = true }; if x < w - 1 { grown[p + 1] = true }
            if y > 0 { grown[p - w] = true }; if y < h - 1 { grown[p + w] = true }
        }
        display = grown
    }
    var maskBytes = display.map { $0 ? UInt8(255) : 0 }
    let maskCtx = CGContext(data: &maskBytes, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w,
                            space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)!
    let mask = maskCtx.makeImage()!
    let cx = CGFloat(x0 + x1 + 1) / 2, cy = CGFloat(y0 + y1 + 1) / 2
    let cut = CGRect(x: (cx - capture.width / 2).rounded(), y: (cy - capture.height / 2).rounded(),
                     width: capture.width, height: capture.height)
    print(String(format: "  bezel %@: %d×%d, display box %d×%d at (%d,%d), capture at (%.0f,%.0f) = l %.4f t %.4f",
                 (path as NSString).lastPathComponent, w, h, bw, bh, x0, y0, cut.minX, cut.minY,
                 cut.minX / CGFloat(w), cut.minY / CGFloat(h)))
    return Bezel(image: img, mask: mask, cutout: cut)
}

/// The capture inside its bezel, at the bezel's own resolution.
func device(_ capture: CGImage, _ b: Bezel) -> CGImage {
    let w = b.image.width, h = b.image.height
    let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: srgb,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .none
    let full = CGRect(x: 0, y: 0, width: w, height: h)
    ctx.saveGState()
    ctx.clip(to: full, mask: b.mask)
    // CG's origin is bottom-left; the cut-out is measured from the top.
    ctx.draw(capture, in: CGRect(x: b.cutout.minX, y: CGFloat(h) - b.cutout.maxY, width: b.cutout.width, height: b.cutout.height))
    ctx.restoreGState()
    ctx.draw(b.image, in: full)
    return ctx.makeImage()!
}

/// Draws the device so its screen lands on `screen` (canvas pixels, top-left).
/// Returns the bezel's outer rect.
@discardableResult
func place(_ dev: CGImage, _ b: Bezel, screen: CGRect, on cv: Canvas) -> CGRect {
    let s = screen.width / b.cutout.width
    let r = CGRect(x: screen.minX - b.cutout.minX * s, y: screen.minY - b.cutout.minY * s,
                   width: CGFloat(b.image.width) * s, height: CGFloat(b.image.height) * s)
    cv.draw(dev, in: r)
    return r
}

// MARK: - Screenshot sets

struct SetSpec {
    let folder: String
    let w: Int, h: Int
    let bezel: String
    let screenW, screenTop, capTop, capSize, subSize, m, mTop: CGFloat
}

struct Shot {
    let set: SetSpec
    let out: String
    let capture: String
    let caption: String
    let subline: String?
    var dark = false
}

let brand = "#3730A3"

func background(_ cv: Canvas, dark: Bool) {
    let stops: [(CGColor, CGFloat)] = dark
        ? [(color("#1B1946"), 0), (color("#131238"), 0.55), (color("#0B0A24"), 1)]
        : [(color("#EEF0FF"), 0), (color("#E3E2F8"), 0.55), (color("#D9D7F4"), 1)]
    cv.linearGradient(stops, from: CGPoint(x: cv.width / 2, y: 0), to: CGPoint(x: cv.width / 2, y: cv.height))
    // CSS paints the first-listed layer on top, so the lower glow goes first.
    cv.ellipseGlow(dark ? rgba(91, 80, 214, 0.25) : rgba(55, 48, 163, 0.18),
                   center: CGPoint(x: 0.5 * cv.width, y: 1.10 * cv.height), rx: 0.70 * cv.width, ry: 0.40 * cv.height)
    cv.ellipseGlow(dark ? rgba(140, 131, 240, 0.28) : rgba(91, 80, 214, 0.22),
                   center: CGPoint(x: 0.5 * cv.width, y: 0.24 * cv.height), rx: 0.60 * cv.width, ry: 0.32 * cv.height)
}

var bezelCache: [String: Bezel] = [:]
var problems: [String] = []
var notes: [String] = []

func render(_ shot: Shot, captures: String, bezels: String, out: String) {
    let s = shot.set
    let cap = loadImage(captures + "/" + shot.capture)
    let capSize = CGSize(width: cap.width, height: cap.height)
    let key = s.bezel + "@\(cap.width)x\(cap.height)"
    if bezelCache[key] == nil { bezelCache[key] = loadBezel(bezels + "/" + s.bezel, capture: capSize) }
    let b = bezelCache[key]!

    let cv = Canvas(s.w, s.h)
    background(cv, dark: shot.dark)

    let avail = cv.width - 2 * s.m
    let head = TextStyle(size: s.capSize, weight: .heavy, tracking: -0.02, color: color(shot.dark ? "#EDEBFF" : brand), lineHeight: 1.08)
    let headLines = layout(shot.caption, head, avail, balance: true)
    var bottom = drawLines(headLines, head, on: cv, left: s.m, width: avail, top: s.capTop, align: .center)
    var subLines: [String] = []
    if let sub = shot.subline {
        let st = TextStyle(size: s.subSize, weight: .semibold, tracking: 0, color: color(shot.dark ? "#B3ACF5" : "#5B50D6"), lineHeight: 1.08)
        subLines = layout(sub, st, avail, balance: true)
        bottom = drawLines(subLines, st, on: cv, left: s.m, width: avail, top: bottom + 22, align: .center, alpha: 0.92)
    }

    let screenH = s.screenW * capSize.height / capSize.width
    let screen = CGRect(x: (cv.width - s.screenW) / 2, y: s.screenTop, width: s.screenW, height: screenH)
    let frame = place(device(cap, b), b, screen: screen, on: cv)

    let path = out + "/" + s.folder + "/" + shot.out
    writePNG(cv.image(), path)
    print(String(format: "%@/%@  %d×%d  caption %@%@  text ends %.0f, bezel %.0f–%.0f (safe %.0f–%.0f, sides %.0f–%.0f vs %.0f–%.0f)",
                 s.folder, shot.out, s.w, s.h, headLines.joined(separator: " | "),
                 subLines.isEmpty ? "" : "  sub " + subLines.joined(separator: " | "),
                 bottom, frame.minY, frame.maxY, s.mTop, cv.height - s.mTop, frame.minX, frame.maxX, s.m, cv.width - s.m))
    if bottom > frame.minY { problems.append("\(path): caption overlaps the device") }
    let over = max(s.mTop - s.capTop, frame.maxY - (cv.height - s.mTop), s.m - frame.minX, frame.maxX - (cv.width - s.m))
    if over > 0 {
        // The approved mockup's geometry is kept as rendered; overshoots of the
        // spec's margins are reported, and fail only when large.
        let msg = String(format: "%@: device or caption %.0fpx past the spec's margin (mockup geometry kept)", path, over)
        if over > 12 { problems.append(msg) } else { notes.append(msg) }
    }
}

// MARK: - Product page header (3840 × 1646)

/// Apple's "Art Safe Area" in the product page header template
/// (creative_assets-product_page_header_template-static.psd, 3840 × 1646):
/// the centred region kept on every device's crop.
let appleHeaderSafeArea = CGRect(x: 1097, y: 493, width: 1645, height: 660)

enum HeaderLayout { case approved, fittedToSafeArea }

func renderHeader(_ variant: HeaderLayout, captures: String, bezels: String, out: String) {
    let W = 3840, H = 1646
    let cv = Canvas(W, H)
    // linear-gradient(100deg, …): the gradient line runs at 100° through the centre.
    let a = 100 * CGFloat.pi / 180, dir = CGPoint(x: sin(a), y: -cos(a))
    let len = cv.width * abs(sin(a)) + cv.height * abs(cos(a))
    let c = CGPoint(x: cv.width / 2, y: cv.height / 2)
    cv.linearGradient([(color("#EEF0FF"), 0), (color("#E2E0F8"), 0.5), (color("#D4D1F2"), 1)],
                      from: CGPoint(x: c.x - dir.x * len / 2, y: c.y - dir.y * len / 2),
                      to: CGPoint(x: c.x + dir.x * len / 2, y: c.y + dir.y * len / 2))
    cv.ellipseGlow(rgba(91, 80, 214, 0.22), center: CGPoint(x: 0.70 * cv.width, y: 0.5 * cv.height),
                   rx: 0.45 * cv.width, ry: 0.80 * cv.height)

    // Everything below is laid out in the approved design's coordinates. The
    // fitted variant scales that whole composition uniformly into Apple's art
    // safe area (the background still fills the canvas).
    let contentBox = CGRect(x: 268.8, y: 243, width: 3694.6 - 268.8, height: 1572.3 - 243)  // text + both bezels, approved layout
    var k: CGFloat = 1
    if variant == .fittedToSafeArea {
        let sa = appleHeaderSafeArea.insetBy(dx: 30, dy: 30)   // a little air inside Apple's box
        k = min(sa.width / contentBox.width, sa.height / contentBox.height)
        cv.ctx.translateBy(x: sa.midX - contentBox.midX * k, y: sa.midY - contentBox.midY * k)
        cv.ctx.scaleBy(x: k, y: k)
    }

    // Text block: left 7%, 28% wide, vertically centred.
    let size = 0.046 * cv.width
    let head = TextStyle(size: size, weight: .heavy, tracking: -0.025, color: color(brand), lineHeight: 1.02)
    let sub = TextStyle(size: 0.42 * size, weight: .semibold, tracking: 0, color: color("#5B50D6"), lineHeight: 1.02)
    let left = 0.07 * cv.width, avail = 0.28 * cv.width
    let headLines = layout("Keep score.\nSee who\u{2019}s winning.", head, avail, balance: false)
    let subLines = layout("On iPhone, iPad and iPhone Duo", sub, avail, balance: false)
    let gap = 0.5 * sub.size
    let blockH = CGFloat(headLines.count) * head.lineHeight * head.size + gap + CGFloat(subLines.count) * sub.lineHeight * sub.size
    let top = (cv.height - blockH) / 2
    let after = drawLines(headLines, head, on: cv, left: left, width: avail, top: top, align: .left)
    drawLines(subLines, sub, on: cv, left: left, width: avail, top: after + gap, align: .left)

    // Devices: right 57% (40%–97%), screens' bottoms 8% above the edge; the open
    // Duo sideways (silhouette ~1080px), then the iPhone (silhouette ~1300px).
    let regionL = 0.40 * cv.width, regionW = 0.57 * cv.width, screenBottom = cv.height * 0.92
    var frames: [CGRect] = []
    for (file, bezelFile, leftPct, silhouette) in [("duo-inner/standings-sideways.png", "duo-inner-landscape.png", 0.0, 1080.0),
                                                   ("iphone-6.9/standings.png", "iphone-18-pro-max-portrait.png", 0.71, 1300.0)] {
        let cap = loadImage(captures + "/" + file)
        let capSize = CGSize(width: cap.width, height: cap.height)
        let b = loadBezel(bezels + "/" + bezelFile, capture: capSize)
        let screenH = CGFloat(silhouette) * b.cutout.height / CGFloat(b.image.height)
        let screenW = screenH * capSize.width / capSize.height
        let screen = CGRect(x: regionL + CGFloat(leftPct) * regionW, y: screenBottom - screenH, width: screenW, height: screenH)
        frames.append(place(device(cap, b), b, screen: screen, on: cv))
    }
    let path = out + "/header/" + (variant == .approved ? "product-page-header-3840x1646.png"
                                                     : "alternative-fitted-to-apple-safe-area/product-page-header-3840x1646-fitted.png")
    writePNG(cv.image(), path)
    let textRight = left + max(headLines.map { width($0, head) }.max()!, subLines.map { width($0, sub) }.max()!)
    let content = frames.reduce(CGRect(x: left, y: top, width: textRight - left, height: blockH)) { $0.union($1) }
    print(String(format: "header (%@)  %d×%d  text %@ / %@ at %.0fpx  content box (%.0f,%.0f)-(%.0f,%.0f) in design coords, scale %.3f",
                 variant == .approved ? "approved" : "fitted", W, H, headLines.joined(separator: " | "), subLines.joined(separator: " | "),
                 size * k, content.minX, content.minY, content.maxX, content.maxY, k))
    if abs(content.minX - contentBox.minX) > 2 || abs(content.maxX - contentBox.maxX) > 2 || abs(content.minY - contentBox.minY) > 2 || abs(content.maxY - contentBox.maxY) > 2 {
        problems.append("\(path): content box drifted from the fitted variant's assumption")
    }
    if frames[0].maxX > frames[1].minX { problems.append("\(path): devices overlap") }
    if frames.contains(where: { $0.minY < 0 || $0.maxY > cv.height || $0.maxX > cv.width }) { problems.append("\(path): device off the canvas") }
    if variant == .approved {
        notes.append("\(path): approved layout; the headline and iPhone sit outside Apple's art safe area \(appleHeaderSafeArea)")
    }
    safeAreaCheck(cv.image(), out: out + "/tools/checks/header-" + (variant == .approved ? "approved" : "fitted") + "-vs-apple-safe-area.png")
}

/// A reviewer's copy with Apple's art safe area drawn on (not for upload).
func safeAreaCheck(_ img: CGImage, out path: String) {
    let cv = Canvas(img.width / 2, img.height / 2)
    cv.draw(img, in: CGRect(x: 0, y: 0, width: cv.width, height: cv.height))
    let sa = appleHeaderSafeArea.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
    cv.ctx.setFillColor(rgba(0, 0, 0, 0.35))
    cv.ctx.addRect(CGRect(x: 0, y: 0, width: cv.width, height: cv.height)); cv.ctx.addRect(sa)
    cv.ctx.fillPath(using: .evenOdd)
    cv.ctx.setStrokeColor(rgba(0, 200, 0, 1)); cv.ctx.setLineWidth(3); cv.ctx.stroke(sa)
    let label = TextStyle(size: 22, weight: .bold, tracking: 0, color: rgba(0, 120, 0, 1), lineHeight: 1.2)
    drawLines(["Apple art safe area (header template)"], label, on: cv, left: sa.minX + 8, width: sa.width, top: sa.minY - 32, align: .left)
    writePNG(cv.image(), path)
}

// MARK: - Main

let args = CommandLine.arguments
guard args.count == 4 else { fail("usage: compose <captures-dir> <bezel-dir> <out-dir>") }
let (captures, bezels, out) = (args[1], args[2], args[3])

let iphone = SetSpec(folder: "iphone-6.9-1320x2868", w: 1320, h: 2868, bezel: "iphone-18-pro-max-portrait.png",
                     screenW: 980, screenTop: 560, capTop: 170, capSize: 92, subSize: 44, m: 80, mTop: 115)
let ipad = SetSpec(folder: "ipad-13-2064x2752", w: 2064, h: 2752, bezel: "ipad-pro-13-portrait.png",
                   screenW: 1480, screenTop: 560, capTop: 150, capSize: 104, subSize: 48, m: 124, mTop: 110)
let outer = SetSpec(folder: "iphone-duo-outer-1398x2034", w: 1398, h: 2034, bezel: "duo-outer-closed.png",
                    screenW: 990, screenTop: 430, capTop: 120, capSize: 84, subSize: 40, m: 84, mTop: 82)
let upright = SetSpec(folder: "iphone-duo-inner", w: 2007, h: 2853, bezel: "duo-inner-portrait.png",
                      screenW: 1460, screenTop: 580, capTop: 170, capSize: 104, subSize: 48, m: 120, mTop: 115)
let sideways = SetSpec(folder: "iphone-duo-inner", w: 2853, h: 2007, bezel: "duo-inner-landscape.png",
                       screenW: 2000, screenTop: 390, capTop: 110, capSize: 92, subSize: 44, m: 160, mTop: 80)

let keepScore = "Keep score.\nSee who\u{2019}s winning."
let tapIn = "Tap in scores.\nWe do the math."
let gameEnds = "The game ends at 100.\nLowest score wins."
let players = "2 to 8 players. Ready in seconds."
let doubled = "Ended the round without the lowest score? Doubled, automatically"

let shots: [Shot] = [
    Shot(set: iphone, out: "01-standings.png", capture: "iphone-6.9/standings.png", caption: keepScore, subline: "Standings update after every round"),
    Shot(set: iphone, out: "02-score-entry.png", capture: "iphone-6.9/entry.png", caption: tapIn, subline: doubled),
    Shot(set: iphone, out: "03-final-standings.png", capture: "iphone-6.9/final-standings.png", caption: gameEnds, subline: nil),
    Shot(set: iphone, out: "04-setup.png", capture: "iphone-6.9/setup.png", caption: players, subline: nil),
    Shot(set: iphone, out: "05-standings-dark.png", capture: "iphone-6.9/standings-dark.png", caption: "Free. No ads. No account.", subline: "Dark mode too", dark: true),

    Shot(set: ipad, out: "01-standings.png", capture: "ipad-13/standings.png", caption: keepScore, subline: "Big enough for the whole table"),
    Shot(set: ipad, out: "02-score-entry.png", capture: "ipad-13/entry.png", caption: tapIn, subline: doubled),
    Shot(set: ipad, out: "03-final-standings.png", capture: "ipad-13/final-standings.png", caption: gameEnds, subline: nil),
    Shot(set: ipad, out: "04-setup.png", capture: "ipad-13/setup.png", caption: players, subline: nil),

    Shot(set: outer, out: "01-standings.png", capture: "duo-outer/standings.png", caption: keepScore, subline: nil),
    Shot(set: outer, out: "02-score-entry.png", capture: "duo-outer/entry.png", caption: tapIn, subline: nil),
    Shot(set: outer, out: "03-final-standings.png", capture: "duo-outer/final-standings.png", caption: gameEnds, subline: nil),
    Shot(set: outer, out: "04-setup.png", capture: "duo-outer/setup.png", caption: players, subline: nil),

    Shot(set: upright, out: "01-standings-upright-2007x2853.png", capture: "duo-inner/standings-upright.png", caption: keepScore, subline: "Room for the whole table"),
    Shot(set: sideways, out: "02-score-entry-sideways-2853x2007.png", capture: "duo-inner/entry-sideways.png", caption: "Tap in scores. We do the math.", subline: nil),
    Shot(set: upright, out: "03-final-standings-upright-2007x2853.png", capture: "duo-inner/final-standings-upright.png", caption: gameEnds, subline: nil),
    Shot(set: sideways, out: "04-setup-sideways-2853x2007.png", capture: "duo-inner/setup-sideways.png", caption: players, subline: nil),
]

for shot in shots { render(shot, captures: captures, bezels: bezels, out: out) }
renderHeader(.approved, captures: captures, bezels: bezels, out: out)
renderHeader(.fittedToSafeArea, captures: captures, bezels: bezels, out: out)

notes.forEach { print("NOTE: \($0)") }
if problems.isEmpty { print("OK: \(shots.count) screenshots and 2 headers (approved, fitted alternative) written to \(out)") }
else { problems.forEach { print("PROBLEM: \($0)") }; exit(2) }
