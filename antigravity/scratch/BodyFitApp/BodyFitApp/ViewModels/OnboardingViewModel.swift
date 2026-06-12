import Foundation
import SwiftUI
import UIKit

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .basicInfo
    @Published var profile = BodyProfile()
    @Published var isComplete = false

    // Step 1: Basic Info
    @Published var heightText: String = ""
    @Published var weightText: String = ""
    @Published var ageText: String = "25"

    // Step 2: Measurements
    @Published var bustText: String = ""
    @Published var waistText: String = ""
    @Published var hipText: String = ""
    @Published var shoulderText: String = ""

    // Step 3: Concerns
    @Published var selectedConcerns: Set<BodyConcern> = []

    // Step 4: Fit Preference
    @Published var fitPreference: FitPreference = .balanced

    // Step 5: Problem Areas
    @Published var selectedProblemAreas: Set<ProblemArea> = []

    enum OnboardingStep: Int, CaseIterable {
        case basicInfo = 0
        case measurements = 1
        case concerns = 2
        case fitPreference = 3
        case problemAreas = 4

        var title: String {
            switch self {
            case .basicInfo: return "About You"
            case .measurements: return "Your Measurements"
            case .concerns: return "Body Concerns"
            case .fitPreference: return "Fit Preference"
            case .problemAreas: return "Problem Areas"
            }
        }

        var subtitle: String {
            switch self {
            case .basicInfo: return "Let's start with the basics"
            case .measurements: return "These help us map your body shape"
            case .concerns: return "Select areas you're conscious about"
            case .fitPreference: return "How do you like your clothes to fit?"
            case .problemAreas: return "Where do clothes typically not fit well?"
            }
        }

        var icon: String {
            switch self {
            case .basicInfo: return "person.fill"
            case .measurements: return "ruler.fill"
            case .concerns: return "heart.text.square.fill"
            case .fitPreference: return "tshirt.fill"
            case .problemAreas: return "exclamationmark.triangle.fill"
            }
        }
    }

    var progress: Double {
        Double(currentStep.rawValue + 1) / Double(OnboardingStep.allCases.count)
    }

    var canProceed: Bool {
        switch currentStep {
        case .basicInfo:
            return !heightText.isEmpty && !weightText.isEmpty
        case .measurements:
            return !bustText.isEmpty && !waistText.isEmpty && !hipText.isEmpty
        case .concerns:
            return true // Optional
        case .fitPreference:
            return true // Always has a default
        case .problemAreas:
            return true // Optional
        }
    }

    func nextStep() {
        let allSteps = OnboardingStep.allCases
        guard let currentIndex = allSteps.firstIndex(of: currentStep),
              currentIndex < allSteps.count - 1 else {
            completeOnboarding()
            return
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = allSteps[currentIndex + 1]
        }
    }

    func previousStep() {
        let allSteps = OnboardingStep.allCases
        guard let currentIndex = allSteps.firstIndex(of: currentStep),
              currentIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = allSteps[currentIndex - 1]
        }
    }

    func completeOnboarding() {
        profile.height = Double(heightText) ?? 0
        profile.weight = Double(weightText) ?? 0
        profile.age = Int(ageText) ?? 25
        profile.bustCircumference = Double(bustText) ?? 0
        profile.waistCircumference = Double(waistText) ?? 0
        profile.hipCircumference = Double(hipText) ?? 0
        profile.shoulderWidth = Double(shoulderText) ?? 0
        profile.concerns = Array(selectedConcerns)
        profile.fitPreference = fitPreference
        profile.problemAreas = Array(selectedProblemAreas)

        // Classify shape
        let classifier = ShapeClassifier()
        let result = classifier.classify(profile: profile)
        profile.detectedShape = result.shape
        profile.shapeConfidence = result.confidence

        profile.save()
        isComplete = true
    }

    func toggleConcern(_ concern: BodyConcern) {
        if selectedConcerns.contains(concern) {
            selectedConcerns.remove(concern)
        } else {
            selectedConcerns.insert(concern)
        }
    }

    func toggleProblemArea(_ area: ProblemArea) {
        if selectedProblemAreas.contains(area) {
            selectedProblemAreas.remove(area)
        } else {
            selectedProblemAreas.insert(area)
        }
    }
}
