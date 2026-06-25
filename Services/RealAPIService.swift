import Foundation
import UIKit

class RealAPIService: AIServiceProtocol {
    static let shared = RealAPIService()
    
    private let baseURL: String
    private let appSecret: String?
    
    init(
        baseURL: String = "YOUR_SERVERLESS_ENDPOINT",
        appSecret: String? = nil
    ) {
        self.baseURL = baseURL
        self.appSecret = appSecret
    }
    
    func fetchStyleTemplates(completion: @escaping (Result<[StyleTemplate], Error>) -> Void) {
        let templates = StyleTemplate.sampleData()
        completion(.success(templates))
    }
    
    func generateImage(
        originalImage: UIImage,
        style: StyleTemplate,
        completion: @escaping (Result<GeneratedImage, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/generate") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        guard let imageData = originalImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(APIError.imageEncodingFailed))
            return
        }
        
        let base64String = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "imageBase64": base64String,
            "styleId": style.id
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let appSecret = appSecret {
            request.setValue(appSecret, forHTTPHeaderField: "x-app-secret")
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.invalidResponse))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }
            
            do {
                if httpResponse.statusCode != 200 {
                    if let errorDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = errorDict["error"] as? String {
                        DispatchQueue.main.async {
                            completion(.failure(APIError.serverError(message: errorMessage)))
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode)))
                    }
                    return
                }
                
                guard let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let success = responseDict["success"] as? Bool,
                      success == true,
                      let generatedBase64 = responseDict["imageBase64"] as? String else {
                    DispatchQueue.main.async {
                        completion(.failure(APIError.invalidResponseFormat))
                    }
                    return
                }
                
                guard let generatedData = Data(base64Encoded: generatedBase64),
                      let generatedImage = UIImage(data: generatedData) else {
                    DispatchQueue.main.async {
                        completion(.failure(APIError.imageDecodingFailed))
                    }
                    return
                }
                
                let result = GeneratedImage(
                    id: UUID().uuidString,
                    originalImageData: originalImage.pngData() ?? Data(),
                    generatedImageData: generatedImage.pngData() ?? Data(),
                    styleTemplate: style,
                    createdAt: Date()
                )
                
                DispatchQueue.main.async {
                    completion(.success(result))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func fetchHistory(completion: @escaping (Result<[GeneratedImage], Error>) -> Void) {
        completion(.success([]))
    }
    
    enum APIError: Error, LocalizedError {
        case invalidURL
        case imageEncodingFailed
        case invalidResponse
        case noData
        case serverError(message: String)
        case httpError(statusCode: Int)
        case invalidResponseFormat
        case imageDecodingFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "无效的服务器地址"
            case .imageEncodingFailed:
                return "图片编码失败"
            case .invalidResponse:
                return "无效的响应"
            case .noData:
                return "无返回数据"
            case .serverError(let message):
                return "服务器错误：\(message)"
            case .httpError(let statusCode):
                return "HTTP 错误：\(statusCode)"
            case .invalidResponseFormat:
                return "响应格式错误"
            case .imageDecodingFailed:
                return "图片解码失败"
            }
        }
    }
}
