import Foundation
import simd
import Vision
import UIKit

class VisionAnalyzer {
    /// On-device proportions for ratio-based body shape (research: shoulder/hip/waist spans; units cancel in ratios).
    struct BodyProportions {
        var shoulderWidth: Double = 0
        var hipWidth: Double = 0
        /// Lateral span at ~natural waist via interpolated left/right torso points (not average of shoulder & hip).
        var waistWidth: Double = 0
        /// Upper-torso proxy for bust-to-hip style ratios when only pose is available (≈ shoulder span).
        var bustProxyWidth: Double = 0
        var torsoHeight: Double = 0
        var shoulderToHipRatio: Double = 0
        var waistToHipRatio: Double = 0
        var bustToHipRatio: Double = 0
        var confidence: Double = 0
        /// Apple Vision 3D pose in meters when available (iOS 17+), else 2D normalized image spans.
        var analysisSource: AnalysisSource = .twoD
        /// Estimated body height from 3D pose when available (meters).
        var bodyHeightMeters: Double?

        enum AnalysisSource {
            case twoD
            case threeD

            var displayName: String {
                switch self {
                case .twoD: return "Apple Vision · 2D pose"
                case .threeD: return "Apple Vision · 3D pose (meters)"
                }
            }
        }

        /// Legacy field used by persisted profile keys; same as `waistWidth`.
        var waistEstimate: Double { waistWidth }
    }

    func analyzeBodyPose(from image: UIImage) async throws -> BodyProportions {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }

        if let from3D = try? await analyzeBodyPose3D(cgImage: cgImage), from3D.isValidForClassification {
            return from3D
        }

