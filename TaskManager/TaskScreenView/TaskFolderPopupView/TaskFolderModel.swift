//
//  TaskFolderModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import Foundation

final class TaskFolderModel: Identifiable {
    let id = UUID()
    let name: String
    let taskCount: Int
    var isSelected: Bool
    
    init(name: String, taskCount: Int, isSelected: Bool) {
        self.name = name
        self.taskCount = taskCount
        self.isSelected = isSelected
    }
}

extension TaskFolderModel {
    static let sampleFolders = [
        TaskFolderModel(name: "Все задачи", taskCount: 8, isSelected: false),
        TaskFolderModel(name: "Рабочие", taskCount: 5, isSelected: true),
        TaskFolderModel(name: "Личные", taskCount: 3, isSelected: false),
        TaskFolderModel(name: "Покупки", taskCount: 2, isSelected: false),
        TaskFolderModel(name: "Здоровье", taskCount: 1, isSelected: false),
        TaskFolderModel(name: "Путешествия", taskCount: 0, isSelected: false)
    ]
}
