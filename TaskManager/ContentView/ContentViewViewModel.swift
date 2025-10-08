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
