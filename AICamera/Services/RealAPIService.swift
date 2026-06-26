import Foundation
import UIKit
import Combine

class RealAPIService: APIServiceProtocol {
    let baseURL: String
    let appSecret: String

    init(baseURL: String, appSecret: String = "") {
        self.baseURL = baseURL
        self.appSecret = appSecret
    }

    func fetchStyleTemplates() -> AnyPublisher<[StyleTemplate], Error> {
        let templates = [
            StyleTemplate(id: "ink", name: "水墨中国风", icon: "ink", color: "#2C3E50"),
            StyleTemplate(id: "ancient", name: "古风头像", icon: "ancient", color: "#8B4513"),
            StyleTemplate(id: "chibi", name: "Q版萌趣头像", icon: "chibi", color: "#FF69B4"),
            StyleTemplate(id: "anime", name: "日系动漫头像", icon: "anime", color: "#4169E1"),
            StyleTemplate(id: "doll3d", name: "3D玩偶头像", icon: "doll3d", color: "#32CD32"),
            StyleTemplate(id: "cyberpunk", name: "赛博朋克写真", icon: "cyberpunk", color: "#9400D3"),
            StyleTemplate(id: "goldplated", name: "国风鎏金山水", icon: "goldplated", color: "#E7C013")
        ]
        return Just(templates)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func generateImage(image: UIImage, styleId: String) -> AnyPublisher<UIImage, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                promise(.failure(NSError(domain: "RealAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "图片编码失败"])))
                return
            }

            let base64String = "data:image/jpeg;base64," + imageData.base64EncodedString()

            let url = URL(string: self.baseURL)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if !self.appSecret.isEmpty {
                request.setValue(self.appSecret, forHTTPHeaderField: "x-app-secret")
            }

            let body: [String: Any] = [
                "styleId": styleId,
                "imageBase64": base64String
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let data = data else {
                    promise(.failure(NSError(domain: "RealAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "无响应数据"])))
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool, success,
                       let imageBase64 = json["imageBase64"] as? String {
                        let cleanBase64 = imageBase64.replacingOccurrences(of: "data:image/[^;]+;base64,", with: "", options: .regularExpression)
                        if let imageData = Data(base64Encoded: cleanBase64),
                           let resultImage = UIImage(data: imageData) {
                            promise(.success(resultImage))
                        } else {
                            promise(.failure(NSError(domain: "RealAPI", code: -3, userInfo: [NSLocalizedDescriptionKey: "图片解码失败"])))
                        }
                    } else {
                        let errorMsg = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"] as? String ?? "生成失败"
                        promise(.failure(NSError(domain: "RealAPI", code: -4, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                    }
                } catch {
                    promise(.failure(error))
                }
            }.resume()
        }
        .eraseToAnyPublisher()
    }
}
