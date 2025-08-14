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
    @State private var imageScale: CGFloat = 0.85
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingSaveAlert = false
    @State private var saveError = false
    @State private var useIOSStyle = true
    @State private var isExporting = false
    
    enum BackgroundOption: String, CaseIterable {
        case gradient1 = "Blue Gradient"
        case gradient2 = "Purple Gradient"
        case gradient3 = "Sunset Gradient"
        case gradient4 = "Ocean Gradient"
        case solid1 = "Dark Blue"
        case solid2 = "Purple"
        case solid3 = "Black"
        case solid4 = "White"
        
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
                case .solid1:
                    Color(red: 0.0, green: 0.2, blue: 0.5)
                case .solid2:
                    Color(red: 0.5, green: 0.0, blue: 0.5)
                case .solid3:
                    Color.black
                case .solid4:
                    Color.white
                }
            }
        }
    }
    
    func calculateRadius(for image: UIImage? = nil) -> CGFloat {
        // Fixed corner radius that doesn't scale with image size
        // This gives us actual rounded corners, not a circular shape
        if useIOSStyle {
            // iOS-style continuous corners
            return cornerRadius * 1.5
        } else {
            // Standard rounded corners
            return cornerRadius
        }
    }
    
    @ViewBuilder
    var imageOverlay: some View {
        if let image = selectedImage {
            let frameWidth = UIScreen.main.bounds.width * imageScale * 0.85
            let frameHeight = 300 * imageScale
            let radius = calculateRadius()
            let cornerStyle: RoundedCornerStyle = useIOSStyle ? .continuous : .circular
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: frameWidth, maxHeight: frameHeight)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: cornerStyle))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .scaleEffect(isExporting ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExporting)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "photo.stack")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolRenderingMode(.hierarchical)
                Text("Add Screenshot")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.1))
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Preview Area
                        ZStack {
                            selectedBackground.background
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxHeight: min(geometry.size.height * 0.4, 350))
                                .overlay(imageOverlay)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                                .onTapGesture {
                                    if selectedImage == nil {
                                        showingImagePicker = true
                                    }
                                }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                
                    // Add/Change Image Button
                    if selectedImage != nil {
                        Button(action: { showingImagePicker = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Change Screenshot")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.blue.opacity(0.1))
                                    .strokeBorder(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                    }
                
                        // Controls
                        VStack(spacing: 16) {
                            // Background Selection
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Background")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(BackgroundOption.allCases, id: \.self) { option in
                                            VStack(spacing: 4) {
                                                option.background
                                                    .frame(width: 64, height: 64)
                                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                            .strokeBorder(
                                                                selectedBackground == option ? 
                                                                Color.blue : Color.gray.opacity(0.2), 
                                                                lineWidth: selectedBackground == option ? 3 : 1
                                                            )
                                                    )
                                                    .shadow(color: .black.opacity(selectedBackground == option ? 0.1 : 0.05), 
                                                           radius: selectedBackground == option ? 6 : 3, 
                                                           x: 0, y: 2)
                                                    .scaleEffect(selectedBackground == option ? 0.95 : 1.0)
                                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedBackground)
                                                    .onTapGesture {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                            selectedBackground = option
                                                        }
                                                    }
                                                Text(option.rawValue)
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundColor(selectedBackground == option ? .blue : .secondary)
                                                    .lineLimit(1)
                                                    .frame(width: 64)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                    
                            // Corner Radius Controls
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Corner Radius")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("\(Int(cornerRadius)) pixels")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Toggle("", isOn: $useIOSStyle)
                                            .labelsHidden()
                                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                                            .scaleEffect(0.9)
                                        Text(useIOSStyle ? "Smooth" : "Standard")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 6)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.blue)
                                        .frame(width: max(6, CGFloat(cornerRadius) / 50 * (geometry.size.width - 64)), height: 6)
                                    
                                    Slider(value: $cornerRadius, in: 0...50)
                                        .tint(.clear)
                                }
                                .padding(.horizontal)
                            }
                    
                            // Image Scale Slider
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Image Size")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("\(Int(imageScale * 100))% of canvas")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 6)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.blue)
                                        .frame(width: max(6, CGFloat((imageScale - 0.3) / 0.7) * (geometry.size.width - 64)), height: 6)
                                    
                                    Slider(value: $imageScale, in: 0.3...1.0)
                                        .tint(.clear)
                                }
                                .padding(.horizontal)
                            }
                    
                            // Export Button
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
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Save to Photos")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(selectedImage != nil ? Color.blue : Color.gray.opacity(0.3))
                                )
                                .shadow(color: selectedImage != nil ? .blue.opacity(0.25) : .clear, 
                                       radius: 12, x: 0, y: 6)
                                .scaleEffect(isExporting ? 0.95 : 1.0)
                            }
                            .disabled(selectedImage == nil)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                }
                .navigationTitle("X Screenshots")
                .navigationBarTitleDisplayMode(.large)
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
            // Scale the corner radius appropriately for the export size
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