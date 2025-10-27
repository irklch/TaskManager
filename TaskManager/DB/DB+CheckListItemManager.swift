//
//  DB+CheckListItemManager.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 12.10.2025.
//

import Foundation
import CoreData

extension DB {
    enum CheckListItemManager {
        static func addNewTask(
            title: String,
            description: String,
            isDone: Bool,
            in context: NSManagedObjectContext
        ) {
            let newTask = ChecklistItem(context: context)
            newTask.id = UUID()
            newTask.title = title
            newTask.isDone = isDone
            
            do {
                try context.save()
            } catch {
                return 
            }
            
        }
    }
}

struct CheckListItemNonDB: Identifiable {
    let id: UUID
    var title: String
    var isDone: Bool
    
    init(id: UUID, title: String, isDone: Bool) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
    
    init(model: ChecklistItem) {
        self.id = model.id ?? .init()
        self.title = model.title ?? ""
        self.isDone = model.isDone
    }
    
    func getDBModel(in context: NSManagedObjectContext) -> ChecklistItem {
        let model: ChecklistItem = .init(context: context)
        model.id = id
        model.title = title
        model.isDone = isDone
        return model
    }
}
