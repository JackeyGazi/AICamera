import Foundation
import UIKit
import SwiftUI
import Combine

class GenerationViewModel: ObservableObject {
    @Published var originalImage: UIImage?
    @Published var selectedStyle: StyleTemplate?
    @Published var generatedImage: GeneratedImage?
    @Published var isGenerating = false
    @Published var styleTemplates: [StyleTemplate] = []
    @Published var errorMessage: String?
    
    private let service: AIServiceProtocol
    
    init(service: AIServiceProtocol = MockDataService.shared) {
        self.service = service
        loadStyleTemplates()
    }
    
    func loadStyleTemplates() {
        service.fetchStyleTemplates { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let templates):
                self.styleTemplates = templates
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func setOriginalImage(_ image: UIImage) {
        self.originalImage = image
    }
    
    func selectStyle(_ style: StyleTemplate) {
        self.selectedStyle = style
    }
    
    func startGeneration() {
        guard let image = originalImage, let style = selectedStyle else { return }
        
        isGenerating = true
        errorMessage = nil
        
        service.generateImage(originalImage: image, style: style) { [weak self] result in
            guard let self = self else { return }
            self.isGenerating = false
            
            switch result {
            case .success(let generated):
                self.generatedImage = generated
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func reset() {
        originalImage = nil
        selectedStyle = nil
        generatedImage = nil
        isGenerating = false
        errorMessage = nil
    }
}
