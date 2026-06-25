import SwiftUI

struct ResultView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var generationViewModel: GenerationViewModel
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @State private var showingSaveAlert = false
    @State private var currentShowingOriginal = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    if let generated = generationViewModel.generatedImage {
                        imageComparisonView(generated)
                        
                        styleInfoView(generated)
                    }
                    
                    Spacer()
                    
                    actionButtons
                }
            }
            .navigationBarHidden(true)
            .alert("图片已保存", isPresented: $showingSaveAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text("图片已保存到您的相册")
            }
            .onAppear {
                if let generated = generationViewModel.generatedImage {
                    historyViewModel.addToHistory(generated)
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                generationViewModel.reset()
                appNavigation.navigate(to: .home)
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Text("生成结果")
                .font(.system(size: 18, weight: .semibold))
            
            Spacer()
            
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func imageComparisonView(_ generated: GeneratedImage) -> some View {
        VStack(spacing: 16) {
            ZStack {
                if let image = currentShowingOriginal ? generated.originalImage : generated.generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 350)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(currentShowingOriginal ? "原图" : "AI 生成")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(12)
                            .padding(12)
                    }
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentShowingOriginal.toggle()
                }
            }
            
            toggleHint
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
    
    private var toggleHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.tap")
            Text("点击图片切换原图/效果图")
        }
        .font(.system(size: 13))
        .foregroundColor(.secondary)
    }
    
    private func styleInfoView(_ generated: GeneratedImage) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(generated.styleTemplate.name)
                    .font(.system(size: 18, weight: .semibold))
                Text(generated.styleTemplate.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 14) {
            Button(action: {
                saveImage()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("保存到相册")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(26)
            }
            
            HStack(spacing: 14) {
                Button(action: {
                    shareImage()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("分享")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(UIColor.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(25)
                }
                
                Button(action: {
                    generationViewModel.reset()
                    appNavigation.navigate(to: .home)
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("再来一张")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(UIColor.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(25)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    private func saveImage() {
        guard let generated = generationViewModel.generatedImage,
              let image = generated.generatedImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showingSaveAlert = true
    }
    
    private func shareImage() {
        guard let generated = generationViewModel.generatedImage,
              let image = generated.generatedImage else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
