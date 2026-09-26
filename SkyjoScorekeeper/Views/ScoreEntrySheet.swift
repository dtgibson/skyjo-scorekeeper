import SwiftUI

struct ScoreEntrySheet: View {
    @ObservedObject var session: GameSession
    let onCommit: ([UUID: Int], UUID?) -> Void

    // Entry state lives here, not inside the mode-specific layouts, so it
    // survives a live switch between stacked and side-by-side.
    @State private var rawInputs: [UUID: String] = [:]
    @State private var negativeInputs: [UUID: Bool] = [:]
    @State private var skyjoPlayerID: UUID? = nil
    @State private var focusedPlayer: UUID?
    @State private var layoutMode: LayoutMode = .tall

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Ideal width of the fitted panel (iOS 18+, regular width).
    static let fittedPanelWidth: CGFloat = 720
    /// Width of the "who ended" / numpad / Confirm column in the side-by-side layout.
    private static let controlColumnWidth: CGFloat = 284

    /// Ideal height of the fitted panel: the numpad column (344pt) plus the
    /// "who ended" chips block, two chips per row. 430 / 480 / 530 / 580pt for
    /// 2 / 4 / 6 / 8 players. The system clamps it to the window.
    static func fittedPanelHeight(playerCount: Int) -> CGFloat {
        let chipRows = CGFloat((max(playerCount, 1) + 1) / 2)
        let chipsBlock = 42 + 44 * chipRows + 6 * (chipRows - 1)
        return 344 + chipsBlock
    }

    private var entries: [UUID: Int] {
        Dictionary(uniqueKeysWithValues: session.players.compactMap { player in
            guard let text = rawInputs[player.id], !text.isEmpty, let value = Int(text) else { return nil }
            let isNeg = negativeInputs[player.id] ?? false
            return (player.id, isNeg ? -value : value)
        })
    }

    private var allFilled: Bool {
        session.players.allSatisfy { entries[$0.id] != nil }
    }

    private var canConfirm: Bool { allFilled && skyjoPlayerID != nil }

    private func minOtherScore(excluding playerID: UUID) -> Int? {
        // Live: the minimum of whatever other scores are entered so far.
        // As lower scores come in this only gets more accurate; the
        // committed result always matches the final (all-filled) preview.
        entries.filter { $0.key != playerID }.values.min()
    }

    var body: some View {
        Group {
            switch layoutMode {
            case .tall, .short: stackedLayout
            case .wide: sideBySideLayout
            }
        }
        .onAvailableSize(update: $layoutMode, LayoutMode.init(size:))
        .background(Color(.systemGroupedBackground))
        .onAppear { focusedPlayer = session.players.first?.id }
    }

    // MARK: - Stacked (tall, and tight when short)

    private var isTight: Bool { layoutMode == .short }

