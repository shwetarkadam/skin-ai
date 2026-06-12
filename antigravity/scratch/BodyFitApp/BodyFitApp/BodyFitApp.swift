import SwiftUI

@main
struct BodyFitApp: App {
    @StateObject private var onboardingVM = OnboardingViewModel()
    @StateObject private var bodyAnalysisVM = BodyAnalysisViewModel()
    @StateObject private var clothingVM = ClothingViewModel()
    @StateObject private var tryOnVM = TryOnViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(onboardingVM)
                .environmentObject(bodyAnalysisVM)
                .environmentObject(clothingVM)
                .environmentObject(tryOnVM)
        }
    }
}
