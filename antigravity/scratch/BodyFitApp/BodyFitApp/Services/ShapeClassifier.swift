import Foundation

class ShapeClassifier {
    struct ClassificationResult {
        let shape: BodyShape
        let confidence: Double
        let allScores: [BodyShape: Double]
    }

    func classify(profile: BodyProfile, visionProportions: VisionAnalyzer.BodyProportions? = nil) -> ClassificationResult {
        var scores: [BodyShape: Double] = [:]

        // Score from measurements (tape / questionnaire)
        let measurementScores = classifyFromMeasurements(profile: profile)

        // Vision path: ratio rules from pose (research §02). Low confidence → rely more on measurements (research §02).
        let visionTrust: Double
        let visionScores: [BodyShape: Double]
        if let proportions = visionProportions, proportions.isValidForClassification, proportions.confidence > 0.28 {
            visionScores = classifyFromVision(proportions: proportions)
            visionTrust = min(1.0, max(0, (proportions.confidence - 0.28) / 0.55))
        } else {
            visionScores = [:]
            visionTrust = 0
        }

        let concernScores = classifyFromConcerns(concerns: profile.concerns)

        // Weighted combination — when vision is weak, questionnaire + concerns dominate (MVP recommendation).
        let measurementWeight: Double = {
            if visionScores.isEmpty { return 0.7 }
            return 0.42 + (1.0 - visionTrust) * 0.28
        }()
        let visionWeight: Double = visionScores.isEmpty ? 0.0 : 0.18 + visionTrust * 0.27
        let concernWeight: Double = visionScores.isEmpty ? 0.3 : 0.12 + (1.0 - visionTrust) * 0.1

        let weightSum = measurementWeight + visionWeight + concernWeight
        let normM = measurementWeight / weightSum
        let normV = visionWeight / weightSum
        let normC = concernWeight / weightSum

        for shape in BodyShape.allCases {
            let mScore = measurementScores[shape] ?? 0
            let vScore = visionScores[shape] ?? 0
            let cScore = concernScores[shape] ?? 0
            scores[shape] = mScore * normM + vScore * normV + cScore * normC
        }

        // Find the best match
        let sorted = scores.sorted { $0.value > $1.value }
        let bestShape = sorted.first?.key ?? .rectangle
        let bestScore = sorted.first?.value ?? 0

        // Normalize confidence to 0-1
        let totalScore = scores.values.reduce(0, +)
        let confidence = totalScore > 0 ? bestScore / totalScore : 0.5

        return ClassificationResult(
            shape: bestShape,
            confidence: min(confidence, 0.98),
            allScores: scores
        )
    }

    private func classifyFromMeasurements(profile: BodyProfile) -> [BodyShape: Double] {
        var scores: [BodyShape: Double] = [:]
        guard profile.bustCircumference > 0 && profile.waistCircumference > 0 && profile.hipCircumference > 0 else {
            return BodyShape.allCases.reduce(into: [:]) { $0[$1] = 0.2 }
        }

        let bust = profile.bustCircumference
        let waist = profile.waistCircumference
        let hip = profile.hipCircumference

        let bustToHip = bust / hip
        let waistToBust = waist / bust
        let waistToHip = waist / hip

        // Hourglass: bust ≈ hips, waist is noticeably smaller
        let hourglassScore: Double = {
            let bustHipSimilarity = 1.0 - min(abs(bustToHip - 1.0), 0.5) * 2
            let waistDefinition = max(0, 1.0 - waistToHip) * 2
            return (bustHipSimilarity * 0.5 + waistDefinition * 0.5)
        }()
        scores[.hourglass] = max(0, min(1, hourglassScore))

        // Pear: hips > bust, defined waist
        let pearScore: Double = {
            let hipsLarger = max(0, (1.0 - bustToHip)) * 3
            let waistDefined = max(0, 1.0 - waistToHip) * 1.5
            return (hipsLarger * 0.6 + waistDefined * 0.4)
        }()
        scores[.pear] = max(0, min(1, pearScore))

        // Apple: waist ≈ bust, wider than hips
        let appleScore: Double = {
            let thickWaist = max(0, waistToBust - 0.7) * 3
            let waistWiderThanHip = max(0, waistToHip - 0.85) * 3
            return (thickWaist * 0.5 + waistWiderThanHip * 0.5)
        }()
        scores[.apple] = max(0, min(1, appleScore))

        // Rectangle: all measurements similar
        let rectangleScore: Double = {
            let similarity = 1.0 - (abs(bustToHip - 1.0) + abs(waistToBust - 0.95) + abs(waistToHip - 0.95)) / 3
            return max(0, similarity * 1.5)
        }()
        scores[.rectangle] = max(0, min(1, rectangleScore))

        // Inverted Triangle: bust/shoulders much wider than hips
        let invertedTriangleScore: Double = {
            let bustLarger = max(0, bustToHip - 1.0) * 3
            let shoulderFactor = profile.shoulderWidth > 0 ? max(0, profile.shoulderWidth / hip - 0.3) * 2 : 0
            return (bustLarger * 0.6 + shoulderFactor * 0.4)
        }()
        scores[.invertedTriangle] = max(0, min(1, invertedTriangleScore))

        return scores
    }

