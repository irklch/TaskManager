//
//  FolderPickerView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI

struct FolderPickerView: View {
    let folders: [TaskFolderNonDB]
    @Binding var selectedFolder: TaskFolderNonDB
    let onSelect: (TaskFolderNonDB) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(folders, id: \.id) { folder in
                Button(action: {
                    onSelect(folder)
                }) {
                    HStack {
                        Text(folder.name)
                            .font(.body)
                            .foregroundColor(.hex000101)
                        
                        Spacer()
                        
                        if selectedFolder.id == folder.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.hex316AFD)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                
                if folder.id != folders.last?.id {
                    Divider()
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

