//
//  DeadlinePickerView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI

struct DeadlinePickerView: View {
    @Binding var selectedDate: Date?
    @Binding var hasDeadline: Bool
    let onDateSelected: (Date) -> Void
    let onNoDateSelected: () -> Void
    
    @State private var tempDate = Date()
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок
            Text("Выберите дедлайн")
                .font(.headline)
                .foregroundColor(.hex000101)
                .padding(.top, 20)
            
            // Выбор даты
            DatePicker(
                "Дата",
                selection: $tempDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal, 20)
            
            // Кнопки действий
            HStack(spacing: 12) {
                // Кнопка "Без даты"
                Button(action: {
                    onNoDateSelected()
                }) {
                    Text("Без даты")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.hexF2F2F2)
                        .cornerRadius(8)
                }
                
                // Кнопка "Установить"
                Button(action: {
                    onDateSelected(tempDate)
                }) {
                    Text("Установить")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.hex316AFD)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onAppear {
            if let date = selectedDate {
                tempDate = date
            }
        }
    }
}

