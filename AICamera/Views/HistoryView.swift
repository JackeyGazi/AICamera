import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @State private var selectedItem: GeneratedImage?
    @State private var isEditing = false
    @State private var selectedIds = Set<String>()

    private let hPadding: CGFloat = 20
    private let spacing: CGFloat = 16

    private var cardWidth: CGFloat {
        (UIScreen.main.bounds.width - hPadding * 2 - spacing) / 2
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()

                if historyViewModel.isLoading {
                    ProgressView("加载中...")
                } else if historyViewModel.historyItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("暂无历史记录")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        Text("快去生成你的第一张 AI 头像吧")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(stride(from: 0, to: historyViewModel.historyItems.count, by: 2)), id: \.self) { startIndex in
                                HStack(spacing: spacing) {
                                    // 左侧卡片
                                    HistoryCard(
                                        item: historyViewModel.historyItems[startIndex],
                                        cardWidth: cardWidth,
                                        isEditing: isEditing,
                                        isSelected: selectedIds.contains(historyViewModel.historyItems[startIndex].id),
                                        onTap: {
                                            if isEditing {
                                                toggleSelection(historyViewModel.historyItems[startIndex].id)
                                            } else {
                                                selectedItem = historyViewModel.historyItems[startIndex]
                                            }
                                        },
                                        onDelete: {
                                            historyViewModel.deleteItems(ids: [historyViewModel.historyItems[startIndex].id])
                                        }
                                    )

                                    // 右侧卡片或占位
                                    if startIndex + 1 < historyViewModel.historyItems.count {
                                        HistoryCard(
                                            item: historyViewModel.historyItems[startIndex + 1],
                                            cardWidth: cardWidth,
                                            isEditing: isEditing,
                                            isSelected: selectedIds.contains(historyViewModel.historyItems[startIndex + 1].id),
                                            onTap: {
                                                if isEditing {
                                                    toggleSelection(historyViewModel.historyItems[startIndex + 1].id)
                                                } else {
                                                    selectedItem = historyViewModel.historyItems[startIndex + 1]
                                                }
                                            },
                                            onDelete: {
                                                historyViewModel.deleteItems(ids: [historyViewModel.historyItems[startIndex + 1].id])
                                            }
                                        )
                                    } else {
                                        Spacer()
                                            .frame(width: cardWidth)
                                    }
                                }
                                .padding(.horizontal, hPadding)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitle("历史记录", displayMode: .inline)
            .navigationBarItems(
                leading: isEditing
                    ? AnyView(Button(action: batchDelete) {
                        Text("删除")
                            .foregroundColor(selectedIds.isEmpty ? .gray : .red)
                    }
                    .disabled(selectedIds.isEmpty))
                    : AnyView(Button(action: { appNavigation.goBack() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }),
                trailing: isEditing
                    ? AnyView(Button("取消") {
                        withAnimation { isEditing = false }
                        selectedIds.removeAll()
                    })
                    : AnyView(Button("编辑") {
                        withAnimation { isEditing = true }
                    })
            )
            .sheet(item: $selectedItem) { item in
                HistoryDetailView(item: item)
            }
        }
    }

    private func toggleSelection(_ id: String) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }

    private func batchDelete() {
        guard !selectedIds.isEmpty else { return }
        historyViewModel.deleteItems(ids: selectedIds)
        selectedIds.removeAll()
        withAnimation { isEditing = false }
    }
}

// MARK: - History Card
struct HistoryCard: View {
    let item: GeneratedImage
    let cardWidth: CGFloat
    let isEditing: Bool
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    private let imageHeight: CGFloat = 170
    private let cornerRadius: CGFloat = 14

    var body: some View {
        ZStack(alignment: .bottom) {
            // 卡片基底（填满整体）
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

            // 预览图（固定尺寸，scaledToFill + clipped 裁切多余部分）
            Image(uiImage: item.generatedImage)
                .resizable()
                .scaledToFill()
                .frame(width: cardWidth, height: imageHeight)
                .clipped()

            // 底部液态玻璃信息栏
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName.isEmpty ? item.styleName : item.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(formatDate(item.createdAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    Rectangle().fill(.thinMaterial)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.25),
                            .white.opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )

            // 编辑模式选择圈（右下角最顶层）
            if isEditing {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                        .frame(width: 18, height: 18)

                    if isSelected {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 11, height: 11)
                    }
                }
                .padding(6)
                .shadow(color: .black.opacity(0.3), radius: 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: -1.5, y: -1.5)
            }
        }
        .frame(width: cardWidth, height: imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onTapGesture { onTap() }
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - History Detail
struct HistoryDetailView: View {
    let item: GeneratedImage
    @State private var showOriginal = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    Image(uiImage: showOriginal ? item.originalImage : item.generatedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation {
                                showOriginal.toggle()
                            }
                        }

                    Text("点击切换 / 原 / 效果")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 20)
                }
            }
            .navigationBarTitle(item.styleName, displayMode: .inline)
            .navigationBarItems(trailing: Button("关闭") {
                dismiss()
            })
        }
    }
}
