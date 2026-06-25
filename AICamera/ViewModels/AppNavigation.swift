import SwiftUI
import Combine

class AppNavigation: ObservableObject {
    @Published var currentPage: AppPage = .home
    
    enum AppPage: Hashable {
        case home
        case styleSelection
        case generating
        case result
        case history
    }
    
    func navigate(to page: AppPage) {
        currentPage = page
    }
    
    func goBack() {
        switch currentPage {
        case .styleSelection:
            currentPage = .home
        case .generating:
            currentPage = .styleSelection
        case .result:
            currentPage = .home
        case .history:
            currentPage = .home
        case .home:
            break
        }
    }
}
