import Foundation
import UIKit

struct GeneratedImage: Identifiable, Equatable {
    let id: String
    let originalImageData: Data
    let generatedImageData: Data
    let styleTemplate: StyleTemplate
    let createdAt: Date
    
    var originalImage: UIImage? {
        UIImage(data: originalImageData)
    }
    
    var generatedImage: UIImage? {
        UIImage(data: generatedImageData)
    }
}
