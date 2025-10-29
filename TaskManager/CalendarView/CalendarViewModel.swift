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
    @Published var tasksForSelectedDate: [TaskItemViewModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupInitialDates()
        setupObservers()
        generateMockTasks()
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
        formatter.dateFormat = "EEEE"
        return formatter.string(from: getSelectedDate())
    }
    
    func getTasksCount() -> String {
        "6 meetings" // Mock data
    }
    
    private func generateMockTasks() {
        // Генерируем mock задачи для демонстрации
        let mockTasks = [
            ("10:00", "Daily Meeting", "10:00 - 10:45", "Task allocation and planning for the day"),
            ("11:00", "Daily Meeting", "10:00 - 10:45", "Task allocation and planning for the day"),
            ("12:00", "Daily Meeting", "10:00 - 10:45", "Task allocation and planning for the day"),
            ("13:00", "Daily Meeting", "10:00 - 10:45", "Task allocation and planning for the day")
        ]
        
        tasksForSelectedDate = mockTasks.map { time, title, timeInterval, description in
            TaskItemViewModel(
                title: title,
                timeInterval: timeInterval,
                description: description,
                progress: .init(
                    progressViewModel: .init(
                        tasksCount: 13,
                        doneTasksCount: 7,
                        doneTasksColor: .white)),
                isDone: false,
                style: .grayStyle,
                sideArrowViewModel: .init(
                    backgroundColor: .white,
                    arrowColor: .hex000101),
                onChangeDoneCheckbox: nil
            )
        }
    }
    
    func createTaskRowViewModel(for task: TaskItemViewModel, time: String) -> TaskRowViewModel {
        TaskRowViewModel(
            time: time,
            taskViewModel: task
        )
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
        dateMonthFormatter.dateFormat = "dd MMMM"
        let dayFormatter = DateFormatter()
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

