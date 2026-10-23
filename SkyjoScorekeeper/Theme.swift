import SwiftUI

enum Theme {
    static let brand = Color(red: 0.216, green: 0.188, blue: 0.639)
    static let brandHighContrast = Color(red: 0.1647, green: 0.1412, blue: 0.4588)
    static let contentMaxWidth: CGFloat = 600

    // Okabe-Ito color-blind-safe palette. Each player position gets a unique color.
    private static let playerPalette: [(Color, Color)] = [
        (Color(red: 0.216, green: 0.188, blue: 0.639), .white),    // Indigo (brand)
        (Color(red: 0.902, green: 0.624, blue: 0.000), .white),    // Orange
        (Color(red: 0.000, green: 0.620, blue: 0.451), .white),    // Teal
        (Color(red: 0.835, green: 0.369, blue: 0.000), .white),    // Vermillion
        (Color(red: 0.000, green: 0.447, blue: 0.698), .white),    // Blue
        (Color(red: 0.800, green: 0.475, blue: 0.655), .white),    // Pink-purple
        (Color(red: 0.337, green: 0.706, blue: 0.914), Color(.label)), // Sky blue
        (Color(red: 0.941, green: 0.894, blue: 0.259), Color(.label)), // Yellow
    ]

    // Higher-contrast variants meeting WCAG AA (4.5:1) against white text.
    // Sky blue and yellow switch from dark text to white text in high-contrast mode.
    private static let playerPaletteHighContrast: [(Color, Color)] = [
        (Color(red: 0.1647, green: 0.1412, blue: 0.4588), .white), // Indigo HC   ~11:1
        (Color(red: 0.5412, green: 0.3843, blue: 0.000),  .white), // Orange HC   ~5.5:1
        (Color(red: 0.000,  green: 0.4784, blue: 0.3490), .white), // Teal HC     ~5.4:1
        (Color(red: 0.6902, green: 0.2941, blue: 0.000),  .white), // Vermillion HC ~5.4:1
        (Color(red: 0.000,  green: 0.3529, blue: 0.5569), .white), // Blue HC     ~7.4:1
        (Color(red: 0.6275, green: 0.3255, blue: 0.4941), .white), // Pink-purple HC ~5.2:1
        (Color(red: 0.1255, green: 0.4157, blue: 0.6196), .white), // Sky blue HC ~5.8:1
        (Color(red: 0.4784, green: 0.4392, blue: 0.000),  .white), // Yellow HC   ~5.1:1
    ]

    static func playerColor(at index: Int, highContrast: Bool = false) -> Color {
        let palette = highContrast ? playerPaletteHighContrast : playerPalette
        return palette[index % palette.count].0
    }

    static func playerTextColor(at index: Int, highContrast: Bool = false) -> Color {
        let palette = highContrast ? playerPaletteHighContrast : playerPalette
        return palette[index % palette.count].1
    }
}

// MARK: - Adaptive layout

/// How a screen arranges itself, decided only by the space it is given.
/// iOS 27 windows can be any shape (iPhone Duo, iPhone Mirroring, resizable
/// iPad windows), so never branch on orientation, device idiom, or screen size.
enum LayoutMode: Equatable {
    /// Today's tall arrangement.
    case tall
    /// Too short for the tall arrangement, and too narrow to go side by side.
    case short
    /// Wide enough to go side by side, and either short or clearly wider than tall.
    case wide

    /// Below this height the tall layouts can no longer keep their content in view
    /// (the stacked entry sheet needs this much to show two player rows).
    static let shortHeight: CGFloat = 575
    /// The narrowest width that fits a 284pt control column beside the player rows.
    static let wideMinWidth: CGFloat = 560
    /// Width ÷ height at or above which a space counts as clearly wider than tall.
    static let wideAspectRatio: CGFloat = 1.2

    init(size: CGSize) {
        guard size.width > 0, size.height > 0 else {
            self = .tall
            return
        }
        let short = Self.isShort(height: size.height)
        if size.width >= Self.wideMinWidth,
           short || size.width / size.height >= Self.wideAspectRatio {
            self = .wide
        } else if short {
            self = .short
        } else {
            self = .tall
        }
    }

    /// True when the height alone is too short for the tall arrangement.
    static func isShort(height: CGFloat) -> Bool {
        height > 0 && height < shortHeight
    }
}

// MARK: - Folds (iPhone Duo)

/// Where a fold divides the space a screen is given, in that screen's own
/// coordinates. iPhone Duo reports its fold as a reserved `.division` region.
enum Division: Equatable {
    /// The fold runs top to bottom (open like a book); `band` is its span along x.
    case vertical(band: ClosedRange<CGFloat>)
    /// The fold runs side to side (propped like a laptop); `band` is its span along y.
    case horizontal(band: ClosedRange<CGFloat>)
}

/// The two pages either side of a vertical fold. The band between them holds nothing.
struct Pages: Equatable {
    var leading: CGRect
    var trailing: CGRect

    /// The width of the fold band, for an `HStack` of the two pages.
    var spacing: CGFloat { trailing.minX - leading.maxX }
}

/// The space a screen is offered: its size, plus any fold or camera region
/// inside it. A screen goes to two pages when a fold runs top to bottom through it.
struct AvailableSpace: Equatable {
    var size: CGSize
    var division: Division?
    /// Camera and sensor regions, clipped to the space.
    var occlusions: [CGRect]

