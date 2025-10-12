//
//  FolderInputRow.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 12.10.2025.
//

import SwiftUI

struct FolderInputRow: View {
    @Binding var newFolderName: String
    var onSubmit: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // иконка
            ZStack {
                Circle().fill(.white.opacity(0.18))
                Image(systemName: "folder.fill")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.white )
            }
            .frame(width: 44, height: 44)

            // текст
            VStack(alignment: .leading, spacing: 4) {
                PlaceholderTextField(
                    placeholder: "Название папки",
                    font: .system(size: 18, weight: .light),
                    text: $newFolderName,
                    onSubmit: onSubmit,
                    placeholderColor: .white.opacity(0.5),
                    textColor: .white)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Готово") {
                            onSubmit()
                        }
                        .foregroundColor(.hex316AFD)
                        .fontWeight(.light)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.hex316AFD)
        )
    }
}
