import Foundation

struct Player: Identifiable, Equatable, Codable {
    var id = UUID()
    var name = ""

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    var isValid: Bool {
        !trimmedName.isEmpty
    }
}