    /// Classifies the reserved regions read from the space (all in its own
    /// coordinates). A fold counts only when it lies inside the space with room
    /// on both sides; one touching an edge (a Split View window beside the fold)
    /// leaves the space undivided.
    init(size: CGSize, divisions: [CGRect] = [], occlusions: [CGRect] = []) {
        self.size = size
        let bounds = CGRect(origin: .zero, size: size)
        self.division = divisions.lazy.compactMap { frame -> Division? in
            let band = frame.intersection(bounds)
            guard !band.isNull, !band.isEmpty else { return nil }
            if band.height >= band.width {
                guard band.minX > bounds.minX, band.maxX < bounds.maxX else { return nil }
                return .vertical(band: band.minX...band.maxX)
            } else {
                guard band.minY > bounds.minY, band.maxY < bounds.maxY else { return nil }
                return .horizontal(band: band.minY...band.maxY)
            }
        }.first
        self.occlusions = occlusions
            .map { $0.intersection(bounds) }
            .filter { !$0.isNull && !$0.isEmpty }
    }

    var layoutMode: LayoutMode { LayoutMode(size: size) }

    /// The pages either side of a vertical fold; nil when the space isn't divided that way.
    var pages: Pages? {
        guard case .vertical(let band) = division else { return nil }
        return Pages(
            leading: page(CGRect(x: 0, y: 0, width: band.lowerBound, height: size.height)),
            trailing: page(CGRect(x: band.upperBound, y: 0, width: size.width - band.upperBound, height: size.height))
        )
    }

    /// The part above a horizontal fold; nil when the space isn't divided that way.
    var upperPage: CGRect? {
        guard case .horizontal(let band) = division else { return nil }
        return page(CGRect(x: 0, y: 0, width: size.width, height: band.lowerBound))
    }

    /// The part below a horizontal fold; nil when the space isn't divided that way.
    var lowerPage: CGRect? {
        guard case .horizontal(let band) = division else { return nil }
        return page(CGRect(x: 0, y: band.upperBound, width: size.width, height: size.height - band.upperBound))
    }

    /// A page starts below any camera region in its top half. (On iPhone Duo the
    /// camera normally sits inside the safe area, so nothing moves.)
    private func page(_ rect: CGRect) -> CGRect {
        let top = occlusions
            .filter { $0.intersects(rect) && $0.minY < rect.midY }
            .map(\.maxY)
            .max() ?? rect.minY
        guard top > rect.minY else { return rect }
        return CGRect(x: rect.minX, y: top, width: rect.width, height: max(rect.maxY - top, 0))
    }
}

extension AvailableSpace {
    /// Reads the space a geometry proxy describes. Fold and camera regions come
    /// from `ReservedRegion` on iOS 27.1 and later; earlier systems have none.
    /// The fold is read even while inactive (the phone lying flat), so the pages
    /// hold steady through the hinge's whole range instead of the controls
    /// jumping back onto the crease.
    init(_ proxy: GeometryProxy) {
        var divisions: [CGRect] = []
        var occlusions: [CGRect] = []
        if #available(iOS 27.1, *) {
            divisions = proxy.reservedRegions(kind: .division, options: .includeInactive).map(\.frame)
            occlusions = proxy.reservedRegions(kind: .occlusion).filter(\.isActive).map(\.frame)
        }
        self.init(size: proxy.size, divisions: divisions, occlusions: occlusions)
    }
}

extension View {
    /// Fills the space this view is offered and keeps `value` in step with a value
    /// derived from that space's size. See `onAvailableSpace(update:_:)`.
    func onAvailableSize<Value: Equatable>(
        update value: Binding<Value>,
        _ derive: @escaping (CGSize) -> Value
    ) -> some View {
        onAvailableSpace(update: value) { derive($0.size) }
    }

    /// Fills the space this view is offered and keeps `value` in step with a value
    /// derived from that space: its size and any fold or camera region in it.
    /// The keyboard is ignored, so typing never reflows a screen. The first
    /// reading applies instantly; later changes (a window being resized, the
    /// phone unfolding) animate ease-out over 240ms, or apply instantly with
    /// Reduce Motion.
    func onAvailableSpace<Value: Equatable>(
        update value: Binding<Value>,
        _ derive: @escaping (AvailableSpace) -> Value
    ) -> some View {
        modifier(AvailableSpaceReader(value: value, derive: derive))
    }

    /// Lays this view out as one page of a two-page arrangement: the page's width,
    /// starting at its top (below any camera region).
    func page(_ frame: CGRect) -> some View {
        self
            .frame(width: frame.width)
            .frame(maxHeight: .infinity)
            .padding(.top, frame.minY)
    }
}

private struct AvailableSpaceReader<Value: Equatable>: ViewModifier {
    @Binding var value: Value
    let derive: (AvailableSpace) -> Value

    @State private var hasMeasured = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            // Exactly the offered size, even when content overflows it (large
            // Dynamic Type), so the reading is the container, never the content.
            // Otherwise an overflowing layout could flip its own mode.
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background {
                // Measure inside the keyboard-ignoring region (the order of these
                // two modifiers matters: measuring outside it reads the size the
                // keyboard left over).
                Color.clear
                    .onGeometryChange(for: AvailableSpace.self) { proxy in
                        AvailableSpace(proxy)
                    } action: { space in
                        guard space.size.width > 0, space.size.height > 0 else { return }
                        let newValue = derive(space)
                        if newValue != value {
                            withAnimation(hasMeasured && !reduceMotion ? .easeOut(duration: 0.24) : nil) {
                                value = newValue
                            }
                        }
                        hasMeasured = true
                    }
                    .ignoresSafeArea(.keyboard)
            }
    }
}
