import SwiftUI

enum Theme {
    static let brand = Color(red: 0.216, green: 0.188, blue: 0.639)
    static let contentMaxWidth: CGFloat = 600

    // Okabe-Ito color-blind-safe palette. Each player position gets a unique color.
    private static let playerPalette: [(Color, Color)] = [
        (Color(red: 0.216, green: 0.188, blue: 0.639), .white),    // Indigo (brand)
        (Color(red: 0.902, green: 0.624, blue: 0.000), .white),    // Orange
        (Color(red: 0.000, green: 0.620, blue: 0.451), .white),    // Teal
        (Color(red: 0.835, green: 0.369, blue: 0.000), .white),    // Vermillion
        (Color(red: 0.000, green: 0.447, blue: 0.698), .white),    // Blue
        (Color(red: 0.800, green: 0.475, blue: 0.655), .white),    // Pink-purple
        (Color(red: 0.337, green: 0.706, blue: 0.914), Color(.label)), // Sky blue
        (Color(red: 0.941, green: 0.894, blue: 0.259), Color(.label)), // Yellow
    ]

    static func playerColor(at index: Int) -> Color {
        playerPalette[index % playerPalette.count].0
    }

    static func playerTextColor(at index: Int) -> Color {
        playerPalette[index % playerPalette.count].1
    }
}