    /// Ratio-based rules from pose keypoints (research brief §02 — no neural net).
    private func classifyFromVision(proportions: VisionAnalyzer.BodyProportions) -> [BodyShape: Double] {
        var scores: [BodyShape: Double] = [:]
        let S = proportions.shoulderWidth
        let H = proportions.hipWidth
        let W = proportions.waistWidth
        let B = proportions.bustProxyWidth > 0 ? proportions.bustProxyWidth : S

        guard H > 1e-6, S > 1e-6, W > 1e-6 else {
            return BodyShape.allCases.reduce(into: [:]) { $0[$1] = 0.15 }
        }

        let shoulderHip = S / H
        let waistHip = W / H
        let waistShoulder = W / S
        let bustHip = B / H

        // Hourglass: shoulder ≈ hip, bust proxy ≈ hip, waist clearly narrower than hip (< 75% of hip).
        let shoulderHipBalance = 1.0 - min(abs(shoulderHip - 1.0), 0.12) / 0.12
        let bustHipBalance = 1.0 - min(abs(bustHip - 1.0), 0.12) / 0.12
        let hourglassNarrowWaist = waistHip < 0.75 ? 1.0 : max(0, 1.0 - (waistHip - 0.72) / 0.28)
        var hourglass = max(0, min(1, shoulderHipBalance * 0.32 + bustHipBalance * 0.22 + hourglassNarrowWaist * 0.46))
        if shoulderHip < 0.92 || shoulderHip > 1.08 { hourglass *= 0.55 }
        if waistHip > 0.8 { hourglass *= 0.65 }

        // Triangle (pear): hip > shoulder by > 5%, defined waist.
        var pear: Double = 0
        if shoulderHip < 0.952 {
            pear += 0.55
        }
        if waistHip < 0.88 {
            pear += 0.38
        }
        pear = max(0, min(1, pear))
        if waistHip > 0.95 { pear *= 0.45 }

        // Inverted triangle: shoulder > hip by > 5%.
        var inverted: Double = 0
        if shoulderHip > 1.05 {
            inverted += 0.72
        }
        if waistShoulder < 0.92 {
            inverted += 0.18
        }
        inverted = max(0, min(1, inverted))
        if shoulderHip < 1.0 { inverted *= 0.35 }

        // Rectangle: shoulder, hip, waist within ~5% of each other (by max span).
        let maxSpan = max(S, H, W)
        let meanSpan = (S + H + W) / 3
        let spread = (abs(S - meanSpan) + abs(H - meanSpan) + abs(W - meanSpan)) / (3 * max(maxSpan, 1e-6))
        var rectangle = max(0, min(1, 1.0 - spread * 4))
        if max(abs(shoulderHip - 1), abs(waistHip - 1)) > 0.08 {
            rectangle *= 0.5
        }

        // Apple: waist ≥ hip or waist ≈ hip (fullness in midsection).
        var apple: Double = 0
        if waistHip >= 0.95 {
            apple += 0.58
        }
        if W >= H * 0.92 {
            apple += 0.32
        }
        apple = max(0, min(1, apple))
        if waistHip < 0.82 {
            apple *= 0.35
        }

        scores[.hourglass] = hourglass
        scores[.pear] = pear
        scores[.invertedTriangle] = inverted
        scores[.rectangle] = rectangle
        scores[.apple] = apple

        return scores
    }

    private func classifyFromConcerns(concerns: [BodyConcern]) -> [BodyShape: Double] {
        var scores: [BodyShape: Double] = BodyShape.allCases.reduce(into: [:]) { $0[$1] = 0.1 }

        for concern in concerns {
            switch concern {
            case .stomachBulge, .thickWaist:
                scores[.apple, default: 0] += 0.3
            case .wideHips, .thickThighs:
                scores[.pear, default: 0] += 0.3
            case .broadShoulders:
                scores[.invertedTriangle, default: 0] += 0.3
            case .narrowHips:
                scores[.invertedTriangle, default: 0] += 0.2
            case .narrowShoulders:
                scores[.pear, default: 0] += 0.2
            case .largeBust:
                scores[.hourglass, default: 0] += 0.2
                scores[.invertedTriangle, default: 0] += 0.1
            case .smallBust:
                scores[.pear, default: 0] += 0.15
                scores[.rectangle, default: 0] += 0.15
            case .longTorso, .shortTorso:
                break // These don't strongly indicate a shape
            case .heavyArms:
                scores[.apple, default: 0] += 0.1
            }
        }

        // Normalize
        let maxScore = scores.values.max() ?? 1
        if maxScore > 0 {
            for key in scores.keys {
                scores[key] = (scores[key] ?? 0) / maxScore
            }
        }

        return scores
    }
}
