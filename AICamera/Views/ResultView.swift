import SwiftUI

struct ResultView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var generationViewModel: GenerationViewModel
    @State private var showOriginal = false
    @State private var showSaveAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()

                VStack(spacing: 20) {
                    if let original = generationViewModel.selectedImage,
                       let generated = generationViewModel.generatedImage {
                        VStack(spacing: 16) {
                            Text(showOriginal ? "原图" : "效果图")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            ZStack {
                                Image(uiImage: showOriginal ? original : generated)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                                    .cornerRadius(20)
                                    .shadow(radius: 10)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showOriginal.toggle()
                                        }
                                    }
                            }

                            Text("点击图片切换查看")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)

                        if let style = generationViewModel.selectedStyle {
                            Text("风格：\(style.name)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                Button(action: {
                                    saveImage()
                                }) {
                                    Label("保存", systemImage: "square.and.arrow.down")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.purple.opacity(0.1))
                                        .foregroundColor(.purple)
                                        .cornerRadius(16)
                                }

                                Button(action: {
                                    shareImage()
                                }) {
                                    Label("分享", systemImage: "square.and.arrow.up")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(16)
                                }
                            }

                            Button(action: {
                                generationViewModel.reset()
                                appNavigation.navigate(to: .home)
                            }) {
                                Text("再来一张")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.purple, Color.blue]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(26)
                                    .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitle("生成结果", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    appNavigation.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            )
            .alert("保存成功", isPresented: $showSaveAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("图片已保存到相册")
            }
        }
    }

    private func saveImage() {
        guard let image = generationViewModel.generatedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSaveAlert = true
    }

    private func shareImage() {
        guard let image = generationViewModel.generatedImage else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
