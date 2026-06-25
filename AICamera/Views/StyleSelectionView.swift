import SwiftUI

struct StyleSelectionView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var generationViewModel: GenerationViewModel
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    if let image = generationViewModel.originalImage {
                        selectedImageView(image)
                    }
                    
                    styleList
                    
                    confirmButton
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                appNavigation.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Text("选择风格")
                .font(.system(size: 18, weight: .semibold))
            
            Spacer()
            
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func selectedImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .padding(.horizontal, 16)
            .cornerRadius(12)
            .padding(.bottom, 20)
    }
    
    private var styleList: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(generationViewModel.styleTemplates) { style in
                    StyleCardView(
                        style: style,
                        isSelected: generationViewModel.selectedStyle?.id == style.id
                    )
                    .onTapGesture {
                        generationViewModel.selectStyle(style)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    private var confirmButton: some View {
        Button(action: {
            guard generationViewModel.selectedStyle != nil else { return }
            generationViewModel.startGeneration()
            appNavigation.navigate(to: .generating)
        }) {
            Text("开始生成")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    if generationViewModel.selectedStyle != nil {
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .foregroundColor(.white)
                .cornerRadius(26)
        }
        .disabled(generationViewModel.selectedStyle == nil)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

struct StyleCardView: View {
    let style: StyleTemplate
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            styleThumbnail
            VStack(alignment: .leading, spacing: 4) {
                Text(style.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text(style.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 3)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    private var styleThumbnail: some View {
        ZStack {
            Rectangle()
                .fill(thumbnailGradient)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(12)
            
            Image(systemName: styleIconName)
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    private var thumbnailGradient: LinearGradient {
        switch style.category {
        case .ink:
            return LinearGradient(colors: [.gray, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ancient:
            return LinearGradient(colors: [.red.opacity(0.8), .orange.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .chibi:
            return LinearGradient(colors: [.pink, .purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .anime:
            return LinearGradient(colors: [.blue, .cyan.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .doll3D:
            return LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cyberpunk:
            return LinearGradient(colors: [.purple, .pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var styleIconName: String {
        switch style.category {
        case .ink:
            return "paintbrush.pointed"
        case .ancient:
            return "building.columns"
        case .chibi:
            return "face.smiling"
        case .anime:
            return "sparkles"
        case .doll3D:
            return "cube"
        case .cyberpunk:
            return "bolt"
        }
    }
}
