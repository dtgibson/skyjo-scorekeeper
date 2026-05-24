import XCTest
@testable import SkyjoScorekeeper

final class SessionPersistenceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SessionStore.clear()
    }

    override func tearDown() {
        SessionStore.clear()
        super.tearDown()
    }

    // MARK: - SessionStore

    func testLoadReturnsNilWhenEmpty() {
        XCTAssertNil(SessionStore.load())
    }

    func testSaveAndLoad() {
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        let snapshot = GameSessionSnapshot(players: players, rounds: [])
        SessionStore.save(snapshot)

        let loaded = SessionStore.load()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.players.map(\.name), ["Alice", "Bob"])
        XCTAssertEqual(loaded?.rounds.count, 0)
    }

    func testClearRemovesSavedState() {
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        SessionStore.save(GameSessionSnapshot(players: players, rounds: []))
        SessionStore.clear()
        XCTAssertNil(SessionStore.load())
    }

    func testLoadReturnsNilForCorruptData() throws {
        guard let url = SessionStore.fileURL else { return }
        let dir = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try "not valid json {{{{".write(to: url, atomically: true, encoding: .utf8)
        XCTAssertNil(SessionStore.load())
    }

    func testSavePreservesAllFields() {
        let p1 = Player(name: "Alice")
        let p2 = Player(name: "Bob")
        let score1 = RoundScore(playerID: p1.id, raw: 7, applied: 7)
        let score2 = RoundScore(playerID: p2.id, raw: -2, applied: -2)
        let round = Round(number: 1, scores: [score1, score2], skyjoPlayerID: p1.id)
        let snapshot = GameSessionSnapshot(players: [p1, p2], rounds: [round])
        SessionStore.save(snapshot)

        let loaded = SessionStore.load()
        XCTAssertEqual(loaded?.rounds.count, 1)
        XCTAssertEqual(loaded?.rounds.first?.skyjoPlayerID, p1.id)
        XCTAssertEqual(loaded?.rounds.first?.scores.first?.applied, 7)
        XCTAssertEqual(loaded?.rounds.first?.scores.last?.applied, -2)
    }

    // MARK: - GameSession integration

    func testNewGameClearsSavedState() {
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        let session = GameSession(players: players)
        session.commitRound(
            entries: [players[0].id: 5, players[1].id: 10],
            skyjoPlayerID: nil
        )
        XCTAssertNotNil(SessionStore.load())

        _ = GameSession(players: players)
        XCTAssertNil(SessionStore.load())
    }

    func testCommitRoundSavesState() {
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        let session = GameSession(players: players)
        session.commitRound(
            entries: [players[0].id: 5, players[1].id: 10],
            skyjoPlayerID: nil
        )

        let loaded = SessionStore.load()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.rounds.count, 1)
        XCTAssertEqual(loaded?.players.map(\.name), ["Alice", "Bob"])
    }

    func testUndoSavesUpdatedState() {
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        let session = GameSession(players: players)
        session.commitRound(
            entries: [players[0].id: 5, players[1].id: 10],
            skyjoPlayerID: nil
        )
        session.undoLastRound()

        let loaded = SessionStore.load()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.rounds.count, 0)
    }

    func testGameOverClearsSavedState() {
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        let session = GameSession(players: players)
        session.commitRound(
            entries: [players[0].id: 60, players[1].id: 5],
            skyjoPlayerID: nil
        )
        session.commitRound(
            entries: [players[0].id: 45, players[1].id: 5],
            skyjoPlayerID: nil
        )
        XCTAssertTrue(session.isGameOver)
        XCTAssertNil(SessionStore.load())
    }

    func testRestoreInitReproducesSession() {
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        let original = GameSession(players: players)
        original.commitRound(
            entries: [players[0].id: 10, players[1].id: 5],
            skyjoPlayerID: nil
        )
        original.commitRound(
            entries: [players[0].id: 3, players[1].id: 8],
            skyjoPlayerID: nil
        )

        guard let loaded = SessionStore.load() else {
            XCTFail("Expected saved state")
            return
        }
        let restored = GameSession(snapshot: loaded)

        XCTAssertEqual(restored.players.map(\.name), original.players.map(\.name))
        XCTAssertEqual(restored.players.map(\.id), original.players.map(\.id))
        XCTAssertEqual(restored.rounds.count, original.rounds.count)
        XCTAssertEqual(restored.currentRoundNumber, original.currentRoundNumber)
        XCTAssertEqual(
            restored.standings.map(\.total),
            original.standings.map(\.total)
        )
    }

    func testRestoreInitDoesNotClearSavedState() {
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        let session = GameSession(players: players)
        session.commitRound(
            entries: [players[0].id: 5, players[1].id: 10],
            skyjoPlayerID: nil
        )

        let snapshot = session.snapshot
        _ = GameSession(snapshot: snapshot)
        XCTAssertNotNil(SessionStore.load(), "Restore init must not clear saved state")
    }

    func testSnapshotRoundtrip() {
        let players = [Player(name: "Alice"), Player(name: "Bob")]
        let session = GameSession(players: players)
        session.commitRound(
            entries: [players[0].id: 7, players[1].id: -2],
            skyjoPlayerID: nil
        )

        let snap = session.snapshot
        XCTAssertEqual(snap.players.count, 2)
        XCTAssertEqual(snap.rounds.count, 1)
        XCTAssertEqual(snap.rounds.first?.scores.count, 2)
    }
}