        return try await analyzeBodyPose2D(cgImage: cgImage)
    }

    private func analyzeBodyPose3D(cgImage: CGImage) async throws -> BodyProportions {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanBodyPose3DRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observation = (request.results as? [VNHumanBodyPose3DObservation])?.first else {
                    continuation.resume(throwing: VisionError.noBodyDetected)
                    return
                }

                do {
                    let proportions = try self.extractProportions3D(from: observation)
                    continuation.resume(returning: proportions)
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func analyzeBodyPose2D(cgImage: CGImage) async throws -> BodyProportions {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanBodyPoseRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observation = (request.results as? [VNHumanBodyPoseObservation])?.first else {
                    continuation.resume(throwing: VisionError.noBodyDetected)
                    return
                }

                do {
                    let proportions = try self.extractProportions(from: observation)
                    continuation.resume(returning: proportions)
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func translation(from transform: simd_float4x4) -> SIMD3<Float> {
        SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }

    private func distanceMeters(_ a: simd_float4x4, _ b: simd_float4x4) -> Double {
        Double(simd_distance(translation(from: a), translation(from: b)))
    }

    private func extractProportions3D(from observation: VNHumanBodyPose3DObservation) throws -> BodyProportions {
        var proportions = BodyProportions()
        proportions.analysisSource = .threeD
        proportions.bodyHeightMeters = Double(observation.bodyHeight)

        let ls: VNHumanBodyRecognizedPoint3D
        let rs: VNHumanBodyRecognizedPoint3D
        let lh: VNHumanBodyRecognizedPoint3D
        let rh: VNHumanBodyRecognizedPoint3D
        do {
            ls = try observation.recognizedPoint(.leftShoulder)
            rs = try observation.recognizedPoint(.rightShoulder)
            lh = try observation.recognizedPoint(.leftHip)
            rh = try observation.recognizedPoint(.rightHip)
        } catch {
            throw VisionError.noBodyDetected
        }

        proportions.shoulderWidth = distanceMeters(ls.position, rs.position)
        proportions.hipWidth = distanceMeters(lh.position, rh.position)

        // Natural-waist lateral span: interpolate each side from shoulder → hip (~42% toward hips).
        let t: Float = 0.42
        let leftWaist = translation(from: ls.position) + (translation(from: lh.position) - translation(from: ls.position)) * t
        let rightWaist = translation(from: rs.position) + (translation(from: rh.position) - translation(from: rs.position)) * t
        proportions.waistWidth = Double(simd_distance(leftWaist, rightWaist))

        if proportions.waistWidth <= 0 || proportions.waistWidth.isNaN {
            proportions.waistWidth = max(0, min(proportions.shoulderWidth, proportions.hipWidth) * 0.82)
        }

        proportions.bustProxyWidth = proportions.shoulderWidth * 0.96

        if let cs = try? observation.pointInImage(.centerShoulder),
           let root2D = try? observation.pointInImage(.root) {
            proportions.torsoHeight = abs(cs.location.y - root2D.location.y)
        } else if let spine = try? observation.pointInImage(.spine),
                  let root2D = try? observation.pointInImage(.root) {
            proportions.torsoHeight = abs(spine.location.y - root2D.location.y)
        }

        finalizeRatios(&proportions)
        proportions.confidence = Double(observation.confidence)
        return proportions
    }

    private func extractProportions(from observation: VNHumanBodyPoseObservation) throws -> BodyProportions {
        var proportions = BodyProportions()
        proportions.analysisSource = .twoD

        let leftShoulder = try? observation.recognizedPoint(.leftShoulder)
        let rightShoulder = try? observation.recognizedPoint(.rightShoulder)
        let leftHip = try? observation.recognizedPoint(.leftHip)
        let rightHip = try? observation.recognizedPoint(.rightHip)
        let neck = try? observation.recognizedPoint(.neck)

        let confidenceThreshold: Float = 0.3

        if let ls = leftShoulder, let rs = rightShoulder,
           ls.confidence > confidenceThreshold, rs.confidence > confidenceThreshold {
            proportions.shoulderWidth = abs(Double(ls.location.x - rs.location.x))
        }

        if let lh = leftHip, let rh = rightHip,
           lh.confidence > confidenceThreshold, rh.confidence > confidenceThreshold {
            proportions.hipWidth = abs(Double(lh.location.x - rh.location.x))
        }

        if let n = neck, let lh = leftHip, let rh = rightHip,
           n.confidence > confidenceThreshold,
           lh.confidence > confidenceThreshold, rh.confidence > confidenceThreshold {
            let midHipY = (lh.location.y + rh.location.y) / 2
            proportions.torsoHeight = abs(Double(n.location.y - midHipY))
        }

        if let ls = leftShoulder, let rs = rightShoulder,
           let lh = leftHip, let rh = rightHip,
           ls.confidence > confidenceThreshold, rs.confidence > confidenceThreshold,
           lh.confidence > confidenceThreshold, rh.confidence > confidenceThreshold {
            let t = 0.42
            let leftWaistX = Double(ls.location.x) + (Double(lh.location.x) - Double(ls.location.x)) * t
            let leftWaistY = Double(ls.location.y) + (Double(lh.location.y) - Double(ls.location.y)) * t
            let rightWaistX = Double(rs.location.x) + (Double(rh.location.x) - Double(rs.location.x)) * t
            let rightWaistY = Double(rs.location.y) + (Double(rh.location.y) - Double(rs.location.y)) * t
            let dx = rightWaistX - leftWaistX
            let dy = rightWaistY - leftWaistY
            proportions.waistWidth = hypot(dx, dy)
        }

        if proportions.waistWidth <= 0, proportions.shoulderWidth > 0, proportions.hipWidth > 0 {
            proportions.waistWidth = min(proportions.shoulderWidth, proportions.hipWidth) * 0.82
        }

        proportions.bustProxyWidth = proportions.shoulderWidth > 0 ? proportions.shoulderWidth * 0.96 : 0

        finalizeRatios(&proportions)

        var pointCount = 0
        var totalConfidence: Float = 0
        for point in [leftShoulder, rightShoulder, leftHip, rightHip, neck] {
            if let p = point, p.confidence > confidenceThreshold {
                pointCount += 1
                totalConfidence += p.confidence
            }
        }
        proportions.confidence = pointCount > 0 ? Double(totalConfidence / Float(pointCount)) : 0

        return proportions
    }

    private func finalizeRatios(_ proportions: inout BodyProportions) {
        if proportions.hipWidth > 0 {
            proportions.shoulderToHipRatio = proportions.shoulderWidth / proportions.hipWidth
            proportions.waistToHipRatio = proportions.waistWidth / proportions.hipWidth
        }
        if proportions.hipWidth > 0, proportions.bustProxyWidth > 0 {
            proportions.bustToHipRatio = proportions.bustProxyWidth / proportions.hipWidth
        }
    }

    func generateBodySegmentation(from image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw VisionError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNGeneratePersonSegmentationRequest()
            request.qualityLevel = .accurate
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
                guard let result = request.results?.first,
                      let maskImage = self.createMaskImage(from: result.pixelBuffer, originalSize: image.size) else {
                    continuation.resume(throwing: VisionError.segmentationFailed)
                    return
                }
                continuation.resume(returning: maskImage)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func createMaskImage(from pixelBuffer: CVPixelBuffer, originalSize: CGSize) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }

        UIGraphicsBeginImageContextWithOptions(originalSize, false, 1.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.draw(cgImage, in: CGRect(origin: .zero, size: originalSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension VisionAnalyzer.BodyProportions {
    /// True when spans are usable for ratio-based shape rules (research brief body-shape section).
    var isValidForClassification: Bool {
        shoulderWidth > 1e-5 && hipWidth > 1e-5 && waistWidth > 1e-5 && shoulderWidth.isFinite && hipWidth.isFinite && waistWidth.isFinite
    }
}

enum VisionError: Error, LocalizedError {
    case invalidImage
    case noBodyDetected
    case segmentationFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Unable to process the image. Please try a different photo."
        case .noBodyDetected: return "No body detected in the photo. Please upload a full-body photo."
        case .segmentationFailed: return "Unable to analyze the body outline. Please try again."
        }
    }
}
