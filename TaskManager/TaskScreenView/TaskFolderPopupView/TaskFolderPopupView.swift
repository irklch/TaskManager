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
    let folders: [TaskFolderModel]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 30)
            
            // Header with title and close button
            HStack {
                Text("Папки")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.hex000101)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Folder list
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
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
        .background(Color.hexF2F2F2)
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
        folders: TaskFolderModel.sampleFolders
    )
}

