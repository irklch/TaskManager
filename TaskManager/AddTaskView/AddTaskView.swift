//
//  AddTaskView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import PhotosUI

struct AddTaskView: View {
    @ObservedObject var viewModel: AddTaskViewModel
    @Binding var isPresented: Bool
    @Binding var selectedFolder: TaskFolderNonDB
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, description
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Task Title
                    titleSection
                    
                    // Task Description
                    descriptionSection
                    
                    // Checklist
                    checklistSection
                    
                    // Attachments
                    attachmentsSection
                    
                    // Folder Selection
                    folderSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.hexF2F2F2)
            .navigationBarHidden(true)
            .overlay(
                // Custom Navigation Bar
                VStack {
                    customNavigationBar
                    Spacer()
                }
            )
            .overlay(
                // Bottom Action Bar
                VStack {
                    Spacer()
                    bottomActionBar
                }
            )
            .sheet(isPresented: $viewModel.showingImagePicker) {
                PhotosPicker(selection: $viewModel.selectedImageItem, matching: .images) {
                    EmptyView()
                }
                .onChange(of: viewModel.selectedImageItem) { newItem in
                    Task {
                        if let newItem = newItem {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                await MainActor.run {
                                    viewModel.setSelectedImage(image)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingFolderPicker) {
                folderPickerSheet
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Новая задача")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.hex000101)
            
            Text("Создайте задачу и организуйте свою работу")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Название задачи")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.hex000101)
            
            TextField("Введите название задачи", text: $viewModel.taskTitle)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.hex000101)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
                .focused($focusedField, equals: .title)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .title ? Color.hex316AFD : Color.clear, lineWidth: 2)
                )
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Описание")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.hex000101)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.taskDescription)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.hex000101)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .description)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .description ? Color.hex316AFD : Color.clear, lineWidth: 2)
                    )
                    .frame(minHeight: 100)
                
                if viewModel.taskDescription.isEmpty {
                    Text("Добавьте описание к задаче...")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
        }
    }
    
    // MARK: - Checklist Section
    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Чек-лист")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.hex000101)
                
                Spacer()
                
                Button(action: {
                    viewModel.addNewTaskStep()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.hex316AFD)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(Array(viewModel.taskSteps.enumerated()), id: \.offset) { index, step in
                    checklistItemView(step: step, index: index)
                }
            }
        }
    }
    
    private func checklistItemView(step: TaskStep, index: Int) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                viewModel.taskSteps[index].isCompleted.toggle()
            }) {
                Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(step.isCompleted ? .hex316AFD : .gray)
            }
            
            TextField("Новый пункт", text: $viewModel.taskSteps[index].title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(step.isCompleted ? .gray : .hex000101)
                .strikethrough(step.isCompleted)
                .onSubmit {
                    if !viewModel.taskSteps[index].title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.addNewTaskStep()
                    }
                }
            
            if viewModel.taskSteps.count > 1 {
                Button(action: {
                    viewModel.removeTaskStep(at: index)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    // MARK: - Attachments Section
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Вложения")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.hex000101)
            
            VStack(spacing: 12) {
                // Image Attachment
                if let selectedImage = viewModel.selectedImage {
                    HStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Изображение")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.hex000101)
                            
                            Text("\(Int(selectedImage.size.width)) × \(Int(selectedImage.size.height))")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.setSelectedImage(nil)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Add Attachment Button
                Button(action: {
                    viewModel.showImagePicker()
                }) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 20))
                            .foregroundColor(.hex316AFD)
                        
                        Text("Добавить изображение")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.hex316AFD)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.hex316AFD.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Folder Section
    private var folderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Папка")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.hex000101)
            
            Button(action: {
                viewModel.showFolderPicker()
            }) {
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.hex316AFD)
                    
                    Text(selectedFolder.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.hex000101)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Custom Navigation Bar
    private var customNavigationBar: some View {
                    HStack {
                            Button(action: {
                isPresented = false
                            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.hex000101)
                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            Text("Новая задача")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.hex000101)
            
            Spacer()
            
                            Button(action: {
                                viewModel.saveTask()
                                isPresented = false
                            }) {
                Text("Сохранить")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(viewModel.isSaveButtonEnabled ? .white : .gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(viewModel.isSaveButtonEnabled ? Color.hex316AFD : Color.gray.opacity(0.3))
                    .cornerRadius(20)
            }
            .disabled(!viewModel.isSaveButtonEnabled)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        HStack(spacing: 16) {
            // Add Image Button
            Button(action: {
                viewModel.showImagePicker()
            }) {
                Image(systemName: "photo")
                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.hex316AFD)
                    .frame(width: 50, height: 50)
                                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            // Add Checklist Item Button
            Button(action: {
                viewModel.addNewTaskStep()
            }) {
                Image(systemName: "checklist")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.hex316AFD)
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            // Save Button
            Button(action: {
                viewModel.saveTask()
                isPresented = false
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Сохранить")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(viewModel.isSaveButtonEnabled ? Color.hex316AFD : Color.gray.opacity(0.3))
                .cornerRadius(25)
                .shadow(color: viewModel.isSaveButtonEnabled ? Color.hex316AFD.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            }
            .disabled(!viewModel.isSaveButtonEnabled)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
    }
    
    // MARK: - Folder Picker Sheet
    private var folderPickerSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Выберите папку")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.hex000101)
                    
                    Text("Выберите папку для новой задачи")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Folder List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.folders, id: \.id) { folder in
                            Button(action: {
                                viewModel.selectFolder(folder)
                                selectedFolder = folder
                            }) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.hex316AFD)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(folder.name)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.hex000101)
                                        
                                        Text("\(folder.taskCount) задач")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedFolder.id == folder.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.hex316AFD)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if folder.id != viewModel.folders.last?.id {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                }
                .background(Color.hexF2F2F2)
            }
            .background(Color.hexF2F2F2)
            .navigationBarHidden(true)
            .overlay(
                VStack {
                    HStack {
                        Button(action: {
                            viewModel.hideFolderPicker()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.hex000101)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .cornerRadius(22)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            )
        }
    }
}

#Preview {
    AddTaskView(
        viewModel: AddTaskViewModel(
            context: PersistenceController.preview.container.viewContext,
            selectedFolder: .getTemplate()
        ),
        isPresented: .constant(true),
        selectedFolder: .constant(.getTemplate())
    )
}