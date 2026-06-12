import Foundation

/// Approximate women's size chart (bust, waist, hip in cm). Used to recommend size from measurements.
private let sizeChart: [(size: String, bust: ClosedRange<Double>, waist: ClosedRange<Double>, hip: ClosedRange<Double>)] = [
    ("XS", 79...83, 60...64, 86...90),
    ("S", 84...88, 65...69, 91...95),
    ("M", 89...93, 70...74, 96...100),
    ("L", 94...98, 75...79, 101...105),
    ("XL", 99...103, 80...84, 106...110),
    ("XXL", 104...120, 85...100, 111...125)
]

class FitEngine {
    func generateRecommendation(profile: BodyProfile, clothing: ClothingItem) -> FitRecommendation {
        guard let shape = profile.detectedShape else {
            return defaultRecommendation(clothing: clothing)
        }

        var tightAreas: [String] = []
        var looseAreas: [String] = []
        var suggestions: [String] = []
        var score = 7
        var recommendedSize: String?
        var sizeAdvice: String?

        // Analyze based on body shape + clothing category
        switch (shape, clothing.category) {
        case (.apple, .top):
            if profile.concerns.contains(.stomachBulge) {
                tightAreas.append("Midsection — may pull across the stomach")
                suggestions.append("Look for tops with ruching or draping at the waist")
                suggestions.append("Consider sizing up for a more comfortable fit around the middle")
                score -= 2
            }
            if profile.concerns.contains(.largeBust) {
                tightAreas.append("Bust area — may feel constrictive")
                suggestions.append("Opt for V-neck or wrap styles for a flattering bustline")
                score -= 1
            }
            looseAreas.append("Hip area — likely to have extra room below the waist")

        case (.apple, .dress):
            tightAreas.append("Waist and midsection — dress may cling to the tummy")
            suggestions.append("Empire waist or A-line dresses will skim over the midsection")
            suggestions.append("Look for dresses with strategic draping around the middle")
            suggestions.append("Mid-length or knee-length hems balance your silhouette; avoid very short hems that emphasize the middle")
            if profile.concerns.contains(.stomachBulge) {
                score -= 3
                suggestions.append("Consider a structured fabric that holds shape rather than clingy material")
            }

        case (.apple, .bottom):
            tightAreas.append("Waistband may feel tight if sitting at the natural waist")
            suggestions.append("Mid-rise styles are generally more comfortable for your shape")
            suggestions.append("Look for styles with stretch or elastic waistbands")
            score -= 1

        case (.pear, .top):
            looseAreas.append("Shoulder and bust area — tops may feel roomy up top")
            suggestions.append("Structured shoulders or statement sleeves balance your proportions")
            suggestions.append("Bright colors and patterns on top draw the eye upward")
            score += 1

        case (.pear, .bottom):
            tightAreas.append("Hip and thigh area — pants may feel snug")
            if profile.concerns.contains(.thickThighs) {
                tightAreas.append("Thighs — may restrict movement")
                score -= 2
            }
            suggestions.append("Bootcut or wide-leg styles balance wider hips beautifully")
            suggestions.append("Dark-colored bottoms create a slimming effect")

        case (.pear, .dress):
            tightAreas.append("Hip area — dress may pull across the hips")
            suggestions.append("A-line or fit-and-flare dresses are your most flattering silhouette")
            suggestions.append("V-neck or scoop necklines draw the eye up; avoid high necklines that shorten the torso")
            score -= 1

        case (.hourglass, .top):
            suggestions.append("Fitted styles that define your waist are ideal")
            suggestions.append("Wrap tops showcase your balanced proportions")
            score += 1

        case (.hourglass, .dress):
            suggestions.append("This should fit beautifully — your proportions work well with most dress styles")
            suggestions.append("Belted or wrap dresses accentuate your defined waist")
            suggestions.append("Fitted or wrap necklines and midi length are especially flattering")
            score += 2

        case (.hourglass, .bottom):
            suggestions.append("High-waisted styles highlight your narrow waist")
            score += 1

        case (.rectangle, .top):
            looseAreas.append("Waist area — tops may hang straight without definition")
            suggestions.append("Peplum and ruched tops create the illusion of curves")
            suggestions.append("Layering adds dimension and visual interest")

        case (.rectangle, .dress):
            looseAreas.append("Waist — dress may not show much shape definition")
            suggestions.append("Belted dresses or wrap styles create waist definition")
            suggestions.append("Fit-and-flare silhouettes add feminine shape")
            suggestions.append("Dresses with defined waistlines or ruching at the waist work best")
            score -= 1

        case (.rectangle, .bottom):
            suggestions.append("Pleated or wide-leg pants add body and movement")
            suggestions.append("High-waisted styles with a belt create waist definition")

        case (.invertedTriangle, .top):
            tightAreas.append("Shoulders and upper arms — may feel constrictive")
            if profile.concerns.contains(.broadShoulders) {
                score -= 2
                suggestions.append("V-necklines and raglan sleeves soften broad shoulders")
            }
            suggestions.append("Avoid boat necklines and padded shoulders")

        case (.invertedTriangle, .bottom):
            looseAreas.append("Hip area — bottoms may feel roomy below the waist")
            suggestions.append("Wide-leg pants and full skirts add volume to balance your frame")
            score += 1

        case (.invertedTriangle, .dress):
            tightAreas.append("Shoulder area — may feel tight across the top")
            suggestions.append("A-line dresses with detailed skirts balance your proportions")
            suggestions.append("V-neck or wrap necklines and sleeveless or raglan sleeves avoid adding shoulder width")
            score -= 1

        default:
            suggestions.append("This garment should work reasonably well with your body type")
        }

        // Add concern-specific adjustments
        for concern in profile.concerns {
            switch concern {
            case .stomachBulge where clothing.category == .dress || clothing.category == .top:
                if !tightAreas.contains(where: { $0.lowercased().contains("stomach") || $0.lowercased().contains("midsection") }) {
                    tightAreas.append("Stomach area may show through fitted styles")
                    suggestions.append("Darker colors and structured fabrics help smooth the midsection")
                }
            case .heavyArms where clothing.category == .top || clothing.category == .dress:
                suggestions.append("Three-quarter or fluttery sleeves are more flattering than cap sleeves")
            default:
                break
            }
        }

        // Fit preference adjustment
        switch profile.fitPreference {
        case .loose:
            score += 1
            suggestions.append("Since you prefer a relaxed fit, consider sizing up for comfort")
        case .fitted:
            if !tightAreas.isEmpty {
                score -= 1
                suggestions.append("Fitted styles in stretch fabrics will accommodate snug areas")
            }
        case .balanced:
            break
        }

        // Size recommendation from body measurements
        if profile.bustCircumference > 0, profile.waistCircumference > 0, profile.hipCircumference > 0 {
            recommendedSize = recommendedSizeFor(profile: profile)
            if let rec = recommendedSize {
                if let garmentSize = clothing.size?.trimmingCharacters(in: .whitespaces), !garmentSize.isEmpty {
                    let sizeOrder = ["XS", "S", "M", "L", "XL", "XXL", "One Size"]
                    let recIdx = sizeOrder.firstIndex(of: rec) ?? 2
                    let garmentIdx = sizeOrder.firstIndex(of: garmentSize) ?? 2
                    if garmentIdx < recIdx && garmentSize != "One Size" {
                        score -= 1
                        sizeAdvice = "This item is size \(garmentSize); we recommend size \(rec) for your measurements — consider sizing up."
                        suggestions.insert("Sizing up to \(rec) may be more comfortable", at: 0)
                    } else if garmentIdx > recIdx {
                        sizeAdvice = "This item is size \(garmentSize). Your measurements suggest \(rec); this may fit slightly loose."
                    } else {
                        sizeAdvice = "Size \(garmentSize) aligns well with our recommendation of \(rec) for your measurements."
                    }
                } else {
                    sizeAdvice = "Based on your measurements, we recommend size \(rec) for this type of garment."
                }
            }
        }

        // Clamp score
        score = max(1, min(10, score))

        let fitLevel: FitLevel = {
            switch score {
            case 9...10: return .perfect
            case 7...8: return .good
            case 5...6: return .moderate
            case 3...4: return .challenging
            default: return .poor
            }
        }()

        let compatibility = shape.fitConsiderations[clothing.category.rawValue.lowercased()] ?? "Generally compatible with your body shape"

        let styleAdvice = "Based on your \(shape.rawValue) body shape, \(compatibility.lowercased()). \(shape.stylingTips.first ?? "")"

        return FitRecommendation(
            overallScore: score,
            fitLevel: fitLevel,
            tightAreas: tightAreas,
            looseAreas: looseAreas,
            suggestions: Array(suggestions.prefix(6)),
            bodyShapeCompatibility: compatibility,
            styleAdvice: styleAdvice,
            recommendedSize: recommendedSize,
            sizeAdvice: sizeAdvice
        )
    }

