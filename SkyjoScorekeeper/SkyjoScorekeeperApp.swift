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
            _route = State(initialValue: .game(session: GameSession(snapshot: snapshot)))
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
