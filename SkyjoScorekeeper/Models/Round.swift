import Foundation

struct Round: Codable {
    let number: Int
    let scores: [RoundScore]
    let skyjoPlayerID: UUID?
}
