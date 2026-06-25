import Foundation
import UIKit
import Combine

class HistoryViewModel: ObservableObject {
    @Published var historyItems: [GeneratedImage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: AIServiceProtocol
    
    init(service: AIServiceProtocol = MockDataService.shared) {
        self.service = service
        loadHistory()
    }
    
    func loadHistory() {
        isLoading = true
        errorMessage = nil
        
        service.fetchHistory { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let items):
                self.historyItems = items
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func addToHistory(_ generatedImage: GeneratedImage) {
        historyItems.insert(generatedImage, at: 0)
    }
}
