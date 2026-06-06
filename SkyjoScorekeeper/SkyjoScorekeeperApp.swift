import SwiftUI

@main
struct SkyjoScorekeeperApp: App {
    @State private var route: Route

    enum Route {
        case setup(initialPlayers: [Player]?)
        case game(session: GameSession)
    }

    init() {
        if let snapshot = SessionStore.load() {
            let restored = GameSession(snapshot: snapshot)
            // Defensive: never restore into a finished game. A completed
            // game should have cleared its save, but if a stale or
            // hand-edited file slips through, fall back to setup.
            if restored.isGameOver {
                SessionStore.clear()
                _route = State(initialValue: .setup(initialPlayers: nil))
            } else {
                _route = State(initialValue: .game(session: restored))
            }
        } else {
            _route = State(initialValue: .setup(initialPlayers: nil))
        }
    }

    var body: some Scene {
        WindowGroup {
            switch route {
            case .setup(let initialPlayers):
                GameSetupView(initialPlayers: initialPlayers) { players in
                    route = .game(session: GameSession(players: players))
                }
            case .game(let session):
                ScoringView(session: session) { initialPlayers in
                    SessionStore.clear()
                    route = .setup(initialPlayers: initialPlayers)
                }
            }
        }
    }
}
