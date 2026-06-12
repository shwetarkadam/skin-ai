import SwiftUI

// MARK: - View Extensions
extension View {
    func glassCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                    .fill(AppColors.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }

    func primaryButton() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColors.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.buttonCornerRadius))
            .shadow(color: AppColors.accentTeal.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    func secondaryButton() -> some View {
        self
            .font(.headline)
            .foregroundColor(AppColors.accentTeal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.buttonCornerRadius)
                    .stroke(AppColors.accentTeal, lineWidth: 1.5)
            )
    }

    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: phase * geo.size.width * 1.6 - geo.size.width * 0.3)
                    }
                )
                .clipped()
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Double Extensions
extension Double {
    var inchesToCm: Double { self * 2.54 }
    var cmToInches: Double { self / 2.54 }

    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
