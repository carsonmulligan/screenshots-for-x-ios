//
//  ContentView.swift
//  ScreenshotsForX
//
//  Created by Carson Mulligan on 7/27/25.
//

import SwiftUI
import PhotosUI


class ImageSaver: NSObject {
    var onComplete: ((Bool) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage, onComplete: @escaping (Bool) -> Void) {
        self.onComplete = onComplete
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        onComplete?(error == nil)
    }
}

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var selectedBackground = BackgroundOption.gradient1
    @State private var cornerRadius: CGFloat = 20
    @State private var imageScale: CGFloat = 0.75
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingSaveAlert = false
    @State private var saveError = false
    @State private var useIOSStyle = true
    @State private var isExporting = false
    
    enum BackgroundOption: String, CaseIterable {
        case gradient1 = "Blue"
        case gradient2 = "Purple"
        case gradient3 = "Sunset"
        case gradient4 = "Ocean"
        
        var background: some View {
            Group {
                switch self {
                case .gradient1:
                    LinearGradient(colors: [Color(red: 0.0, green: 0.4, blue: 0.8), Color(red: 0.0, green: 0.6, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
                case .gradient2:
                    LinearGradient(colors: [Color(red: 0.5, green: 0.0, blue: 0.8), Color(red: 0.8, green: 0.0, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                case .gradient3:
                    LinearGradient(colors: [Color(red: 1.0, green: 0.4, blue: 0.2), Color(red: 1.0, green: 0.2, blue: 0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                case .gradient4:
                    LinearGradient(colors: [Color(red: 0.0, green: 0.5, blue: 0.8), Color(red: 0.0, green: 0.8, blue: 0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            }
        }
    }
    
    func calculateRadius(for image: UIImage? = nil) -> CGFloat {
        if useIOSStyle {
            return cornerRadius * 1.5
        } else {
            return cornerRadius
        }
    }
    
    @ViewBuilder
    var imageOverlay: some View {
        if let image = selectedImage {
            let frameSize = UIScreen.main.bounds.width * imageScale * 0.7
            let radius = calculateRadius()
            let cornerStyle: RoundedCornerStyle = useIOSStyle ? .continuous : .circular
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: frameSize, maxHeight: frameSize)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: cornerStyle))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .scaleEffect(isExporting ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExporting)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolRenderingMode(.hierarchical)
                Text("Add Screenshot")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(0.15))
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
                // Header
                VStack(spacing: 4) {
                    Text("X Screenshots")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Text("Beautiful screenshots for X")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Preview Area
                ZStack {
                    selectedBackground.background
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(imageOverlay)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .onTapGesture {
                            if selectedImage == nil {
                                showingImagePicker = true
                            }
                        }
                }
                .frame(height: UIScreen.main.bounds.width * 0.75)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                // Controls Section
                VStack(spacing: 20) {
                    // Background Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Background")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(BackgroundOption.allCases, id: \.self) { option in
                                    VStack(spacing: 4) {
                                        option.background
                                            .frame(width: 56, height: 56)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .strokeBorder(
                                                        selectedBackground == option ? 
                                                        Color.blue : Color.white.opacity(0.2), 
                                                        lineWidth: selectedBackground == option ? 2.5 : 1
                                                    )
                                            )
                                            .scaleEffect(selectedBackground == option ? 0.95 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedBackground)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedBackground = option
                                                }
                                            }
                                        Text(option.rawValue)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(selectedBackground == option ? .blue : .white.opacity(0.6))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // Adjustments
                    HStack(spacing: 16) {
                        // Corner Radius
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Corners")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(Int(cornerRadius))")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            
                            Slider(value: $cornerRadius, in: 0...40)
                                .tint(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Image Size
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Size")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(Int(imageScale * 100))%")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            
                            Slider(value: $imageScale, in: 0.4...1.0)
                                .tint(.blue)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if selectedImage != nil {
                            Button(action: { showingImagePicker = true }) {
                                Label("Change Screenshot", systemImage: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            }
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isExporting = true
                            }
                            exportImage()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isExporting = false
                                }
                            }
                        }) {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(selectedImage != nil ? Color.blue : Color.gray.opacity(0.3))
                                )
                                .shadow(color: selectedImage != nil ? .blue.opacity(0.2) : .clear, 
                                       radius: 8, x: 0, y: 4)
                                .scaleEffect(isExporting ? 0.95 : 1.0)
                        }
                        .disabled(selectedImage == nil)
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 20)
            }
        .background(Color.black.ignoresSafeArea())
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let item = newValue,
                   let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
        .alert(saveError ? "Save Failed" : "Image Saved!", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(saveError ? "Failed to save image to Photos. Please check permissions." : "Your image has been saved to Photos successfully!")
        }
    }
    
    @ViewBuilder
    func exportContent() -> some View {
        selectedBackground.background
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 2000, height: 2000)
            .overlay(exportImageOverlay())
    }
    
    @ViewBuilder
    func exportImageOverlay() -> some View {
        if let image = selectedImage {
            let frameSize = 2000 * imageScale
            let exportScale = 2000.0 / UIScreen.main.bounds.width
            let radius = calculateRadius() * exportScale * 1.2
            let cornerStyle: RoundedCornerStyle = useIOSStyle ? .continuous : .circular
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: frameSize, maxHeight: frameSize)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: cornerStyle))
                .shadow(color: .black.opacity(0.2), radius: 60, x: 0, y: 30)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        }
    }
    
    func exportImage() {
        let renderer = ImageRenderer(content: exportContent())
        
        renderer.scale = 1.0
        
        if let uiImage = renderer.uiImage {
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: uiImage) { success in
                saveError = !success
                showingSaveAlert = true
            }
        }
    }
}

#Preview {
    ContentView()
}