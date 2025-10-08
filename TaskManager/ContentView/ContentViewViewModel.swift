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
    
    let viewContext: NSManagedObjectContext
    @Published var selectedFolder: TaskFolderNonDB = .getTemplate()
    
    lazy var tabItems: [TabItemModel] = {
        let taskScreenView: TaskScreenView = .init(viewModel: .init(
            selectedFolder: $selectedFolder,
            viewContext: viewContext))
        return [
            TabItemModel(
                icon: "list.clipboard",
                title: "Задачи",
                view: AnyView(taskScreenView)),
            TabItemModel(
                icon: "calendar",
                title: "Календарь",
                view: AnyView(CalendarView()))
        ]
    }()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        setupSelectedFolder()
    }
    
    private func setupSelectedFolder() {
        selectedFolder = DB.TaskFolderManager.getSelectedFolder(in: viewContext)
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
}
