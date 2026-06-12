import Foundation
import UIKit

@MainActor
class TryOnViewModel: ObservableObject {
    @Published var tryOnResult: UIImage?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var recommendation: FitRecommendation?
    @Published var showTokenAlert = false
    @Published var apiToken: String = ""

    private let api = HuggingFaceAPI()
    private let fitEngine = FitEngine()

    var hasToken: Bool { api.hasToken }

    func generateTryOn(bodyImage: UIImage, clothingImage: UIImage) async {
        isProcessing = true
        errorMessage = nil
        tryOnResult = nil

        do {
            let result = try await api.generateTryOn(bodyImage: bodyImage, clothingImage: clothingImage)
            tryOnResult = result
        } catch let error as HuggingFaceAPI.APIError {
            switch error {
            case .noToken:
                showTokenAlert = true
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    func generateFitRecommendation(profile: BodyProfile, clothing: ClothingItem) {
        recommendation = fitEngine.generateRecommendation(profile: profile, clothing: clothing)
    }

    func saveToken() {
        guard !apiToken.isEmpty else { return }
        api.setToken(apiToken)
        showTokenAlert = false
    }

    func clearResult() {
        tryOnResult = nil
        recommendation = nil
        errorMessage = nil
    }

    func clearError() {
        errorMessage = nil
    }
}
