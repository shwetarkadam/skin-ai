import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @State private var showQuestionnaire = false
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateButton = false
    @State private var animateOrbs = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.backgroundGradient
                    .ignoresSafeArea()

                // Floating orbs
                floatingOrbs

                VStack(spacing: 40) {
                    Spacer()

                    // App icon
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AppColors.accentTeal.opacity(0.4), .clear],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(animateOrbs ? 1.1 : 0.9)

                        Image(systemName: "figure.dress.line.vertical.figure")
                            .font(.system(size: 60, weight: .light))
                            .foregroundStyle(AppColors.accentGradient)
                    }

                    // Title
                    VStack(spacing: 12) {
                        Text("BodyFit")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .opacity(animateTitle ? 1 : 0)
                            .offset(y: animateTitle ? 0 : 20)

                        Text("Discover your perfect fit")
                            .font(.title3)
                            .foregroundColor(AppColors.textSecondary)
                            .opacity(animateSubtitle ? 1 : 0)
                            .offset(y: animateSubtitle ? 0 : 15)
                    }

                    // Features list
                    VStack(spacing: 16) {
                        featureRow(icon: "wand.and.stars", text: "AI-powered body shape analysis")
                        featureRow(icon: "tshirt.fill", text: "Virtual try-on visualization")
                        featureRow(icon: "sparkles", text: "Personalized fit recommendations")
                    }
                    .opacity(animateSubtitle ? 1 : 0)

                    Spacer()

                    // CTA Button
                    NavigationLink(destination: QuestionnaireView()) {
                        HStack {
                            Text("Get Started")
                            Image(systemName: "arrow.right")
                        }
                        .primaryButton()
                    }
                    .opacity(animateButton ? 1 : 0)
                    .offset(y: animateButton ? 0 : 30)
                    .padding(.horizontal, AppConstants.padding)
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) { animateTitle = true }
                withAnimation(.easeOut(duration: 0.6).delay(0.4)) { animateSubtitle = true }
                withAnimation(.easeOut(duration: 0.6).delay(0.8)) { animateButton = true }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { animateOrbs = true }
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppColors.accentGradient)
                .frame(width: 40, height: 40)
                .background(AppColors.surfaceGlass)
                .clipShape(Circle())
            Text(text)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var floatingOrbs: some View {
        ZStack {
            Circle()
                .fill(AppColors.accentTeal.opacity(0.08))
                .frame(width: 200, height: 200)
                .offset(x: -100, y: -200)
                .blur(radius: 40)
                .scaleEffect(animateOrbs ? 1.2 : 0.8)

            Circle()
                .fill(AppColors.accentPink.opacity(0.06))
                .frame(width: 150, height: 150)
                .offset(x: 120, y: 150)
                .blur(radius: 30)
                .scaleEffect(animateOrbs ? 0.8 : 1.2)

            Circle()
                .fill(AppColors.primaryGradientStart.opacity(0.1))
                .frame(width: 100, height: 100)
                .offset(x: 80, y: -300)
                .blur(radius: 20)
                .scaleEffect(animateOrbs ? 1.1 : 0.9)
        }
        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateOrbs)
    }
}
