//
//  TaskFolderModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import Foundation

struct TaskFolderModel: Identifiable {
    let id = UUID()
    let name: String
    let taskCount: Int
}

extension TaskFolderModel {
    static let sampleFolders = [
        TaskFolderModel(name: "Все задачи", taskCount: 8),
        TaskFolderModel(name: "Рабочие", taskCount: 5),
        TaskFolderModel(name: "Личные", taskCount: 3),
        TaskFolderModel(name: "Покупки", taskCount: 2),
        TaskFolderModel(name: "Здоровье", taskCount: 1),
        TaskFolderModel(name: "Путешествия", taskCount: 0)
    ]
}
