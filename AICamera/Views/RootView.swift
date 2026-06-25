import SwiftUI

struct RootView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    
    var body: some View {
        ZStack {
            switch appNavigation.currentPage {
            case .home:
                HomeView()
                    .transition(.opacity)
            case .styleSelection:
                StyleSelectionView()
                    .transition(.move(edge: .trailing))
            case .generating:
                GeneratingView()
                    .transition(.opacity)
            case .result:
                ResultView()
                    .transition(.move(edge: .trailing))
            case .history:
                HistoryView()
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appNavigation.currentPage)
    }
}
