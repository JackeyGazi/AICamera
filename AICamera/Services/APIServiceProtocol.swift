import Foundation
import UIKit

protocol AIServiceProtocol {
    func fetchStyleTemplates(completion: @escaping (Result<[StyleTemplate], Error>) -> Void)
    func generateImage(
        originalImage: UIImage,
        style: StyleTemplate,
        completion: @escaping (Result<GeneratedImage, Error>) -> Void
    )
    func fetchHistory(completion: @escaping (Result<[GeneratedImage], Error>) -> Void)
}
