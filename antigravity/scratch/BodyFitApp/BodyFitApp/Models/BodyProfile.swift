import Foundation

struct BodyProfile: Codable, Identifiable {
    var id = UUID()
    // Basic info
    var height: Double = 0          // in cm
    var weight: Double = 0          // in kg
    var age: Int = 25

    // Measurements (in cm)
    var bustCircumference: Double = 0
    var waistCircumference: Double = 0
    var hipCircumference: Double = 0
    var shoulderWidth: Double = 0

    // Body concerns
    var concerns: [BodyConcern] = []

    // Fit preference
    var fitPreference: FitPreference = .balanced

    // Problem areas
    var problemAreas: [ProblemArea] = []

    // Photo data (stored as file path)
    var bodyPhotoPath: String?

    // Detected shape
    var detectedShape: BodyShape?
    var shapeConfidence: Double = 0

    /// How pose was analyzed (e.g. 2D vs 3D Apple Vision).
    var visionPoseSource: String?
    /// Normalized ratios from photo pose (unitless).
    var visionShoulderToHipRatio: Double?
    var visionWaistToHipRatio: Double?
    var visionBustToHipRatio: Double?
    /// 3D pipeline body height when available (meters).
    var visionBodyHeightMeters: Double?

    /// Raw lateral spans from the image (normalized 2D or meters 3D); kept for debugging / future use.
    var visionShoulderRatio: Double?
    var visionWaistRatio: Double?
    var visionHipRatio: Double?

    var isComplete: Bool {
        height > 0 && weight > 0 &&
        bustCircumference > 0 && waistCircumference > 0 && hipCircumference > 0
    }

    var bmi: Double {
        guard height > 0 else { return 0 }
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }

    // Persistence
    static let storageKey = "bodyProfile"

    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }

    static func load() -> BodyProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let profile = try? JSONDecoder().decode(BodyProfile.self, from: data) else {
            return nil
        }
        return profile
    }
}

enum BodyConcern: String, Codable, CaseIterable, Identifiable {
    case stomachBulge = "Stomach Bulge"
    case broadShoulders = "Broad Shoulders"
    case narrowShoulders = "Narrow Shoulders"
    case wideHips = "Wide Hips"
    case narrowHips = "Narrow Hips"
    case largeBust = "Large Bust"
    case smallBust = "Small Bust"
    case thickWaist = "Thick Waist"
    case longTorso = "Long Torso"
    case shortTorso = "Short Torso"
    case heavyArms = "Heavy Arms"
    case thickThighs = "Thick Thighs"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .stomachBulge: return "circle.fill"
        case .broadShoulders, .narrowShoulders: return "arrow.left.and.right"
        case .wideHips, .narrowHips: return "triangle.fill"
        case .largeBust, .smallBust: return "circle.bottomhalf.filled"
        case .thickWaist: return "rectangle.compress.vertical"
        case .longTorso, .shortTorso: return "arrow.up.and.down"
        case .heavyArms: return "figure.arms.open"
        case .thickThighs: return "figure.walk"
        }
    }
}

enum FitPreference: String, Codable, CaseIterable, Identifiable {
    case loose = "Loose & Relaxed"
    case balanced = "Balanced Fit"
    case fitted = "Fitted & Tailored"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .loose: return "Prefer comfortable, flowy clothing with room to breathe"
        case .balanced: return "Like a mix of comfort and shape definition"
        case .fitted: return "Prefer clothes that follow your body's contours"
        }
    }

    var icon: String {
        switch self {
        case .loose: return "wind"
        case .balanced: return "equal.circle"
        case .fitted: return "person.fill"
        }
    }
}

enum ProblemArea: String, Codable, CaseIterable, Identifiable {
    case chest = "Chest area"
    case stomach = "Stomach / Midsection"
    case hips = "Hip area"
    case thighs = "Thighs"
    case arms = "Upper arms"
    case back = "Back"
    case shoulders = "Shoulders"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chest: return "heart.fill"
        case .stomach: return "circle.fill"
        case .hips: return "triangle.fill"
        case .thighs: return "figure.walk"
        case .arms: return "figure.arms.open"
        case .back: return "person.fill.turn.right"
        case .shoulders: return "arrow.left.and.right"
        }
    }
}
