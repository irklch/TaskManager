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
    
    private var header: some View {
        HStack(spacing: 12) {
            Text("Папки")
                .font(.system(size: 34, weight: .light))
                .foregroundColor(.hex000101)

            Spacer()

            Button {
                viewModel.isCreatingNewFolder = true
                isTextFieldFocused = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.hex316AFD)
                    .padding(14)
                    .background(Circle().fill(.white))
            }
        }
        .padding(.vertical, 6)
    }
    
    var body: some View {
        
            ZStack {
                Color.hexF2F2F2.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        header

                        if viewModel.isCreatingNewFolder {
                            FolderInputRow(
                                newFolderName: $viewModel.newFolderName,
                                onSubmit: {
                                    if let newFolder = viewModel.createNewFolder(selectedFolder: selectedFolder) {
                                        selectedFolder = newFolder
                                        isPresented = false
                                    }
                                }).focused($isTextFieldFocused)
                        }
                        
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.folders) { folder in
                                FolderRow(
                                    folder: folder,
                                    isSelected: (folder.id == selectedFolder.id) && (viewModel.isCreatingNewFolder == false) )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                        if let updatedFolder = viewModel.selectFolder(currentFolder: selectedFolder, newFolder: folder) {
                                            selectedFolder = updatedFolder
                                        }
                                        isPresented = false
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .onTapGesture {
                // Закрыть клавиатуру при тапе вне текстового поля
                isTextFieldFocused = false
            }
    }
}
