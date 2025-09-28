//
//  TaskScreenViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class TaskScreenViewModel: ObservableObject {
    @Published var selectedFolder: TaskFolder?
    @Published var isPopupFolderVisible = false
    @Published var tasks: [Task] = []
    @Published var folders: [TaskFolder] = []
    @Published var doneTasksCount: Int = 0
    @Published var inProgressTasksCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private var context: NSManagedObjectContext?
    
    init(tasks: [Task], folders: [TaskFolder], context: NSManagedObjectContext? = nil) {
        self.tasks = tasks
        self.folders = folders
        self.selectedFolder = folders.first { $0.isSelected } ?? folders.first
        self.context = context
        
        setupObservers()
        calculateTaskCounts()
    }
    
    private func setupObservers() {
        // Наблюдаем за изменениями задач
        $tasks
            .sink { [weak self] _ in
                self?.calculateTaskCounts()
            }
            .store(in: &cancellables)
        
        // Наблюдаем за изменениями выбранной папки
        $selectedFolder
            .sink { [weak self] _ in
                self?.calculateTaskCounts()
            }
            .store(in: &cancellables)
    }
    
    private func calculateTaskCounts() {
        let filteredTasks = getFilteredTasks()
        
        doneTasksCount = filteredTasks.filter { $0.isCompleted }.count
        inProgressTasksCount = filteredTasks.filter { !$0.isCompleted }.count
    }
    
    func getFilteredTasks() -> [Task] {
        guard let selectedFolder = selectedFolder else {
            return tasks
        }
        return tasks.filter { $0.folder == selectedFolder }
    }
    
    func showFolderPopup() {
        isPopupFolderVisible = true
    }
    
    func hideFolderPopup() {
        isPopupFolderVisible = false
    }
    
    func selectFolder(_ folder: TaskFolder) {
        selectedFolder = folder
        hideFolderPopup()
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: date)
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Сегодня \(timeString)"
        } else if calendar.isDateInYesterday(date) {
            return "Вчера \(timeString)"
        } else {
            formatter.dateFormat = "MMM dd"
            let dateString = formatter.string(from: date)
            return "\(dateString) \(timeString)"
        }
    }
    
    func createTaskResultViewModel(for resultType: TaskResultViewModel.ResultType) -> TaskResultViewModel {
        let tasksCount = Double(getFilteredTasks().count)
        let doneCount = resultType == .doneTasks ? Double(doneTasksCount) : Double(inProgressTasksCount)
        
        return TaskResultViewModel(
            tasksCount: tasksCount,
            doneTasksCount: doneCount,
            resultType: resultType
        )
    }
    
    func createSideArrowViewModel() -> SideArrowViewModel {
        return SideArrowViewModel(
            backgroundColor: .hexF2F2F2,
            arrowColor: .hex000101
        )
    }
    
    func createTaskItemViewModel(for task: Task) -> TaskItemViewModel {
        let sideArrowVM = createSideArrowViewModel()
        
        return TaskItemViewModel(
            title: task.wrappedTitle,
            timeInterval: formatDate(task.wrappedCreatedAt),
            description: task.wrappedDescription,
            itemType: .checkbox,
            isDone: task.isCompleted,
            style: .whiteStyle,
            sideArrowViewModel: sideArrowVM
        )
    }
    
    func setContext(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    func refreshFolders() {
        guard let context = context else { return }
        
        let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskFolder.name, ascending: true)]
        
        do {
            let newFolders = try context.fetch(request)
            self.folders = newFolders
            
            // Обновляем selectedFolder если он больше не существует
            if let currentSelected = selectedFolder,
               !newFolders.contains(where: { $0.id == currentSelected.id }) {
                selectedFolder = newFolders.first { $0.isSelected } ?? newFolders.first
            }
        } catch {
            print("Failed to refresh folders: \(error)")
        }
    }
}
