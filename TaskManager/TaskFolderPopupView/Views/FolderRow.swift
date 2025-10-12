//
//  FolderRow.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 12.10.2025.
//

import SwiftUI

struct FolderRow: View {
    let folder: TaskFolderNonDB
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // иконка
            ZStack {
                Circle().fill(isSelected ? .white.opacity(0.18) : .hexF2F2F2)
                Image(systemName: "folder.fill")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(isSelected ? .white : .hex316AFD)
            }
            .frame(width: 44, height: 44)

            // текст
            VStack(alignment: .leading, spacing: 4) {
                Text(folder.name)
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(isSelected ? .white : .hex000101)
            }

            Spacer()

            // счётчик «пилюля»
            CountPill(count: folder.tasks.count, isSelected: isSelected)

            // индикатор выбранной
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.leading, 4)
                    .transition(.scale)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.hex000101)
                    .opacity(0.9)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(isSelected ? Color.hex316AFD : Color.white)
        )
    }
}
