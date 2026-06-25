import SwiftUI

struct GeneratingView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var generationViewModel: GenerationViewModel
    @State private var animationPhase = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                loadingAnimation
                
                Text("AI 正在创作中...")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(generationViewModel.selectedStyle?.name ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                
                progressText
                
                Spacer()
                
                cancelButton
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            startAnimation()
        }
        .onChange(of: generationViewModel.isGenerating) { newValue in
            if !newValue && generationViewModel.generatedImage != nil {
                appNavigation.navigate(to: .result)
            }
        }
    }
    
    private var loadingAnimation: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                .frame(width: 120, height: 120)
            
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.white, .white.opacity(0.5)]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(Angle(degrees: Double(animationPhase) * 30))
            
            Image(systemName: "wand.and.stars")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
    
    private var progressText: some View {
        Text("大约需要 5-10 秒，请稍候")
            .font(.system(size: 14))
            .foregroundColor(.white.opacity(0.6))
    }
    
    private var cancelButton: some View {
        Button(action: {
            appNavigation.goBack()
        }) {
            Text("取消")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white.opacity(0.15))
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.bottom, 20)
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                animationPhase += 1
            }
        }
    }
}
