import SwiftUI

struct RootView: View {
    @StateObject var appNavigation = AppNavigation()
    @StateObject var generationViewModel = GenerationViewModel(
        service: RealAPIService(
            baseURL: "https://ai-camegenerate-fzsqkpyixr.cn-hangzhou.fcapp.run",
            appSecret: "ai-camera-demo-20260626"
        )
    )
    @StateObject var historyViewModel = HistoryViewModel()

    var body: some View {
        ZStack {
            switch appNavigation.currentRoute {
            case .home:
                HomeView()
                    .environmentObject(appNavigation)
                    .environmentObject(generationViewModel)
                    .environmentObject(historyViewModel)
                    .transition(.opacity)
            case .styleSelection:
                StyleSelectionView()
                    .environmentObject(appNavigation)
                    .environmentObject(generationViewModel)
                    .transition(.move(edge: .trailing))
            case .generating:
                GeneratingView()
                    .environmentObject(appNavigation)
                    .environmentObject(generationViewModel)
                    .transition(.opacity)
            case .result:
                ResultView()
                    .environmentObject(appNavigation)
                    .environmentObject(generationViewModel)
                    .transition(.move(edge: .trailing))
            case .history:
                HistoryView()
                    .environmentObject(appNavigation)
                    .environmentObject(historyViewModel)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appNavigation.currentRoute)
        .onAppear {
            generationViewModel.onImageGenerated = { [weak historyViewModel] record in
                historyViewModel?.addItem(record)
            }
        }
    }
}
