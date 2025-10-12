//
//  AddTaskViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData
import PhotosUI
import Combine

// MARK: - ViewModel
final class AddTaskViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var details: String = ""
    @Published var checklist: [ChecklistItem] = []
    @Published var newItemText: String = ""
    @Published var attachments: [Attachment] = []
    
    var isButtonEnabled: Bool {
        title != "" && details != ""
    }
    
    struct ChecklistItem: Identifiable, Hashable {
        let id = UUID()
        var text: String
        var isDone: Bool
    }

    struct Attachment: Identifiable {
        let id = UUID()
        var preview: Image
        var data: Data
    }

    func addChecklistItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        newItemText = ""
        guard !trimmed.isEmpty else {
            return
        }
        
        checklist.append(.init(text: trimmed, isDone: false))
    }

    func toggle(_ item: ChecklistItem) {
        if let i = checklist.firstIndex(of: item) {
            checklist[i].isDone.toggle()
        }
    }

    func delete(item: ChecklistItem) {
        checklist.removeAll{ $0.id == item.id }
    }
    
    func saveTask(folder: TaskFolderNonDB, context: NSManagedObjectContext) {
        // Преобразуем checklist в CheckListItemNonDB
        let checklistItemsNonDB = checklist.map { item in
            CheckListItemNonDB(id: item.id, title: item.text, isDone: item.isDone)
        }
        
        // Получаем данные первого изображения (если есть)
        let imageData = attachments.first?.data
        
        // Сохраняем задачу в базу данных
        DB.TaskItemManager.addNewTask(
            id: UUID(),
            title: title,
            description: details,
            imageData: imageData,
            checklistItems: checklistItemsNonDB,
            folder: folder,
            in: context
        )
        
        // Отправляем уведомление об добавлении задачи
        NotificationCenter.default.post(name: .taskAdded, object: nil)
    }
}

extension Notification.Name {
    static let taskAdded = Notification.Name("taskAdded")
}
