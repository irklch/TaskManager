//
//  TaskFolderPopupView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI

struct TaskFolderPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedFolder: String
    let folders: [TaskFolderModel]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text("Все папки")
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .padding(.leading, Offset.titlesLeadingOffset)
                    
                    VStack(alignment: .leading) {
                        ForEach(folders) { folder in
                            Button(action: {
                                selectedFolder = folder.name
                                isPresented = false
                            }) {
                                HStack {
                                    Text(folder.name)
                                        .foregroundColor(.hex000101)
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text("\(folder.taskCount)")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                                .padding(.horizontal, Offset.screenBorderOffset)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, Offset.screenBorderOffset)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 150)
            }
            .background(Color.hexF2F2F2)
        }
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
        selectedFolder: .constant("All Tasks"),
        folders: TaskFolderModel.sampleFolders
    )
}