    private var stackedLayout: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: isTight ? 12 : 20) {
                        scoresSection
                        skyjoSection(style: isTight ? .singleRow : .adaptiveGrid)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, isTight ? 18 : 22)
                    .padding(.bottom, 16)
                    .frame(maxWidth: Theme.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                }
                .onAppear { scrollToFocusedRow(proxy, animated: false) }
                .onChange(of: focusedPlayer) { _, _ in scrollToFocusedRow(proxy, animated: true) }
            }

            Divider()

            numpad
                .frame(maxWidth: Theme.contentMaxWidth)
                .frame(maxWidth: .infinity)

            confirmButton
                .padding(.horizontal, 16)
                .padding(.bottom, isTight ? 6 : 8)
                .frame(maxWidth: Theme.contentMaxWidth)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Side by side (wide)

    private var sideBySideLayout: some View {
        HStack(spacing: 0) {
            rowsColumn
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityElement(children: .contain)
                .accessibilitySortPriority(2)

            Divider()
                .padding(.vertical, 12)

            controlsColumn
                .frame(width: Self.controlColumnWidth)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .accessibilityElement(children: .contain)
                .accessibilitySortPriority(1)
        }
    }

    /// Player rows: centred when they fit, top-aligned and scrolling when they don't.
    private var rowsColumn: some View {
        ScrollViewReader { proxy in
            ViewThatFits(in: .vertical) {
                rowsColumnContent
                ScrollView { rowsColumnContent }
            }
            .onAppear { scrollToFocusedRow(proxy, animated: false) }
            .onChange(of: focusedPlayer) { _, _ in scrollToFocusedRow(proxy, animated: true) }
        }
    }

    private var rowsColumnContent: some View {
        scoresSection
            .padding(EdgeInsets(top: 18, leading: 16, bottom: 14, trailing: 12))
            .frame(maxWidth: Theme.contentMaxWidth)
            .frame(maxWidth: .infinity)
    }

    /// "Who ended", numpad and Confirm. The chips take only the height they need
    /// (scrolling only if they must); the numpad keys grow into what remains.
    private var controlsColumn: some View {
        VStack(spacing: 0) {
            ViewThatFits(in: .vertical) {
                skyjoSection(style: .twoColumnGrid)
                ScrollView { skyjoSection(style: .twoColumnGrid) }
                    .frame(minHeight: 96)
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .layoutPriority(1)

            numpad

            confirmButton
                .padding(.leading, 12)
                .padding(.trailing, 16)
                .padding(.bottom, 6)
        }
        .padding(.top, 10)
    }

    // MARK: - Scores

    private var scoresSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ROUND \(session.currentRoundNumber) SCORES")
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(Array(session.players.enumerated()), id: \.element.id) { index, player in
                    ScoreInputRow(
                        player: player,
                        colorIndex: index,
                        digits: rawInputs[player.id] ?? "",
                        isNegative: negativeInputs[player.id] ?? false,
                        doubledValue: doubledValue(for: player.id),
                        isFocused: focusedPlayer == player.id,
                        onTap: { focusedPlayer = player.id }
                    )
                    .id(player.id)
                    if index < session.players.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        }
    }

    // MARK: - Skyjo question

    private enum ChipStyle {
        /// Tall: adaptive grid with the helper line.
        case adaptiveGrid
        /// Tight: one row, scrolling sideways when the chips don't fit.
        case singleRow
        /// Side by side: two fixed columns.
        case twoColumnGrid
    }

    private func skyjoSection(style: ChipStyle) -> some View {
        VStack(alignment: .leading, spacing: style == .adaptiveGrid ? 8 : 6) {
            Text("WHO ENDED THE ROUND?")
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)
                .accessibilityAddTraits(.isHeader)

            if style == .adaptiveGrid {
                Text("The first player to turn over their last card. Their score this round doubles if it isn't the lowest.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
            }

            chips(style: style)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        }
    }

    @ViewBuilder
    private func chips(style: ChipStyle) -> some View {
        switch style {
        case .adaptiveGrid:
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                chipButtons
            }
            .padding(12)
        case .singleRow:
            // Chips share the width when they fit; otherwise the row scrolls.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { chipButtons }
                    .padding(8)
                ScrollView(.horizontal) {
                    HStack(spacing: 8) { chipButtons }
                        .padding(8)
                }
                .scrollIndicators(.hidden)
            }
        case .twoColumnGrid:
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)],
                spacing: 6
            ) {
                chipButtons
            }
            .padding(8)
        }
    }

    private var chipButtons: some View {
        ForEach(Array(session.players.enumerated()), id: \.element.id) { index, player in
            SkyjoChip(
                player: player,
                colorIndex: index,
                isSelected: skyjoPlayerID == player.id,
                onTap: { skyjoPlayerID = player.id }
            )
        }
    }

    // MARK: - Numpad

    private enum NumpadKey: Equatable {
        case digit(Int), toggle, backspace
    }

    private var numpad: some View {
        VStack(spacing: 4) {
            numpadRow([.digit(7), .digit(8), .digit(9)])
            numpadRow([.digit(4), .digit(5), .digit(6)])
            numpadRow([.digit(1), .digit(2), .digit(3)])
            numpadRow([.toggle, .digit(0), .backspace])
        }
        .padding(numpadInsets)
    }

    private var numpadInsets: EdgeInsets {
        switch layoutMode {
        case .tall: EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        case .short: EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        case .wide: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 16)
        }
    }

    /// Keys are 54pt tall stacked, 44pt in the tight stack, and grow from 44pt
    /// to fill the side-by-side column. Always at least 44pt (touch target).
    private var keyMinHeight: CGFloat { layoutMode == .tall ? 54 : 44 }
    private var keyMaxHeight: CGFloat? { layoutMode == .wide ? 72 : nil }

    private func numpadRow(_ keys: [NumpadKey]) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<keys.count, id: \.self) { numpadButton(keys[$0]) }
        }
    }

    @ViewBuilder
    private func numpadButton(_ key: NumpadKey) -> some View {
        let isNegActive = focusedPlayer.flatMap { negativeInputs[$0] } ?? false
        let enabled = focusedPlayer != nil

        Button {
            guard let id = focusedPlayer else { return }
            switch key {
            case .digit(let n):
                let current = rawInputs[id] ?? ""
                guard current.count < 3 else { return }
                rawInputs[id] = (current == "0") ? "\(n)" : current + "\(n)"
            case .toggle:
                negativeInputs[id] = !(negativeInputs[id] ?? false)
            case .backspace:
                let trimmed = String((rawInputs[id] ?? "").dropLast())
                rawInputs[id] = trimmed
                // Clearing the field also clears the sign, so an empty row
                // never keeps a stale negative state for the next digit.
                if trimmed.isEmpty { negativeInputs[id] = false }
            }
            announceCurrentValue(for: id)
        } label: {
            Group {
                switch key {
                case .digit(let n):
                    Text("\(n)")
                        .font(.system(.title2, design: .rounded, weight: .medium))
                        .foregroundStyle(Color(.label))
                case .toggle:
                    Text("+/\u{2212}")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(isNegActive ? Color(.systemRed) : Color(.label))
                case .backspace:
                    Image(systemName: "delete.backward")
                        .font(.system(.callout, weight: .medium))
                        .foregroundStyle(Color(.label))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: keyMinHeight, maxHeight: keyMaxHeight)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(key == .toggle && isNegActive
                          ? Color(.systemRed).opacity(0.12)
                          : Color(.secondarySystemFill))
            )
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(NumpadKeyStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
        .accessibilityLabel(numpadKeyLabel(key, isNegActive: isNegActive))
    }

    private func numpadKeyLabel(_ key: NumpadKey, isNegActive: Bool) -> String {
        switch key {
        case .digit(let n): return "\(n)"
        case .toggle: return isNegActive
            ? String(localized: "Toggle to positive")
            : String(localized: "Toggle negative")
        case .backspace: return String(localized: "Delete")
        }
    }

    // MARK: - Confirm button

    private var confirmButton: some View {
        Button {
            onCommit(entries, skyjoPlayerID)
        } label: {
            Text("Confirm Round \(session.currentRoundNumber)")
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(minHeight: confirmMinHeight)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: canConfirm))
        .disabled(!canConfirm)
        // Keep its full height when large text wraps it to two lines, so the
        // chips above scroll instead of pushing Confirm out of the panel.
        .fixedSize(horizontal: false, vertical: true)
    }

    private var confirmMinHeight: CGFloat {
        switch layoutMode {
        case .tall: 58
        case .short: 50
        case .wide: 52
        }
    }

    // MARK: - Helpers

    /// Keep the row being typed into in view after a tap (or a layout switch).
    private func scrollToFocusedRow(_ proxy: ScrollViewProxy, animated: Bool) {
        guard let id = focusedPlayer else { return }
        if animated && !reduceMotion {
            withAnimation(.easeOut(duration: 0.24)) {
                proxy.scrollTo(id, anchor: .center)
            }
        } else {
            proxy.scrollTo(id, anchor: .center)
        }
    }

    /// Speak the focused player's running score after a numpad press, so a
    /// VoiceOver user hears the value building up (like a calculator).
    private func announceCurrentValue(for id: UUID) {
        let digits = rawInputs[id] ?? ""
        let negative = negativeInputs[id] ?? false
        let value = digits.isEmpty ? "0" : (negative ? "-\(digits)" : digits)
        AccessibilityNotification.Announcement(value).post()
    }

    private func doubledValue(for playerID: UUID) -> Int? {
        guard
            skyjoPlayerID == playerID,
            let raw = entries[playerID],
            let minOther = minOtherScore(excluding: playerID),
            GameSession.isDoubled(raw: raw, minOther: minOther)
        else { return nil }
        return raw * 2
    }
}

