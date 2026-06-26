import SwiftUI

struct GeneratingView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var generationViewModel: GenerationViewModel
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.purple, .blue, .purple]),
                                center: .center
                            ),
                            lineWidth: 8
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                            value: isAnimating
                        )

                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 50))
                        .foregroundColor(.purple)
                }

                VStack(spacing: 12) {
                    Text("AI 正在创作中...")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("请稍候，很快就好")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let error = generationViewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text("生成失败")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("返回重试") {
                            appNavigation.goBack()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isAnimating = true
        }
        .onChange(of: generationViewModel.generatedImage) { _, newValue in
            if newValue != nil {
                appNavigation.navigate(to: .result)
            }
        }
    }
}
