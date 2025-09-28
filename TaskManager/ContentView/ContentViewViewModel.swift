//
//  ContentViewViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class ContentViewViewModel: ObservableObject {
    @Published var selectedIndex = 0
    @Published var isTabBarVisible = true
    @Published var showAddTask = false
    @Published var tasks: [Task] = []
    @Published var folders: [TaskFolder] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let persistenceController = PersistenceController.shared
    
    init() {
        setupFetchRequests()
    }
    
    private func setupFetchRequests() {
        let context = persistenceController.container.viewContext
        
        // Наблюдаем за изменениями задач
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .sink { [weak self] _ in
                self?.fetchTasks()
                self?.fetchFolders()
            }
            .store(in: &cancellables)
        
        // Первоначальная загрузка данных
        fetchTasks()
        fetchFolders()
    }
    
    private func fetchTasks() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)]
        
        do {
            tasks = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }
    
    private func fetchFolders() {
        let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskFolder.name, ascending: true)]
        
        do {
            folders = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch folders: \(error)")
        }
    }
    
    func handleScrollGesture(translation: CGSize) {
        let dy = translation.height
        
        // Скролл вниз (палец вверх, dy < 0) — скрыть таббар
        if dy < -50 && isTabBarVisible {
            isTabBarVisible = false
        }
        // Скролл вверх (палец вниз, dy > 0) — показать таббар
        else if dy > 50 && !isTabBarVisible {
            isTabBarVisible = true
        }
    }
    
    func showAddTaskView() {
        showAddTask = true
    }
    
    func hideAddTaskView() {
        showAddTask = false
    }
    
    var tabItems: [TabItemModel] {
        [
            TabItemModel(
                icon: "list.clipboard",
                title: "Задачи",
                view: AnyView(TaskScreenView(
                    tasks: tasks,
                    folders: folders))),
            TabItemModel(
                icon: "calendar",
                title: "Календарь",
                view: AnyView(CalendarView()))
        ]
    }
}
