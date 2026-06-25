import SwiftUI

@main
struct AICameraApp: App {
    @StateObject private var appNavigation = AppNavigation()
    @StateObject private var generationViewModel = GenerationViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appNavigation)
                .environmentObject(generationViewModel)
                .environmentObject(historyViewModel)
        }
    }
}
