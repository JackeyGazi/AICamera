import Foundation
import UIKit
import Combine
import SwiftUI

final class GenerationViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedStyle: StyleTemplate?
    @Published var generatedImage: UIImage?
    @Published var isGenerating: Bool = false
    @Published var errorMessage: String?
    @Published var styleTemplates: [StyleTemplate] = []

    private let service: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // 生成成功后的回调，用于保存到历史记录
    var onImageGenerated: ((GeneratedImage) -> Void)?

    init(service: APIServiceProtocol = MockDataService()) {
        self.service = service
        loadStyleTemplates()
    }

    private func loadStyleTemplates() {
        service.fetchStyleTemplates()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] templates in
                    self?.styleTemplates = templates
                }
            )
            .store(in: &cancellables)
    }

    func selectImage(_ image: UIImage) {
        selectedImage = image
    }

    func selectStyle(_ style: StyleTemplate) {
        selectedStyle = style
    }

    func generate() {
        guard let image = selectedImage, let style = selectedStyle else {
            errorMessage = "请先选择图片和风格"
            return
        }

        isGenerating = true
        errorMessage = nil
        generatedImage = nil

        let styleName = style.name

        service.generateImage(image: image, styleId: style.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isGenerating = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] resultImage in
                    guard let self = self else { return }
                    self.generatedImage = resultImage

                    // 保存到历史记录
                    let record = GeneratedImage(
                        id: UUID().uuidString,
                        originalImage: image,
                        generatedImage: resultImage,
                        styleName: styleName,
                        createdAt: Date()
                    )
                    self.onImageGenerated?(record)
                }
            )
            .store(in: &cancellables)
    }

    func reset() {
        selectedImage = nil
        selectedStyle = nil
        generatedImage = nil
        isGenerating = false
        errorMessage = nil
    }
}
