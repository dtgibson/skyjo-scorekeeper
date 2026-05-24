import Foundation

struct RoundScore: Codable {
    let playerID: UUID
    let raw: Int
    let applied: Int
}
