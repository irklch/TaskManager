//
//  TaskFolderPopupView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData

struct TaskFolderPopupView: View {
    @ObservedObject var viewModel: TaskFolderPopupViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Binding var isPresented: Bool
    @Binding var selectedFolder: TaskFolderNonDB
    
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
                    viewModel.isCreatingNewFolder = true
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
                    if viewModel.isCreatingNewFolder {
                        HStack(spacing: 12) {
                            // Folder icon
                            Image(systemName: "folder")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            // Text field for new folder name
                            TextField("Название папки", text: $viewModel.newFolderName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.hex000101)
                                .focused($isTextFieldFocused)
                                .onSubmit {
                                    if let newFolder = viewModel.createNewFolder(selectedFolder: selectedFolder) {
                                        selectedFolder = newFolder
                                        isPresented = false
                                    }
                                }
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Готово") {
                                            if let newFolder = viewModel.createNewFolder(selectedFolder: selectedFolder) {
                                                selectedFolder = newFolder
                                                isPresented = false
                                            }
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
                    
                    ForEach(viewModel.folders) { folder in
                        Button(action: {
                            if let updatedFolder = viewModel.selectFolder(currentFolder: selectedFolder, newFolder: folder) {
                                selectedFolder = updatedFolder
                            }
                            isPresented = false
                        }) {
                            HStack(spacing: 12) {
                                if selectedFolder.id == folder.id {
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
                                Text("\(folder.tasks.count)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if folder.id != viewModel.folders.last?.id {
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
    
}

extension TaskFolderPopupView {
    enum Offset {
        static let screenBorderOffset: CGFloat = 12.0
        static let titlesLeadingOffset: CGFloat = 18.0
    }
}

//#Preview {
//    TaskFolderPopupView(
//        viewModel: .init(viewContext: PersistenceController.preview.container.viewContext), isPresented: .constant(true), selectedFolder: .constant(.getTemplate()))
//}

