import SwiftUI

@main
struct SkyjoScorekeeperApp: App {
    @State private var route: Route = .setup(initialPlayers: nil)

    enum Route {
        case setup(initialPlayers: [Player]?)
        case game(players: [Player])
    }

    var body: some Scene {
        WindowGroup {
            switch route {
            case .setup(let initialPlayers):
                GameSetupView(initialPlayers: initialPlayers) { players in
                    route = .game(players: players)
                }
            case .game(let players):
                ScoringView(players: players) { initialPlayers in
                    route = .setup(initialPlayers: initialPlayers)
                }
            }
        }
    }
}
