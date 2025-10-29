//
//  CalendarView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 23.05.2024.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var timeInputText: String = ""

    var body: some View {
        VStack {
            getCalendarLineHStack()
            Spacer(minLength: 24)
            ScrollView(showsIndicators: false) {
                getDayVStack()
                getTimeSlotsView()
            }
            .background(Color.white)
            .cornerRadius(20)
            .edgesIgnoringSafeArea(.bottom)
        }
        .background(Color.hexF2F2F2)
    }
    
    private func setTime() {
        let trimmed = timeInputText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            viewModel.setManualTime(trimmed)
        }
    }

    private func getTimeSlotsView() -> some View {
        let minutesPerPixel: CGFloat = 2.0 // Константа для масштабирования
        let startHour = 10
        let startMinutes = startHour * 60
        
        return ZStack(alignment: .topLeading) {
//            // Вертикальная линия времени (задний план, фиксирована слева)
            timeScaleView(minutesPerPixel: minutesPerPixel)
                .padding(.leading, 16)
                .padding(.top, 16)
                .zIndex(1)
            
            
            // Линия текущего времени (поверх всего)
            currentTimeLineView(minutesPerPixel: minutesPerPixel, startMinutes: startMinutes)
                .zIndex(2)
            
            // Временные слоты с отступами между ними
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(viewModel.timeSlots.enumerated()), id: \.offset) { index, slot in
                    timeSlotView(slot: slot, minutesPerPixel: minutesPerPixel)
                }
            }
            .padding(.leading, 80)
            .padding(.trailing, 16)
            .padding(.top, 16)
            .zIndex(3)
            
        }
        .padding(.bottom, 100)
    }
    
    private func timeScaleView(minutesPerPixel: CGFloat) -> some View {
        let times = ["10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00"]
        let hourHeight = 60.0 * minutesPerPixel // Высота одного часа в пикселях
        
        // Вычисляем общую высоту всех слотов с учетом отступов (для синхронизации с VStack)
        let totalSlotsHeight = viewModel.timeSlots.reduce(0) { total, slot in
            total + CGFloat(slot.durationMinutes) * minutesPerPixel
        }
        let totalSpacing = CGFloat(max(0, viewModel.timeSlots.count - 1)) * 8 // 8px между каждым слотом
        let totalHeight = totalSlotsHeight + totalSpacing
        
        return VStack(alignment: .leading, spacing: 8) {
            ForEach(times, id: \.self) { time in
                Text(time)
                    .font(.system(size: 14))
                    .foregroundStyle(.hex000101)
                    .frame(height: hourHeight, alignment: .top)
            }
        }
        .frame(height: totalHeight, alignment: .top) // Выравниваем по высоте слотов + отступы
    }
    
    private func timeSlotView(slot: TimeSlot, minutesPerPixel: CGFloat) -> some View {
        let height = max(ceil(CGFloat(slot.durationMinutes) * minutesPerPixel), 0)
        
        return Group {
            switch slot {
            case .meeting(_, _, let task):
                TaskItemView(viewModel: task)
                    .frame(height: max(height, 80), alignment: .top)
                    
            case .empty:
                let maxHeight = max(height, 10)
                let safeDiagonalStripesHeight = maxHeight.isFinite ? maxHeight : 0

                DiagonalStripesShape()
                    .stroke(style:
                                StrokeStyle(
                                    lineWidth: 0.6))
                    .foregroundColor(.hex000101.opacity(0.7))
                    .background(.clear)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 18))
                    .padding(.leading, 2)
                    .frame(maxWidth: .infinity, maxHeight: safeDiagonalStripesHeight, alignment: .top)
                
            }
        }
    }
    
    private func currentTimeLineView(minutesPerPixel: CGFloat, startMinutes: Int) -> some View {
        let currentMinutes = viewModel.getCurrentTimeMinutes()
        
        // Проверяем, находится ли текущее время в отображаемом диапазоне (10:00 - 14:00)
        guard currentMinutes >= startMinutes && currentMinutes <= 14 * 60 else {
            return AnyView(EmptyView())
        }
        
        // Вычисляем позицию с учетом отступов между слотами
        // Нужно найти, в каком слоте находится время, и учесть все предыдущие слоты с отступами
        var accumulatedOffset: CGFloat = 0
        var found = false
        
        for (index, slot) in viewModel.timeSlots.enumerated() {
            let slotStartMinutes = slot.startMinutes
            let slotEndMinutes = slot.endMinutes
            
            if currentMinutes >= slotStartMinutes && currentMinutes <= slotEndMinutes {
                // Время находится внутри этого слота
                let offsetInSlot = CGFloat(currentMinutes - slotStartMinutes) * minutesPerPixel
                accumulatedOffset += offsetInSlot
                found = true
                break
            } else if currentMinutes > slotEndMinutes {
                // Переходим к следующему слоту
                accumulatedOffset += CGFloat(slot.durationMinutes) * minutesPerPixel
                if index < viewModel.timeSlots.count - 1 {
                    accumulatedOffset += 8 // Отступ между слотами
                }
            } else {
                // Время перед этим слотом - не должно отображаться
                return AnyView(EmptyView())
            }
        }
        
        guard found else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            HStack(spacing: 0) {
                // Кружок на линии времени (отступ для выравнивания с временной шкалой)
                Circle()
                    .fill(Color.hex316AFD)
                    .frame(width: 8, height: 8)
                    .padding(.leading, 16)
                
                // Горизонтальная линия
                Rectangle()
                    .fill(Color.hex316AFD)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
            .offset(x: 0, y: accumulatedOffset + 16)
        )
    }
    
    private func getDayVStack() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.getSelectedDateName())
                .foregroundStyle(.hex000101)
                .font(.system(size: 36, weight: .light))
            
            
            Text(viewModel.getTasksCount())
                .foregroundStyle(.gray)
                .font(.system(size: 12))
                .padding(.top, 8)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .top, .trailing], 16)
    }

    private func getCalendarLineHStack() -> some View {
        return HStack {
            Button(action: {
                viewModel.navigateToPreviousDate()
            }) {
                Image(systemName: "chevron.left")
            }
            .tint(Color.hex000101)
            Spacer()
            ForEach(viewModel.dates, id: \.self) { date in
                Button(action: {
                    viewModel.selectDate(at: date.index)
                }) {
                    if viewModel.isDateSelected(date) {
                        Text(date.numberWithMonth)
                            .font(.title3)
                            .foregroundStyle(.hexF2F2F2)
                            .padding([.top, .bottom], 7)
                            .padding([.leading, .trailing], 16)
                            .background(RoundedRectangle(cornerRadius: 20.0)
                                .tint(Color.hex316AFD))

                    } else {
                        Text(date.number)
                            .font(.title3)
                            .tint(Color.hex000101)
                    }
                }
                Spacer()
            }
            Button(action: {
                viewModel.navigateToNextDate()
            }) {
                Image(systemName: "chevron.right")
            }
            .tint(Color.hex000101)
        }
        .frame(maxWidth: .infinity)
        .padding([.leading, .trailing], 16)
    }
}
