import XCTest
@testable import SkyjoScorekeeper

final class GameSetupTests: XCTestCase {

    // MARK: - Player

    func testPlayerTrimmingAndValidation() {
        var p = Player(name: "  Dave  ")
        XCTAssertEqual(p.trimmedName, "Dave")
        XCTAssertTrue(p.isValid)

        p.name = "   "
        XCTAssertFalse(p.isValid)

        p.name = ""
        XCTAssertFalse(p.isValid)
    }

    // MARK: - GameState defaults

    func testDefaultStateHasTwoEmptyPlayers() {
        let state = GameState()
        XCTAssertEqual(state.players.count, 2)
        XCTAssertFalse(state.canStart)
    }

    // MARK: - canStart

    func testCanStartRequiresTwoValidNames() {
        let state = GameState()

        state.players[0].name = "Alice"
        XCTAssertFalse(state.canStart, "One name is not enough")

        state.players[1].name = "Bob"
        XCTAssertTrue(state.canStart, "Two names should enable start")
    }

    func testWhitespaceOnlyNameCountsAsInvalid() {
        let state = GameState()
        state.players[0].name = "Alice"
        state.players[1].name = "   "
        XCTAssertFalse(state.canStart)
    }

    // MARK: - Add player

    func testAddPlayerEnforcesMaximum() {
        let state = GameState()
        for _ in 0..<6 { state.addPlayer() }
        XCTAssertEqual(state.players.count, 8)
        XCTAssertFalse(state.canAddPlayer)

        state.addPlayer() // should be ignored
        XCTAssertEqual(state.players.count, 8)
    }

    func testAddedPlayerStartsEmpty() {
        let state = GameState()
        state.addPlayer()
        XCTAssertEqual(state.players.last?.name, "")
    }

    // MARK: - Remove player

    func testRemovePlayerEnforcesMinimum() {
        let state = GameState()
        state.addPlayer()
        XCTAssertEqual(state.players.count, 3)

        state.remove(state.players[0])
        XCTAssertEqual(state.players.count, 2)
        XCTAssertFalse(state.canRemovePlayer)

        let remaining = state.players[0]
        state.remove(remaining) // should be ignored
        XCTAssertEqual(state.players.count, 2)
    }

    // MARK: - committedPlayers

    func testCommittedPlayersTrimWhitespace() {
        let state = GameState()
        state.players[0].name = "  Alice  "
        state.players[1].name = " Bob"

        let committed = state.committedPlayers()
        XCTAssertNotNil(committed)
        XCTAssertEqual(committed?[0].name, "Alice")
        XCTAssertEqual(committed?[1].name, "Bob")
    }

    func testCommittedPlayersReturnsNilWhenCannotStart() {
        let state = GameState()
        XCTAssertNil(state.committedPlayers())
    }

    // MARK: - Play again (pre-populated init)

    func testInitWithPrePopulatedPlayers() {
        let players = [Player(name: "Alice"), Player(name: "Bob"), Player(name: "Carol")]
        let state = GameState(players: players)

        XCTAssertEqual(state.players.count, 3)
        XCTAssertEqual(state.players[0].name, "Alice")
        XCTAssertTrue(state.canStart)
    }
}
