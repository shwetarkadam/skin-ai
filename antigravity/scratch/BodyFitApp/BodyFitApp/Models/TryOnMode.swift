import Foundation

enum TryOnMode: String, CaseIterable, Identifiable, Codable {
    case localOnly = "Local Only"
    case cloud = "Cloud Virtual Try-On"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .localOnly:
            return "Use only on-device fit analysis. No photos are sent to servers and virtual try-on is disabled."
        case .cloud:
            return "Enable virtual try-on using the online try-on service. Fit analysis still runs on-device."
        }
    }
}

