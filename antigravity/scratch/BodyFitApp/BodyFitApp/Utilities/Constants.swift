import SwiftUI

enum AppColors {
    // Softer navy-to-slate background (less purple)
    static let primaryGradientStart = Color(red: 0.12, green: 0.14, blue: 0.28)
    static let primaryGradientEnd = Color(red: 0.08, green: 0.10, blue: 0.18)
    // Warm coral primary accent; soft mint secondary
    static let accentTeal = Color(red: 0.25, green: 0.82, blue: 0.78)
    static let accentPink = Color(red: 0.98, green: 0.45, blue: 0.42)
    static let surfaceDark = Color(red: 0.06, green: 0.07, blue: 0.12)
    static let surfaceCard = Color(red: 0.10, green: 0.11, blue: 0.18)
    static let surfaceGlass = Color.white.opacity(0.06)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.78)
    static let textMuted = Color.white.opacity(0.45)
    static let success = Color(red: 0.35, green: 0.82, blue: 0.55)
    static let warning = Color(red: 1.0, green: 0.72, blue: 0.35)
    static let danger = Color(red: 0.95, green: 0.35, blue: 0.38)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [primaryGradientStart, primaryGradientEnd, surfaceDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [surfaceGlass, Color.white.opacity(0.03)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentTeal, accentPink],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

enum AppConstants {
    static let cornerRadius: CGFloat = 20
    static let cardCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 14
    static let padding: CGFloat = 20
    static let smallPadding: CGFloat = 12
    static let animationDuration: Double = 0.4
    static let huggingFaceBaseURL = "https://api-inference.huggingface.co/models"
    static let tryOnModel = "yisol/IDM-VTON"
}
