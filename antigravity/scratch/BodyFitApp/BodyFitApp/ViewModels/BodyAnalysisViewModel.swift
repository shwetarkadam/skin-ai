import Foundation
import UIKit

@MainActor
class BodyAnalysisViewModel: ObservableObject {
    @Published var bodyImage: UIImage?
    @Published var isAnalyzing = false
    @Published var analysisError: String?
    @Published var proportions: VisionAnalyzer.BodyProportions?
    @Published var segmentedImage: UIImage?

    private let visionAnalyzer = VisionAnalyzer()
    private let classifier = ShapeClassifier()

    func analyzePhoto() async {
        guard let image = bodyImage else { return }
        isAnalyzing = true
        analysisError = nil

        do {
            // Detect body pose and extract proportions
            let bodyProportions = try await visionAnalyzer.analyzeBodyPose(from: image)
            proportions = bodyProportions

            // Generate body segmentation
            let mask = try await visionAnalyzer.generateBodySegmentation(from: image)
            segmentedImage = mask

        } catch {
            analysisError = error.localizedDescription
        }

        isAnalyzing = false
    }

    func refineClassification(profile: inout BodyProfile) {
        let result = classifier.classify(profile: profile, visionProportions: proportions)
        profile.detectedShape = result.shape
        profile.shapeConfidence = result.confidence

        if let proportions = proportions {
            profile.visionPoseSource = proportions.analysisSource.displayName
            profile.visionShoulderToHipRatio = proportions.shoulderToHipRatio
            profile.visionWaistToHipRatio = proportions.waistToHipRatio
            profile.visionBustToHipRatio = proportions.bustToHipRatio > 0 ? proportions.bustToHipRatio : nil
            profile.visionBodyHeightMeters = proportions.bodyHeightMeters
            profile.visionShoulderRatio = proportions.shoulderWidth
            profile.visionWaistRatio = proportions.waistWidth
            profile.visionHipRatio = proportions.hipWidth
        }

        profile.save()
    }

    func saveBodyPhoto(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent("body_photo.jpg")
        do {
            try data.write(to: filePath)
            return filePath.path
        } catch {
            return nil
        }
    }
}