// MARK: - Presentation sizing

extension View {
    /// In a regular-width window (iPad, iPhone Duo open) on iOS 18+, present the
    /// entry sheet as a centred panel sized to its content: 720pt wide, with a
    /// height that follows the player count. On iOS 17 the default form sheet is
    /// kept (and the stacked layout applies). Compact width is unaffected.
    @ViewBuilder
    func fittedEntryPanel(playerCount: Int) -> some View {
        if #available(iOS 18, *) {
            frame(
                idealWidth: ScoreEntrySheet.fittedPanelWidth,
                idealHeight: ScoreEntrySheet.fittedPanelHeight(playerCount: playerCount)
            )
            .presentationSizing(.fitted)
        } else {
            self
        }
    }
}

// MARK: - Numpad key style

private struct NumpadKeyStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.09), value: configuration.isPressed)
    }
}

// MARK: - Score input row

private struct ScoreInputRow: View {
    let player: Player
    let colorIndex: Int
    let digits: String
    let isNegative: Bool
    let doubledValue: Int?
    let isFocused: Bool
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var highContrast: Bool { colorSchemeContrast == .increased }

    private var activeBrand: Color {
        highContrast ? Theme.brandHighContrast : Theme.brand
    }

    private var scoreColor: Color {
        guard !digits.isEmpty else { return Color(.tertiaryLabel) }
        return isNegative ? Color(.systemRed) : Color.primary
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.playerColor(at: colorIndex, highContrast: highContrast))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(String(player.trimmedName.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.playerTextColor(at: colorIndex, highContrast: highContrast))
                }
                .accessibilityHidden(true)

