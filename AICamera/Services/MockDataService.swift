import Foundation
import UIKit

class MockDataService: AIServiceProtocol {
    static let shared = MockDataService()
    
    private init() {}
    
    func fetchStyleTemplates(completion: @escaping (Result<[StyleTemplate], Error>) -> Void) {
        let templates = StyleTemplate.sampleData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(templates))
        }
    }
    
    func generateImage(
        originalImage: UIImage,
        style: StyleTemplate,
        completion: @escaping (Result<GeneratedImage, Error>) -> Void
    ) {
        let mockGeneratedImage = generateMockGeneratedImage(from: originalImage)
        let generated = GeneratedImage(
            id: UUID().uuidString,
            originalImageData: originalImage.pngData() ?? Data(),
            generatedImageData: mockGeneratedImage.pngData() ?? Data(),
            styleTemplate: style,
            createdAt: Date()
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion(.success(generated))
        }
    }
    
    func fetchHistory(completion: @escaping (Result<[GeneratedImage], Error>) -> Void) {
        let history = sampleHistory()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(history))
        }
    }
    
    private func generateMockGeneratedImage(from image: UIImage) -> UIImage {
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: size))
        
        let overlayColor = UIColor.random().withAlphaComponent(0.3)
        overlayColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    private func sampleHistory() -> [GeneratedImage] {
        let templates = StyleTemplate.sampleData()
        var history: [GeneratedImage] = []
        
        for i in 0..<6 {
            let template = templates[i % templates.count]
            let image = UIImage(systemName: "person.circle.fill") ?? UIImage()
            let generatedImage = UIImage(systemName: "star.circle.fill") ?? UIImage()
            
            let generated = GeneratedImage(
                id: UUID().uuidString,
                originalImageData: image.pngData() ?? Data(),
                generatedImageData: generatedImage.pngData() ?? Data(),
                styleTemplate: template,
                createdAt: Date().addingTimeInterval(-Double(i) * 3600 * 24)
            )
            history.append(generated)
        }
        
        return history
    }
}

extension StyleTemplate {
    static func sampleData() -> [StyleTemplate] {
        [
            StyleTemplate(
                id: "ink",
                name: "水墨中国风",
                description: "传统水墨画意境，留白写意",
                thumbnailName: "ink_style",
                category: .ink
            ),
            StyleTemplate(
                id: "ancient",
                name: "古风头像",
                description: "古典雅致，东方韵味",
                thumbnailName: "ancient_style",
                category: .ancient
            ),
            StyleTemplate(
                id: "chibi",
                name: "Q版萌趣头像",
                description: "可爱Q版，萌化人心",
                thumbnailName: "chibi_style",
                category: .chibi
            ),
            StyleTemplate(
                id: "anime",
                name: "日系动漫头像",
                description: "日系二次元，精致画风",
                thumbnailName: "anime_style",
                category: .anime
            ),
            StyleTemplate(
                id: "doll3d",
                name: "3D玩偶头像",
                description: "立体玩偶，萌趣可爱",
                thumbnailName: "doll3d_style",
                category: .doll3D
            ),
            StyleTemplate(
                id: "cyberpunk",
                name: "赛博朋克写真",
                description: "未来科技，霓虹光影",
                thumbnailName: "cyberpunk_style",
                category: .cyberpunk
            )
        ]
    }
}

extension UIColor {
    static func random() -> UIColor {
        UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}
