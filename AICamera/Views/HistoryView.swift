import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @State private var selectedItem: GeneratedImage?
    let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    if historyViewModel.isLoading {
                        loadingView
                    } else if historyViewModel.historyItems.isEmpty {
                        emptyStateView
                    } else {
                        historyGridView
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedItem) { item in
                HistoryDetailView(generatedImage: item)
            }
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
            
            Text("历史记录")
                .font(.system(size: 18, weight: .semibold))
            
            Spacer()
            
            Button(action: {
                historyViewModel.loadHistory()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("加载中...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.top, 16)
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("暂无历史记录")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("生成的作品会保存在这里哦")
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.8))
            
            Button(action: {
                appNavigation.navigate(to: .home)
            }) {
                Text("去生成")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    private var historyGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(historyViewModel.historyItems) { item in
                    HistoryGridItemView(generatedImage: item)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .onTapGesture {
                            selectedItem = item
                        }
                }
            }
            .padding(3)
        }
    }
}

struct HistoryGridItemView: View {
    let generatedImage: GeneratedImage
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = generatedImage.generatedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            Text(generatedImage.styleTemplate.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .padding(6)
        }
    }
}

struct HistoryDetailView: View {
    let generatedImage: GeneratedImage
    @Environment(\.dismiss) private var dismiss
    @State private var showingOriginal = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    if let image = showingOriginal ? generatedImage.originalImage : generatedImage.generatedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    Spacer()
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingOriginal.toggle()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(generatedImage.styleTemplate.name)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}
