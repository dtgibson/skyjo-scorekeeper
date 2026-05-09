import Foundation

struct Player: Identifiable, Equatable {
    var id = UUID()
    var name = ""

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    var isValid: Bool {
        !trimmedName.isEmpty
    }
}
