import Foundation

struct FitRecommendation: Identifiable {
    var id = UUID()
    var overallScore: Int              // 1-10
    var fitLevel: FitLevel
    var tightAreas: [String]
    var looseAreas: [String]
    var suggestions: [String]
    var bodyShapeCompatibility: String
    var styleAdvice: String
    /// Recommended garment size based on body measurements (e.g. "M").
    var recommendedSize: String?
    /// Short advice about size (e.g. "This item is size S; we recommend M for your measurements").
    var sizeAdvice: String?
}

enum FitLevel: String {
    case perfect = "Perfect Fit"
    case good = "Good Fit"
    case moderate = "Moderate Fit"
    case challenging = "Challenging Fit"
    case poor = "Poor Fit"

    var color: String {
        switch self {
        case .perfect: return "green"
        case .good: return "teal"
        case .moderate: return "yellow"
        case .challenging: return "orange"
        case .poor: return "red"
        }
    }

    var emoji: String {
        switch self {
        case .perfect: return "✨"
        case .good: return "👍"
        case .moderate: return "🤔"
        case .challenging: return "⚠️"
        case .poor: return "❌"
        }
    }
}
