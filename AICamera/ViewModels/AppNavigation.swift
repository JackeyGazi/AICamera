import Foundation
import Combine
import SwiftUI

enum AppRoute: Hashable {
    case home
    case styleSelection
    case generating
    case result
    case history
}

final class AppNavigation: ObservableObject {
    @Published var currentRoute: AppRoute = .home

    func navigate(to route: AppRoute) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRoute = route
        }
    }

    func goBack() {
        switch currentRoute {
        case .styleSelection, .history:
            navigate(to: .home)
        case .generating, .result:
            navigate(to: .styleSelection)
        default:
            break
        }
    }
}
