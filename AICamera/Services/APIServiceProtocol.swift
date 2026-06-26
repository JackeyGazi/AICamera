import Foundation
import UIKit
import Combine

protocol APIServiceProtocol {
    func fetchStyleTemplates() -> AnyPublisher<[StyleTemplate], Error>
    func generateImage(image: UIImage, styleId: String) -> AnyPublisher<UIImage, Error>
}
