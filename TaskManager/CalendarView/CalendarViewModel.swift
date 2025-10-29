//
//  CalendarViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 23.05.2024.
//

import SwiftUI
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var selectedDateIndex: Int = 0
    @Published var dates: [DateFormat] = []
    @Published var timeSlots: [TimeSlot] = []
    @Published var manualCurrentTime: String? = "10:30" // Для ручной установки времени (формат "HH:mm")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupInitialDates()
        setupObservers()
        generateMockTimeSlots()
    }
    
    private func setupObservers() {
        $selectedDateIndex
            .sink { [weak self] newIndex in
                self?.updateDates(for: newIndex)
            }
            .store(in: &cancellables)
    }
    
    private func setupInitialDates() {
        dates = Self.getDates(newIndex: 0)
    }
    
    private func updateDates(for newIndex: Int) {
        dates = Self.getDates(newIndex: newIndex)
    }
    
    func navigateToPreviousDate() {
        selectedDateIndex -= 1
    }
    
    func navigateToNextDate() {
        selectedDateIndex += 1
    }
    
    func selectDate(at index: Int) {
        selectedDateIndex = index
    }
    
    func isDateSelected(_ date: DateFormat) -> Bool {
        date.index == selectedDateIndex
    }
    
    func getSelectedDate() -> Date {
        let today = Date()
        return Calendar.current.date(byAdding: .day, value: selectedDateIndex, to: today) ?? today
    }
    
    func getSelectedDateName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        let dayName = formatter.string(from: getSelectedDate())
        return dayName.prefix(1).uppercased() + dayName.dropFirst()
    }
    
    func getTasksCount() -> String {
        let meetingsCount = timeSlots.filter { $0.isMeeting }.count
        return "\(meetingsCount) meetings"
    }
    
    func getCurrentTime() -> String {
        if let manualTime = manualCurrentTime {
            return manualTime
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    func getCurrentTimeMinutes() -> Int {
        if let manualTime = manualCurrentTime {
            let components = manualTime.split(separator: ":")
            if components.count == 2,
               let hours = Int(components[0]),
               let minutes = Int(components[1]) {
                return hours * 60 + minutes
            }
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
    
    func setManualTime(_ time: String) {
        manualCurrentTime = time
    }
    
    func resetToRealTime() {
        manualCurrentTime = nil
    }
    
    private func generateMockTimeSlots() {
        // Согласно скриншоту:
        // 10:00 - 10:45: Daily Meeting (синяя)
        // 10:45 - 12:00: пустой слот
        // 12:00 - 12:50: Product Review (серая)
        // 12:50 - 13:00: пустой слот
        // 13:00 - 14:00: Design Optimization (серая)
        
        timeSlots = [
            .meeting(
                startTime: "10:00",
                endTime: "11:00",
                task: TaskItemViewModel(
                    title: "Ежедневный бриф",
                    timeInterval: "10:00 - 11:00",
                    description: "Посмотрим отчётность по всем задачам за неделю",
                    progress: nil,
                    isDone: false,
                    style: .blueStyle,
                    sideArrowViewModel: .init(
                        backgroundColor: .hex000101,
                        arrowColor: .hexF2F2F2),
                    onChangeDoneCheckbox: nil
                )
            ),
            .empty(startTime: "11:00", endTime: "11:30"),
            .meeting(
                startTime: "11:30",
                endTime: "12:30",
                task: TaskItemViewModel(
                    title: "Продуктовое ревью",
                    timeInterval: "11:30 - 12:30",
                    description: "Проанализируем текущие и заложим наброски на последующие",
                    progress: nil,
                    isDone: false,
                    style: .grayStyle,
                    sideArrowViewModel: .init(
                        backgroundColor: .white,
                        arrowColor: .hex000101),
                    onChangeDoneCheckbox: nil
                )
            ),
            .empty(startTime: "12:30", endTime: "13:00"),
            .meeting(
                startTime: "13:00",
                endTime: "14:00",
                task: TaskItemViewModel(
                    title: "Оптимизация с дизайнерами",
                    timeInterval: "13:00 - 14:00",
                    description: "Обсудим новые макеты",
                    progress: nil,
                    isDone: false,
                    style: .grayStyle,
                    sideArrowViewModel: .init(
                        backgroundColor: .white,
                        arrowColor: .hex000101),
                    onChangeDoneCheckbox: nil
                )),
                .meeting(
                    startTime: "14:00",
                    endTime: "15:00",
                    task: TaskItemViewModel(
                        title: "Ежемесячный отчётник",
                        timeInterval: "14:00 - 15:00",
                        description: "Анализ тенденций рынка",
                        progress: nil,
                        isDone: false,
                        style: .grayStyle,
                        sideArrowViewModel: .init(
                            backgroundColor: .white,
                            arrowColor: .hex000101),
                        onChangeDoneCheckbox: nil
                    )
            ),
                .empty(startTime: "15:00", endTime: "16:00")
        ]
    }
    
    static func getDates(newIndex: Int) -> [DateFormat] {
        return [
            .init(index: newIndex-1),
            .init(index: newIndex),
            .init(index: newIndex+1),
            .init(index: newIndex+2)
        ]
    }
}

// MARK: - Supporting Models

struct DateFormat: Hashable {
    let index: Int
    let number: String
    let numberWithMonth: String

    init(index: Int) {
        let today = Date()
        let calendar = Calendar.current
        let todateDay = calendar.date(byAdding: .day, value: index, to: today)!
        let dateMonthFormatter = DateFormatter()
        dateMonthFormatter.locale = Locale(identifier: "ru_RU")
        dateMonthFormatter.dateFormat = "dd MMMM"
        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "ru_RU")
        dayFormatter.dateFormat = "dd"
        self.number = dayFormatter.string(from: todateDay)
        self.numberWithMonth = dateMonthFormatter.string(from: todateDay)
        self.index = index
    }
}

struct TaskRowViewModel {
    let time: String
    let taskViewModel: TaskItemViewModel
}

enum TimeSlot {
    case meeting(startTime: String, endTime: String, task: TaskItemViewModel)
    case empty(startTime: String, endTime: String)
    
    var startTime: String {
        switch self {
        case .meeting(let start, _, _), .empty(let start, _):
            return start
        }
    }
    
    var endTime: String {
        switch self {
        case .meeting(_, let end, _), .empty(_, let end):
            return end
        }
    }
    
    var isMeeting: Bool {
        switch self {
        case .meeting:
            return true
        case .empty:
            return false
        }
    }
    
    var task: TaskItemViewModel? {
        switch self {
        case .meeting(_, _, let task):
            return task
        case .empty:
            return nil
        }
    }
    
    func timeInMinutes(_ time: String) -> Int {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return 0
        }
        return hours * 60 + minutes
    }
    
    var startMinutes: Int {
        timeInMinutes(startTime)
    }
    
    var endMinutes: Int {
        timeInMinutes(endTime)
    }
    
    var durationMinutes: Int {
        endMinutes - startMinutes
    }
}

