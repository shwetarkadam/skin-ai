import SwiftUI

struct ContentView: View {
    @EnvironmentObject var onboardingVM: OnboardingViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
