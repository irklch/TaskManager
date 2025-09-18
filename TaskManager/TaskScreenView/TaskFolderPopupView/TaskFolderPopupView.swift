//
//  TaskFolderPopupView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI

struct TaskFolderPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedFolder: TaskFolderModel
    @Binding var folders: [TaskFolderModel]
    @State private var isCreatingNewFolder = false
    @State private var newFolderName = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 30)
            
            // Header with title and plus button
            HStack {
                Text("Папки")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundColor(.hex000101)
                
                Spacer()
                
                Button(action: {
                    isCreatingNewFolder = true
                    newFolderName = ""
                    isTextFieldFocused = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.hex000101)
                        .frame(width: 54, height: 54)
                        .background(.hexF2F2F2)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Folder list
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    // New folder creation row
                    if isCreatingNewFolder {
                        HStack(spacing: 12) {
                            // Folder icon
                            Image(systemName: "folder")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            // Text field for new folder name
                            TextField("Название папки", text: $newFolderName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.hex000101)
                                .focused($isTextFieldFocused)
                                .onSubmit {
                                    createNewFolder()
                                }
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Готово") {
                                            createNewFolder()
                                        }
                                        .foregroundColor(.hex316AFD)
                                        .fontWeight(.medium)
                                    }
                                }
                            
                            Spacer()
                            
                            // Task count
                            Text("0")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(width: 20)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.1))
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray.opacity(0.3))
                                .padding(.leading, 52)
                        )
                    }
                    
                    ForEach(folders) { folder in
                        Button(action: {
                            selectedFolder.isSelected = false
                            folder.isSelected = true
                            selectedFolder = folder
                            isPresented = false
                        }) {
                            HStack(spacing: 12) {
                                if folder.isSelected {
                                    // Folder icon
                                    Image(systemName: "folder")
                                        .font(.system(size: 16))
                                        .foregroundColor(.hex316AFD)
                                        .frame(width: 20)
                                    
                                    // Folder name
                                    Text(folder.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.hex316AFD)
                                } else {
                                    // Folder icon
                                    Image(systemName: "folder")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .frame(width: 20)
                                    
                                    // Folder name
                                    Text(folder.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.hex000101)
                                }
                                
                                Spacer()
                                
                                // Task count
                                Text("\(folder.taskCount)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if folder.id != folders.last?.id {
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.leading, 52)
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .onTapGesture {
            // Закрыть клавиатуру при тапе вне текстового поля
            isTextFieldFocused = false
        }
    }
    
    private func createNewFolder() {
        guard !newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let newFolder = TaskFolderModel(
            name: newFolderName.trimmingCharacters(in: .whitespacesAndNewlines),
            taskCount: 0,
            isSelected: false
        )
        
        // Снимаем выделение с текущей папки
        selectedFolder.isSelected = false
        
        // Добавляем новую папку в начало списка
        folders.insert(newFolder, at: 0)
        
        // Выбираем новую папку
        newFolder.isSelected = true
        selectedFolder = newFolder
        
        // Скрываем поле создания
        isCreatingNewFolder = false
        newFolderName = ""
        isTextFieldFocused = false
        
        // Закрываем попап
        isPresented = false
    }
}

extension TaskFolderPopupView {
    enum Offset {
        static let screenBorderOffset: CGFloat = 12.0
        static let titlesLeadingOffset: CGFloat = 18.0
    }
}

#Preview {
    TaskFolderPopupView(
        isPresented: .constant(true),
        selectedFolder: .constant(TaskFolderModel.sampleFolders[1]),
        folders: .constant(TaskFolderModel.sampleFolders)
    )
}

