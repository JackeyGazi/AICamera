import Foundation
import UIKit
import Combine

class MockDataService: APIServiceProtocol {

    func fetchStyleTemplates() -> AnyPublisher<[StyleTemplate], Error> {
        let templates = [
            StyleTemplate(id: "ink", name: "水墨中国风", icon: "ink", color: "#2C3E50"),
            StyleTemplate(id: "ancient", name: "古风头像", icon: "ancient", color: "#8B4513"),
            StyleTemplate(id: "chibi", name: "Q版萌趣头像", icon: "chibi", color: "#FF69B4"),
            StyleTemplate(id: "anime", name: "日系动漫头像", icon: "anime", color: "#4169E1"),
            StyleTemplate(id: "doll3d", name: "3D玩偶头像", icon: "doll3d", color: "#32CD32"),
            StyleTemplate(id: "cyberpunk", name: "赛博朋克写真", icon: "cyberpunk", color: "#9400D3"),
            StyleTemplate(id: "cyberpunk", name: "赛博朋克写真", icon: "cyberpunk", color: "#9400D3")
        ]
        return Just(templates)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(0.3), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func generateImage(image: UIImage, styleId: String) -> AnyPublisher<UIImage, Error> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let colors: [UIColor] = [.systemPink, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemTeal]
                let randomColor = colors.randomElement() ?? .systemPink

                UIGraphicsBeginImageContext(image.size)
                defer { UIGraphicsEndImageContext() }

                let rect = CGRect(origin: .zero, size: image.size)
                image.draw(in: rect)

                randomColor.withAlphaComponent(0.4).setFill()
                UIRectFillUsingBlendMode(rect, .overlay)

                if let result = UIGraphicsGetImageFromCurrentImageContext() {
                    promise(.success(result))
                } else {
                    promise(.failure(NSError(domain: "Mock", code: -1, userInfo: [NSLocalizedDescriptionKey: "生成失败"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
