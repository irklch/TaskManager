//
//  TaskStepView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI

struct TaskStepView: View {
    @Binding var taskStep: TaskStep
    let index: Int
    let onUpdate: (Int, String) -> Void
    let onRemove: (Int) -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Кружок для этапа
            Circle()
                .fill(taskStep.isCompleted ? Color.hex316AFD : Color.hexF2F2F2)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.hex316AFD, lineWidth: 2)
                )
                .onTapGesture {
                    taskStep.isCompleted.toggle()
                }
            
            // Поле ввода текста этапа
            TextField(
                TaskStep.placeholder,
                text: $taskStep.title,
                axis: .vertical
            )
            .focused($isFocused)
            .font(.body)
            .foregroundColor(taskStep.isEmpty ? .gray : .hex000101)
            .lineLimit(1...3)
            .onChange(of: taskStep.title) { newValue in
                onUpdate(index, newValue)
            }
            
            // Кнопка удаления (только если этапов больше одного)
            if index > 0 {
                Button(action: {
                    onRemove(index)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            isFocused = true
        }
    }
}

