import SwiftUI

enum Theme {
    static let brand = Color(red: 0.216, green: 0.188, blue: 0.639)
    static let brandHighContrast = Color(red: 0.1647, green: 0.1412, blue: 0.4588)
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

    // Higher-contrast variants meeting WCAG AA (4.5:1) against white text.
    // Sky blue and yellow switch from dark text to white text in high-contrast mode.
    private static let playerPaletteHighContrast: [(Color, Color)] = [
        (Color(red: 0.1647, green: 0.1412, blue: 0.4588), .white), // Indigo HC   ~11:1
        (Color(red: 0.5412, green: 0.3843, blue: 0.000),  .white), // Orange HC   ~5.5:1
        (Color(red: 0.000,  green: 0.4784, blue: 0.3490), .white), // Teal HC     ~5.4:1
        (Color(red: 0.6902, green: 0.2941, blue: 0.000),  .white), // Vermillion HC ~5.4:1
        (Color(red: 0.000,  green: 0.3529, blue: 0.5569), .white), // Blue HC     ~7.4:1
        (Color(red: 0.6275, green: 0.3255, blue: 0.4941), .white), // Pink-purple HC ~5.2:1
        (Color(red: 0.1255, green: 0.4157, blue: 0.6196), .white), // Sky blue HC ~5.8:1
        (Color(red: 0.4784, green: 0.4392, blue: 0.000),  .white), // Yellow HC   ~5.1:1
    ]

    static func playerColor(at index: Int, highContrast: Bool = false) -> Color {
        let palette = highContrast ? playerPaletteHighContrast : playerPalette
        return palette[index % palette.count].0
    }

    static func playerTextColor(at index: Int, highContrast: Bool = false) -> Color {
        let palette = highContrast ? playerPaletteHighContrast : playerPalette
        return palette[index % palette.count].1
    }
}
