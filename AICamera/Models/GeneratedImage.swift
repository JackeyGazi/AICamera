import Foundation
import UIKit

struct GeneratedImage: Identifiable, Equatable {
    let id: String
    let originalImage: UIImage
    let generatedImage: UIImage
    let styleName: String
    let createdAt: Date
    var displayName: String = ""
}
