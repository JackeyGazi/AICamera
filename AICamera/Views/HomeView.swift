import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var appNavigation: AppNavigation
    @EnvironmentObject var generationViewModel: GenerationViewModel
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    headerView
                    
                    Spacer()
                    
                    actionButtons
                    
                    Spacer()
                    
                    historyButton
                }
                .padding(.horizontal, 24)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera) { image in
                    handleImageSelected(image)
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showPhotoLibrary) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    handleImageSelected(image)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.aperture")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            Text("AI Camera")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
            
            Text("用 AI 重新定义你的照片")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 20) {
            Button(action: {
                showCamera = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                    Text("拍照")
                        .font(.title3.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .foregroundColor(.purple)
                .cornerRadius(28)
                .shadow(radius: 10)
            }
            
            Button(action: {
                showPhotoLibrary = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                    Text("从相册选择")
                        .font(.title3.weight(.semibold))
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
    }
    
    private var historyButton: some View {
        Button(action: {
            appNavigation.navigate(to: .history)
        }) {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                Text("历史记录")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.15))
            .cornerRadius(20)
        }
    }
    
    private func handleImageSelected(_ image: UIImage) {
        generationViewModel.setOriginalImage(image)
        appNavigation.navigate(to: .styleSelection)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
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
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
            if let image = image {
                parent.onImagePicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
