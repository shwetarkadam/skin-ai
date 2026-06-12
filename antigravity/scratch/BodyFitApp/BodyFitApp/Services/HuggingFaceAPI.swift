import Foundation
import UIKit

class HuggingFaceAPI {
    private let baseURL = AppConstants.huggingFaceBaseURL
    private var apiToken: String {
        UserDefaults.standard.string(forKey: "hf_api_token") ?? ""
    }

    enum APIError: Error, LocalizedError {
        case noToken
        case invalidResponse
        case rateLimited
        case modelLoading
        case serverError(String)

        var errorDescription: String? {
            switch self {
            case .noToken: return "Please set your Hugging Face API token in Settings."
            case .invalidResponse: return "Received an invalid response from the server."
            case .rateLimited: return "Rate limit reached. Please wait a moment and try again."
            case .modelLoading: return "The AI model is loading. This may take 1-2 minutes on first use."
            case .serverError(let msg): return "Server error: \(msg)"
            }
        }
    }

    func generateTryOn(bodyImage: UIImage, clothingImage: UIImage) async throws -> UIImage {
        guard !apiToken.isEmpty else { throw APIError.noToken }

        // Resize images for API
        let resizedBody = resizeImage(bodyImage, maxDimension: 768)
        let resizedClothing = resizeImage(clothingImage, maxDimension: 768)

        guard let bodyData = resizedBody.jpegData(compressionQuality: 0.8),
              let clothingData = resizedClothing.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidResponse
        }

        // Create multipart form data request
        let boundary = UUID().uuidString
        let url = URL(string: "\(baseURL)/\(AppConstants.tryOnModel)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        var body = Data()

        // Add body image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"human_img\"; filename=\"body.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(bodyData)
        body.append("\r\n".data(using: .utf8)!)

        // Add clothing image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"garm_img\"; filename=\"clothing.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(clothingData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (responseData, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            if let image = UIImage(data: responseData) {
                return image
            }
            // Sometimes the response is JSON with base64 image
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [[String: Any]],
               let first = json.first,
               let base64 = first["generated_image"] as? String,
               let imgData = Data(base64Encoded: base64),
               let image = UIImage(data: imgData) {
                return image
            }
            throw APIError.invalidResponse

        case 429:
            throw APIError.rateLimited

        case 503:
            throw APIError.modelLoading

        default:
            let errorMsg = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(errorMsg)
        }
    }

    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let scale = min(maxDimension / size.width, maxDimension / size.height)
        if scale >= 1 { return image }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return resized
    }

    func setToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "hf_api_token")
    }

    var hasToken: Bool {
        !apiToken.isEmpty
    }
}
