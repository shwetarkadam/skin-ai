import Foundation
import UIKit

@MainActor
class ClothingViewModel: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []
    @Published var selectedClothing: ClothingItem?
    @Published var clothingImage: UIImage?
    @Published var selectedCategory: ClothingCategory = .top
    @Published var clothingName: String = ""
    @Published var selectedSize: String?

    private let storageKey = "clothing_items"

    /// Items with dresses first, then by date added. Use for dress-first flow.
    var clothingItemsSortedWithDressesFirst: [ClothingItem] {
        clothingItems.sorted { a, b in
            if a.category == .dress && b.category != .dress { return true }
            if a.category != .dress && b.category == .dress { return false }
            return a.dateAdded > b.dateAdded
        }
    }

    init() {
        loadClothingItems()
    }

    func addClothing() {
        guard let image = clothingImage else { return }
        guard let path = saveClothingImage(image) else { return }

        let name = clothingName.isEmpty ? "\(selectedCategory.rawValue) \(clothingItems.count + 1)" : clothingName
        let item = ClothingItem(
            name: name,
            category: selectedCategory,
            imagePath: path,
            size: selectedSize
        )
        clothingItems.append(item)
        saveClothingItems()

        // Reset
        clothingImage = nil
        clothingName = ""
        selectedSize = nil
    }

    func removeClothing(_ item: ClothingItem) {
        // Remove image file
        try? FileManager.default.removeItem(atPath: item.imagePath)
        if let tryOnPath = item.lastTryOnImagePath {
            try? FileManager.default.removeItem(atPath: tryOnPath)
        }
        clothingItems.removeAll { $0.id == item.id }
        saveClothingItems()
    }

    func saveTryOnResult(for item: ClothingItem, image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return false }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "tryon_\(item.id.uuidString).jpg"
        let filePath = documentsPath.appendingPathComponent(fileName)
        do {
            if let oldPath = item.lastTryOnImagePath {
                try? FileManager.default.removeItem(atPath: oldPath)
            }
            try data.write(to: filePath)
            if let idx = clothingItems.firstIndex(where: { $0.id == item.id }) {
                clothingItems[idx].lastTryOnImagePath = filePath.path
                saveClothingItems()
                return true
            }
        } catch {}
        return false
    }

    private func saveClothingImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "clothing_\(UUID().uuidString).jpg"
        let filePath = documentsPath.appendingPathComponent(fileName)
        do {
            try data.write(to: filePath)
            return filePath.path
        } catch {
            return nil
        }
    }

    private func saveClothingItems() {
        if let data = try? JSONEncoder().encode(clothingItems) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadClothingItems() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let items = try? JSONDecoder().decode([ClothingItem].self, from: data) else { return }
        clothingItems = items
    }
}
