import SwiftUI

struct StyleSelectionView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var generationViewModel: GenerationViewModel

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let image = generationViewModel.selectedImage {
                            VStack(spacing: 12) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple, lineWidth: 3))
                                    .shadow(radius: 10)
                                    .padding(.horizontal, 16)

                                Text("选择你喜欢的风格")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .padding(.top, 20)
                        }

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(generationViewModel.styleTemplates) { style in
                                StyleCard(style: style, isSelected: generationViewModel.selectedStyle?.id == style.id)
                                    .onTapGesture {
                                        generationViewModel.selectStyle(style)
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }

                VStack {
                    Spacer()
                    Button(action: {
                        appNavigation.navigate(to: .generating)
                        generationViewModel.generate()
                    }) {
                        Text("开始生成")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                ZStack {
                                    // 液态玻璃背景
                                    RoundedRectangle(cornerRadius: 26)
                                        .fill(.regularMaterial)
                                        .environment(\.colorScheme, .light)

                                    // 玻璃光泽效果
                                    RoundedRectangle(cornerRadius: 26)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.5),
                                                    .white.opacity(0.2)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )

                                    // 浅色边框
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                }
                            )
                            .foregroundColor(.primary)
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                    }
                    .disabled(generationViewModel.selectedStyle == nil)
                    .opacity(generationViewModel.selectedStyle == nil ? 0.4 : 1.0)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitle("选择风格", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    appNavigation.goBack()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            )
        }
    }
}

struct StyleCard: View {
    let style: StyleTemplate
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [colorFromHex(style.color), colorFromHex(style.color).opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 80)

                Image(systemName: iconName(for: style.icon))
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }

            Text(style.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2.5)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }

    func iconName(for icon: String) -> String {
        switch icon {
        case "ink": return "paintbrush.pointed.fill"
        case "ancient": return "crown.fill"
        case "chibi": return "face.smiling.fill"
        case "anime": return "sparkles"
        case "doll3d": return "person.crop.circle.fill"
        case "cyberpunk": return "bolt.fill"
        case "goldplated": return "mountain.2.fill"
        default: return "paintpalette.fill"
        }
    }

    func colorFromHex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
}
