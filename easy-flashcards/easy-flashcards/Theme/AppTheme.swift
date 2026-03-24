import SwiftUI

enum AppTheme {

    // MARK: - Colors

    static let background = Color(hex: "13132B")
    static let cardBackground = Color(hex: "1E1E3F")
    static let accent = Color(hex: "7C6CF7")
    static let accentDark = Color(hex: "6B5CE6")
    static let splashBackground = Color(red: 116 / 255, green: 103 / 255, blue: 233 / 255)
    static let sheetBackground = Color(hex: "4D2141").opacity(0.85)
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "9090A7")

    // MARK: - Corner Radius

    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusMedium: CGFloat = 16

    // MARK: - Spacing

    static let spacingSmall: CGFloat = 8
    static let spacingMedium: CGFloat = 16
    static let spacingLarge: CGFloat = 24

    // MARK: - Gradient

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentDark],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6:
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

struct DarkFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
            .foregroundStyle(AppTheme.textPrimary)
            .tint(AppTheme.accent)
    }
}

extension View {
    func darkFieldStyle() -> some View {
        modifier(DarkFieldModifier())
    }
}
