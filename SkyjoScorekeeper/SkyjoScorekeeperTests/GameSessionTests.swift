import XCTest
@testable import SkyjoScorekeeper

final class GameSessionTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession(names: [String] = ["Alice", "Bob", "Carol"]) -> GameSession {
        GameSession(players: names.map { Player(name: $0) })
    }

    private func commit(_ session: GameSession, scores: [Int], skyjoIndex: Int? = nil) {
        let entries = Dictionary(uniqueKeysWithValues: zip(session.players.map(\.id), scores))
        let skyjoID = skyjoIndex.map { session.players[$0].id }
        session.commitRound(entries: entries, skyjoPlayerID: skyjoID)
    }

    // MARK: - Round number

    func testInitialRoundNumberIsOne() {
        let session = makeSession()
        XCTAssertEqual(session.currentRoundNumber, 1)
    }

    func testRoundNumberIncrementsAfterCommit() {
        let session = makeSession()
        commit(session, scores: [5, 8, 3])
        XCTAssertEqual(session.currentRoundNumber, 2)
        commit(session, scores: [2, 4, 1])
        XCTAssertEqual(session.currentRoundNumber, 3)
    }

    // MARK: - Totals

    func testTotalsAccumulateAcrossRounds() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [5, 10])
        commit(session, scores: [3, 7])
        let standings = session.standings
        let alice = standings.first { $0.player.name == "Alice" }!
        let bob = standings.first { $0.player.name == "Bob" }!
        XCTAssertEqual(alice.total, 8)
        XCTAssertEqual(bob.total, 17)
    }

    func testNegativeScoresApply() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [-5, 10])
        let alice = session.standings.first { $0.player.name == "Alice" }!
        XCTAssertEqual(alice.total, -5)
    }

    // MARK: - Doubling rule

    func testSkyjoPlayerDoubledWhenNotLowest() {
        // Alice calls Skyjo with 8, Bob has 5 (lower). Alice's score should double to 16.
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [8, 5], skyjoIndex: 0)
        let alice = session.standings.first { $0.player.name == "Alice" }!
        XCTAssertEqual(alice.total, 16)
    }

    func testSkyjoPlayerNotDoubledWhenIsLowest() {
        // Alice calls Skyjo with 3, Bob has 8 (higher). Alice has minimum — no doubling.
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [3, 8], skyjoIndex: 0)
        let alice = session.standings.first { $0.player.name == "Alice" }!
        XCTAssertEqual(alice.total, 3)
    }

    func testSkyjoPlayerNotDoubledWhenTiedForLowest() {
        // Alice and Bob both score 5. Alice calls Skyjo — tied for minimum, no doubling.
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [5, 5], skyjoIndex: 0)
        let alice = session.standings.first { $0.player.name == "Alice" }!
        XCTAssertEqual(alice.total, 5)
    }

    func testNoDoublingWhenSkyjoPlayerIsNil() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [8, 5], skyjoIndex: nil)
        let alice = session.standings.first { $0.player.name == "Alice" }!
        XCTAssertEqual(alice.total, 8)
    }

    func testDoublingOnlyAffectsSkyjoPlayer() {
        // Only Alice is doubled; Bob's score is unchanged.
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [8, 5], skyjoIndex: 0)
        let bob = session.standings.first { $0.player.name == "Bob" }!
        XCTAssertEqual(bob.total, 5)
    }

    // MARK: - Standings order

    func testStandingsSortedAscending() {
        let session = makeSession(names: ["Alice", "Bob", "Carol"])
        commit(session, scores: [15, 5, 10])
        let totals = session.standings.map(\.total)
        XCTAssertEqual(totals, totals.sorted())
    }

    func testLeaderIsPlayerWithLowestTotal() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [10, 5])
        let bob = session.standings.first { $0.player.name == "Bob" }!
        let alice = session.standings.first { $0.player.name == "Alice" }!
        XCTAssertTrue(bob.isLeader)
        XCTAssertFalse(alice.isLeader)
    }

    func testAllPlayersMarkedLeaderWhenTied() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [7, 7])
        XCTAssertTrue(session.standings.allSatisfy(\.isLeader))
    }

    func testNoRoundsEveryoneIsLeader() {
        let session = makeSession(names: ["Alice", "Bob"])
        // All totals are 0 — minimum is 0, so everyone is a leader
        XCTAssertTrue(session.standings.allSatisfy(\.isLeader))
    }

    // MARK: - isGameOver

    func testGameNotOverBelowThreshold() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [40, 50])
        XCTAssertFalse(session.isGameOver)
    }

    func testGameOverAtExactlyOneHundred() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [60, 30])
        commit(session, scores: [40, 10])
        let alice = session.standings.first { $0.player.name == "Alice" }!
        XCTAssertEqual(alice.total, 100)
        XCTAssertTrue(session.isGameOver)
    }

    func testGameOverAboveOneHundred() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [110, 20])
        XCTAssertTrue(session.isGameOver)
    }

    func testGameOverWhenAnyPlayerCrossesThreshold() {
        // Bob crosses 100; Alice is still low. Game is still over.
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [5, 110])
        XCTAssertTrue(session.isGameOver)
    }

    // MARK: - Winners

    func testSingleWinner() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [5, 110])
        XCTAssertEqual(session.winners.count, 1)
        XCTAssertEqual(session.winners[0].name, "Alice")
    }

    func testTiebreakerByFinalRoundScore() {
        // Alice and Bob tied at 20 total. Last round: Alice 8, Bob 12. Alice wins tiebreaker.
        let session = makeSession(names: ["Alice", "Bob", "Carol"])
        commit(session, scores: [12, 8, 5])
        commit(session, scores: [8, 12, 95])
        // Carol crosses 100. Alice and Bob tied at 20.
        XCTAssertTrue(session.isGameOver)
        let winners = session.winners
        XCTAssertEqual(winners.count, 1)
        XCTAssertEqual(winners[0].name, "Alice", "Alice had lower last-round score (8 vs 12)")
    }

    func testTiedWinnersWhenLastRoundAlsoTied() {
        let session = makeSession(names: ["Alice", "Bob", "Carol"])
        commit(session, scores: [10, 10, 5])
        commit(session, scores: [10, 10, 95])
        // Carol crosses 100. Alice and Bob tied at 20, same last-round score (10).
        XCTAssertTrue(session.isGameOver)
        let winners = session.winners
        XCTAssertEqual(winners.count, 2)
        XCTAssertTrue(winners.contains { $0.name == "Alice" })
        XCTAssertTrue(winners.contains { $0.name == "Bob" })
    }

    func testWinnersEmptyWhenGameNotOver() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [5, 10])
        XCTAssertTrue(session.winners.isEmpty)
    }

    // MARK: - Undo

    func testUndoRemovesLastRound() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [10, 20])
        commit(session, scores: [5, 15])
        session.undoLastRound()
        XCTAssertEqual(session.rounds.count, 1)
        XCTAssertEqual(session.currentRoundNumber, 2)
    }

    func testUndoRestoresTotals() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [10, 20])
        commit(session, scores: [5, 15])
        session.undoLastRound()
        let alice = session.standings.first { $0.player.name == "Alice" }!
        XCTAssertEqual(alice.total, 10)
    }

    func testUndoOnEmptyRoundsIsNoOp() {
        let session = makeSession(names: ["Alice", "Bob"])
        session.undoLastRound()
        XCTAssertEqual(session.rounds.count, 0)
    }

    func testUndoCanReverseGameOver() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [5, 110])
        XCTAssertTrue(session.isGameOver)
        session.undoLastRound()
        XCTAssertFalse(session.isGameOver)
    }

    // MARK: - lastRoundScore

    func testLastRoundScoreReflectsMostRecentAppliedScore() {
        let session = makeSession(names: ["Alice", "Bob"])
        commit(session, scores: [5, 20])
        commit(session, scores: [8, 5], skyjoIndex: 0)
        // Alice called Skyjo with 8, Bob has 5 — Alice gets doubled to 16
        let alice = session.standings.first { $0.player.name == "Alice" }!
        XCTAssertEqual(alice.lastRoundScore, 16)
    }

    func testLastRoundScoreIsNilBeforeFirstRound() {
        let session = makeSession(names: ["Alice", "Bob"])
        XCTAssertNil(session.standings.first?.lastRoundScore)
    }
}
