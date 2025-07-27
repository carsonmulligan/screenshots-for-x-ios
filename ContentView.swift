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
    @State private var cornerRadius: CGFloat = 0
    @State private var imageScale: CGFloat = 0.8
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingSaveAlert = false
    @State private var saveError = false
    @State private var useIOSStyle = false
    
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Preview Area
                ZStack {
                    selectedBackground.background
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxHeight: 400)
                        .overlay(
                            Group {
                                if let image = selectedImage {
                                    let frameWidth = UIScreen.main.bounds.width * imageScale
                                    let frameHeight = 300 * imageScale
                                    let minDimension = min(frameWidth, frameHeight)
                                    let radius = useIOSStyle ? minDimension * cornerRadius / 100 * 0.225 : cornerRadius * imageScale * 2
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: frameWidth, maxHeight: frameHeight)
                                        .clipShape(RoundedRectangle(cornerRadius: radius, style: useIOSStyle ? .continuous : .circular))
                                        .shadow(radius: 10)
                                } else {
                                    VStack {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("Tap to add screenshot")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                        )
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .onTapGesture {
                            showingImagePicker = true
                        }
                }
                .padding(.horizontal)
                
                // Add Image Button
                Button(action: { showingImagePicker = true }) {
                    Label(selectedImage == nil ? "Choose Screenshot" : "Change Screenshot", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Controls
                VStack(spacing: 15) {
                    // Background Selection
                    VStack(alignment: .leading) {
                        Text("Background")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(BackgroundOption.allCases, id: \.self) { option in
                                    VStack {
                                        option.background
                                            .frame(width: 60, height: 40)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedBackground == option ? Color.blue : Color.clear, lineWidth: 3)
                                            )
                                            .onTapGesture {
                                                selectedBackground = option
                                            }
                                        Text(option.rawValue)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Corner Radius Controls
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Corner Radius: \(Int(cornerRadius))")
                                .font(.headline)
                            Spacer()
                            Toggle("iOS Style", isOn: $useIOSStyle)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        Slider(value: $cornerRadius, in: 0...100)
                    }
                    
                    // Image Scale Slider
                    VStack(alignment: .leading) {
                        Text("Image Size: \(Int(imageScale * 100))%")
                            .font(.headline)
                        Slider(value: $imageScale, in: 0.3...1.0)
                    }
                    
                    // Export Button
                    Button(action: exportImage) {
                        Label("Save to Photos", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(selectedImage == nil)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Screenshots for X")
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { _ in
                Task {
                    if let item = selectedItem,
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
    
    func exportImage() {
        let renderer = ImageRenderer(content: 
            selectedBackground.background
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 2000, height: 2000)
                .overlay(
                    Group {
                        if let image = selectedImage {
                            let frameSize = 2000 * imageScale
                            let radius = useIOSStyle ? frameSize * cornerRadius / 100 * 0.225 : cornerRadius * imageScale * 20
                            
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: frameSize, maxHeight: frameSize)
                                .clipShape(RoundedRectangle(cornerRadius: radius, style: useIOSStyle ? .continuous : .circular))
                                .shadow(radius: 30)
                        }
                    }
                )
        )
        
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