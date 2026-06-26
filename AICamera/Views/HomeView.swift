import SwiftUI
import UIKit

// MARK: - Image Picker Source (Identifiable for .sheet(item:))

struct ImagePickerSource: Identifiable {
    let id = UUID()
    let sourceType: UIImagePickerController.SourceType
}

// MARK: - HomeView

struct HomeView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var generationViewModel: GenerationViewModel
    @State private var pickerSource: ImagePickerSource?
    @State private var showStylePreview = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 70))
                            .foregroundColor(.white)

                        Text("AI Camera")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("用 AI 创造独特风格的你")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    VStack(spacing: 20) {
                        Button {
                            pickerSource = ImagePickerSource(sourceType: .camera)
                        } label: {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                Text("拍照")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .foregroundColor(.purple)
                            .cornerRadius(28)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }

                        Button {
                            pickerSource = ImagePickerSource(sourceType: .photoLibrary)
                        } label: {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                Text("从相册选择")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 40)

                    Button {
                        appNavigation.navigate(to: .history)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("历史记录")
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 10)
                    }

                    Button {
                        showStylePreview = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("查看预设风格")
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                        .padding(.top, 4)
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $pickerSource) { source in
                ImagePicker(sourceType: source.sourceType) { image in
                    generationViewModel.selectImage(image)
                    appNavigation.navigate(to: .styleSelection)
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showStylePreview) {
                StylePreviewSheet(styles: generationViewModel.styleTemplates)
            }
        }
    }
}

// MARK: - Style Preview Sheet

struct StylePreviewSheet: View {
    let styles: [StyleTemplate]
    @Environment(\.dismiss) var dismiss

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(styles) { style in
                        StyleCard(style: style, isSelected: false)
                    }
                }
                .padding(16)
            }
            .navigationBarTitle("预设风格", displayMode: .inline)
            .navigationBarItems(trailing: Button("关闭") { dismiss() })
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