    private func recommendedSizeFor(profile: BodyProfile) -> String? {
        let bust = profile.bustCircumference
        let waist = profile.waistCircumference
        let hip = profile.hipCircumference
        for entry in sizeChart {
            if entry.bust.contains(bust), entry.waist.contains(waist), entry.hip.contains(hip) {
                return entry.size
            }
        }
        // Find smallest size where at least two of three measurements fit (avoid recommending too small)
        for entry in sizeChart {
            var matches = 0
            if entry.bust.contains(bust) { matches += 1 }
            if entry.waist.contains(waist) { matches += 1 }
            if entry.hip.contains(hip) { matches += 1 }
            if matches >= 2 { return entry.size }
        }
        if hip > 110 || bust > 104 { return "XXL" }
        if hip < 91 || bust < 84 { return "XS" }
        return "M"
    }

    private func defaultRecommendation(clothing: ClothingItem) -> FitRecommendation {
        return FitRecommendation(
            overallScore: 5,
            fitLevel: .moderate,
            tightAreas: [],
            looseAreas: [],
            suggestions: ["Complete your body profile for personalized fit recommendations"],
            bodyShapeCompatibility: "Unable to determine without body profile",
            styleAdvice: "Complete the body shape questionnaire for detailed style advice",
            recommendedSize: nil,
            sizeAdvice: nil
        )
    }
}