            Text(player.trimmedName)
                .font(.system(.body, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)

            if let doubled = doubledValue {
                Text(verbatim: "×2 → \(doubled)")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(Color(.systemOrange))
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    .accessibilityHidden(true)
            }

            HStack(spacing: 1) {
                Text("\u{2212}")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color(.systemRed))
                    .opacity(isNegative ? 1 : 0)
                    .accessibilityHidden(true)

                Text(digits.isEmpty ? "0" : digits)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(scoreColor)
                    .frame(width: 52, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 64)
        .contentShape(Rectangle())
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(activeBrand, lineWidth: 2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
            }
        }
        .onTapGesture { onTap() }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: doubledValue)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.1), value: isFocused)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
        .accessibilityAddTraits(isFocused ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint("Tap to enter score")
    }

    private var rowAccessibilityLabel: String {
        let name = player.trimmedName
        guard !digits.isEmpty, let magnitude = Int(digits) else {
            return String(localized: "\(name), no score")
        }
        let value = isNegative ? -magnitude : magnitude
        var label = String(localized: "\(name), \(value) points")
        if let doubled = doubledValue {
            label += String(localized: ", doubles to \(doubled)")
        }
        return label
    }
}

// MARK: - Skyjo chip

private struct SkyjoChip: View {
    let player: Player
    let colorIndex: Int
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var highContrast: Bool { colorSchemeContrast == .increased }

    private var playerColor: Color {
        Theme.playerColor(at: colorIndex, highContrast: highContrast)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isSelected ? playerColor : Color(.tertiarySystemFill))
                    .frame(width: 22, height: 22)
                    .overlay {
                        Text(String(player.trimmedName.prefix(1)).uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                isSelected
                                    ? Theme.playerTextColor(at: colorIndex, highContrast: highContrast)
                                    : Color(.secondaryLabel)
                            )
                    }
                    .accessibilityHidden(true)
                Text(player.trimmedName)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(isSelected ? playerColor : Color(.label))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? playerColor.opacity(0.1) : Color(.secondarySystemFill))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? playerColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.12), value: isSelected)
        .accessibilityLabel(Text("\(player.trimmedName) ended the round"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
