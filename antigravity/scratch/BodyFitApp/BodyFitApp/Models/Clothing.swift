import Foundation
import UIKit

struct ClothingItem: Codable, Identifiable {
    var id = UUID()
    var name: String
    var category: ClothingCategory
    var imagePath: String
    var dateAdded: Date = Date()
    var notes: String = ""
    /// Garment size (e.g. S, M, L) for fit comparison. Optional for backward compatibility.
    var size: String?
    /// Path to saved virtual try-on result image, if user saved it.
    var lastTryOnImagePath: String?

    var image: UIImage? {
        guard let data = FileManager.default.contents(atPath: imagePath) else { return nil }
        return UIImage(data: data)
    }

    var lastTryOnImage: UIImage? {
        guard let path = lastTryOnImagePath,
              let data = FileManager.default.contents(atPath: path) else { return nil }
        return UIImage(data: data)
    }
}

/// Common garment sizes for pickers. Not all brands use these; "One Size" / custom allowed.
enum GarmentSize: String, CaseIterable, Identifiable {
    case xs = "XS"
    case s = "S"
    case m = "M"
    case l = "L"
    case xl = "XL"
    case xxl = "XXL"
    case oneSize = "One Size"

    var id: String { rawValue }
}

enum ClothingCategory: String, Codable, CaseIterable, Identifiable {
    case top = "Top"
    case bottom = "Bottom"
    case dress = "Dress"
    case outerwear = "Outerwear"
    case activewear = "Activewear"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .top: return "tshirt.fill"
        case .bottom: return "figure.walk"
        case .dress: return "figure.dress.line.vertical.figure"
        case .outerwear: return "cloud.snow.fill"
        case .activewear: return "figure.run"
        }
    }
}
