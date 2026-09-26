import SwiftUI

struct ScoringView: View {
    @StateObject private var session: GameSession
    let onNewGame: ([Player]?) -> Void

    @State private var showEntrySheet = false
    @State private var showEndGameAlert = false

    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var activeBrand: Color {
        colorSchemeContrast == .increased ? Theme.brandHighContrast : Theme.brand
    }

    init(session: GameSession, onNewGame: @escaping ([Player]?) -> Void) {
        _session = StateObject(wrappedValue: session)
        self.onNewGame = onNewGame
    }

    // Presentation follows the shared session, so every open window agrees:
    // when the game ends in one window, each window closes its entry sheet
    // and shows the result.
    private var entrySheetPresented: Binding<Bool> {
        Binding(
            get: { showEntrySheet && !session.isGameOver },
            set: { showEntrySheet = $0 }
        )
    }

    private var winViewPresented: Binding<Bool> {
        Binding(get: { session.isGameOver }, set: { _ in })
    }

    var body: some View {
        // A local stack whose only job is to host the system toolbar. Root
        // navigation stays the Route enum in SkyjoScorekeeperApp; nothing is pushed.
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 10) {
                        standingsCard
                        Text("Game ends when someone reaches 100. Lowest total wins.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    .frame(maxWidth: Theme.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                }
                enterButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .frame(maxWidth: Theme.contentMaxWidth)
                    .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Round \(session.currentRoundNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .tint(activeBrand)
        }
        .sheet(isPresented: entrySheetPresented) {
            ScoreEntrySheet(session: session) { entries, skyjoPlayerID in
                session.commitRound(entries: entries, skyjoPlayerID: skyjoPlayerID)
                showEntrySheet = false
                if !session.isGameOver, let leader = session.standings.first {
                    AccessibilityNotification.Announcement(
                        String(localized: "Round recorded. \(leader.player.trimmedName) leads with \(leader.total).")
                    ).post()
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .fittedEntryPanel(playerCount: session.players.count)
        }
        .fullScreenCover(isPresented: winViewPresented) {
            WinView(session: session, onNewGame: onNewGame)
        }
        .alert("End Game?", isPresented: $showEndGameAlert) {
            Button("End Game", role: .destructive) { onNewGame(nil) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current scores will be lost.")
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                showEndGameAlert = true
            } label: {
                toolbarLabel("End Game", systemImage: "xmark")
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                session.undoLastRound()
                AccessibilityNotification.Announcement(
                    String(localized: "Last round removed.")
                ).post()
            } label: {
                toolbarLabel("Undo", systemImage: "arrow.uturn.backward")
            }
            .disabled(session.rounds.isEmpty)
            .accessibilityHint("Removes the most recent round's scores")
        }
    }

    /// Title and symbol, both visible. The toolbar collapses a plain `Label` to
    /// its icon (even with `.titleAndIcon`), so the pair is composed by hand.
    /// No fixed width: the system sizes the glass capsule to the words, so long
    /// languages never truncate. The title is the VoiceOver label.
    private func toolbarLabel(_ title: LocalizedStringKey, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .accessibilityHidden(true)
            Text(title)
        }
        .fontDesign(.rounded)
    }

    // MARK: - Standings

    private var standingsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STANDINGS")
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)
                .accessibilityAddTraits(.isHeader)

            let standings = session.standings
            VStack(spacing: 0) {
                ForEach(Array(standings.enumerated()), id: \.element.player.id) { index, standing in
                    StandingRowView(
                        standing: standing,
                        colorIndex: colorIndex(for: standing.player),
                        showLeaderIndicator: !session.rounds.isEmpty
                    )
                    if index < standings.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        }
    }

    // MARK: - Enter button

    private var enterButton: some View {
        Button { showEntrySheet = true } label: {
            Label("Enter Round \(session.currentRoundNumber) Scores", systemImage: "chevron.up")
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 58)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: true))
    }

    private func colorIndex(for player: Player) -> Int {
        session.players.firstIndex(where: { $0.id == player.id }) ?? 0
    }
}

// MARK: - Standing row

private struct StandingRowView: View {
    let standing: PlayerStanding
    let colorIndex: Int
    let showLeaderIndicator: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var highContrast: Bool { colorSchemeContrast == .increased }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.playerColor(at: colorIndex, highContrast: highContrast))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(String(standing.player.trimmedName.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.playerTextColor(at: colorIndex, highContrast: highContrast))
                }

            Text(standing.player.trimmedName)
                .font(.system(.body, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            if showLeaderIndicator {
                Image(systemName: "crown.fill")
                    .font(.system(.caption2))
                    .foregroundStyle(Color(.systemGreen))
                    .opacity(standing.isLeader ? 1 : 0)
                    .accessibilityHidden(true)
            }

            Text("\(standing.total)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(totalColor)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 62)
        .background(
            showLeaderIndicator && standing.isLeader
                ? Color(.systemGreen).opacity(0.07)
                : Color.clear
        )
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: standing.isLeader)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
    }

    private var scoreStatus: GameSession.ScoreStatus {
        GameSession.scoreStatus(for: standing.total)
    }

    private var totalColor: Color {
        switch scoreStatus {
        case .bust: return Color(.systemRed)
        case .approaching: return Color(.systemOrange)
        case .normal: return Color.primary
        }
    }

    private var rowAccessibilityLabel: String {
        let base = String(localized: "\(standing.player.trimmedName), \(standing.total) points")
        let leader = standing.isLeader && showLeaderIndicator ? String(localized: ", currently leading") : ""
        let status: String
        switch scoreStatus {
        case .bust: status = String(localized: ", over one hundred")
        case .approaching: status = String(localized: ", nearing one hundred")
        case .normal: status = ""
        }
        return base + leader + status
    }
}
