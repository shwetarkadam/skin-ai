import SwiftUI

struct AnimatedCard<Content: View>: View {
    let content: Content
    @State private var isAppeared = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppConstants.padding)
            .glassCard()
            .opacity(isAppeared ? 1 : 0)
            .offset(y: isAppeared ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: AppConstants.animationDuration).delay(0.1)) {
                    isAppeared = true
                }
            }
    }
}

struct MeasurementInput: View {
    let label: String
    let unit: String
    let icon: String
    @Binding var value: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppColors.accentGradient)
                .frame(width: 36, height: 36)
                .background(AppColors.surfaceGlass)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(AppColors.textMuted)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(AppColors.textMuted.opacity(0.6))
            }
            .frame(width: 80, alignment: .leading)

            TextField(placeholder, text: $value)
                .keyboardType(.decimalPad)
                .font(.title3.weight(.semibold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.trailing)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppColors.surfaceGlass)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.vertical, 4)
    }
}

struct ShapeVisualizer: View {
    let shape: BodyShape
    let confidence: Double
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.accentTeal.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 120
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)

                // Shape icon
                Text(shape.icon)
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            }

            VStack(spacing: 8) {
                Text(shape.rawValue)
                    .font(.title.weight(.bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("\(Int(confidence * 100))% confidence")
                    .font(.subheadline)
                    .foregroundColor(AppColors.accentTeal)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(AppColors.accentTeal.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .onAppear { isAnimating = true }
    }
}
