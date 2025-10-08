//
//  AddTaskView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import PhotosUI
import CoreData

struct AddTaskView: View {
    @StateObject var viewModel: AddTaskViewModel
    @Binding var isPresented: Bool
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    
    var body: some View {
        ZStack {
                VStack(spacing: 0) {
                    // Header with close button
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.hex316AFD)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                    }
                    
                    // Content - fields at the top
                    VStack(spacing: 20) {
                        // Title field
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Название задачи", text: $viewModel.taskTitle)
                                .font(.title2)
                                .foregroundColor(.hex000101)
                                .focused($isTitleFocused)
                                .padding(.horizontal, 20)
                        }
                        
                        // Description field
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Добавьте описание...", text: $viewModel.taskDescription, axis: .vertical)
                                .font(.body)
                                .foregroundColor(.hex000101)
                                .focused($isDescriptionFocused)
                                .lineLimit(5...10)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .background(Color.hexF2F2F2)
                
                // Bottom buttons - attached to keyboard
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Attachment button
                            Button(action: {
                                viewModel.showingImagePicker = true
                            }) {
                                Image(systemName: "paperclip")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.hex000101)
                                    .frame(width: 30, height: 30)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.gray.opacity(0.7), lineWidth: 1)
                                    )
                                    .clipShape(Circle())
                            }
                            
                            // Save button
                            Button(action: viewModel.saveTask) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.hex316AFD)
                                    .frame(width: 30, height: 30)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.gray.opacity(0.7), lineWidth: 1)
                                    )
                                    .clipShape(Circle())
                            }
                            .disabled(viewModel.taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .opacity(viewModel.taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage)
        }
        .onAppear {
            isTitleFocused = true
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
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
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    AddTaskView(
        viewModel: .init(
            context: PersistenceController.preview.container.viewContext,
            selectedFolder: DB.TaskFolderManager.getSelectedFolder(in: PersistenceController.preview.container.viewContext)),
        isPresented: .constant(true)
    )
}
