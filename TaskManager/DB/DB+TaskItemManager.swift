//
//  DB+TaskItemManager.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 30.09.2025.
//

import Foundation
import CoreData

extension DB {
    enum TaskItemManager {
        static func getItemsFrom(folder: TaskFolderNonDB, in context: NSManagedObjectContext) -> [TaskItemNonDB] {
            // Сначала находим реальный объект TaskFolder в базе данных
            let folderRequest: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
            folderRequest.predicate = NSPredicate(format: "id == %@", folder.id as CVarArg)
            
            do {
                guard let dbFolder = try context.fetch(folderRequest).first else {
                    print("❌ Folder not found in database with id: \(folder.id)")
                    return []
                }
                
                print("✅ Found folder: '\(dbFolder.name ?? "Unknown")' with id: \(dbFolder.id?.uuidString ?? "nil")")
                
                // Теперь ищем задачи, связанные с этой папкой
                let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
                request.predicate = NSPredicate(format: "folder == %@", dbFolder)
                request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskItem.createdAt, ascending: false)]
                
                let tasks = try context.fetch(request)
                print("📋 Found \(tasks.count) tasks in folder '\(dbFolder.name ?? "Unknown")'")
                
                // Также проверяем через relationship
                let tasksFromRelationship = (dbFolder.tasks?.allObjects as? [TaskItem]) ?? []
                print("📋 Tasks from relationship: \(tasksFromRelationship.count)")
                
                return tasks.map({ .init(model: $0) })
            } catch {
                print("❌ Failed to fetch tasks: \(error)")
                return []
            }
        }
        
        static func addNewTask(
            id: UUID,
            title: String,
            description: String,
            imageData: Data?,
            checklistItems: [CheckListItemNonDB],
            folder: TaskFolderNonDB,
            in context: NSManagedObjectContext
        ) {
            // Получаем существующую папку из БД
            guard let dbFolder = DB.TaskFolderManager.getFolder(in: context, with: folder.id) else {
                print("❌ Failed to find folder with id: \(folder.id)")
                return
            }
            
            // Создаем новую задачу
            let newTask = TaskItem(context: context)
            newTask.id = id
            newTask.title = title
            newTask.taskDescription = description
            newTask.imageData = imageData
            newTask.createdAt = Date()
            newTask.isCompleted = false
            newTask.folder = dbFolder  // Используем существующий объект из БД
            
            // Создаем элементы чеклиста
            let checklistItemsSet = NSMutableSet()
            for item in checklistItems {
                let checklistItem = ChecklistItem(context: context)
                checklistItem.id = item.id
                checklistItem.title = item.title
                checklistItem.isDone = item.isDone
                checklistItemsSet.add(checklistItem)
            }
            newTask.checklistItems = checklistItemsSet
            
            do {
                try context.save()
                print("✅ Task '\(title)' saved successfully to folder '\(dbFolder.name ?? "")'")
            } catch {
                print("❌ Failed to save task: \(error)")
            }
        }
    }
}

struct TaskItemNonDB: Identifiable {
    let id: UUID
    let title: String
    let taskDescription: String
    let imageData: Data?
    let createdAt: Date
    let isCompleted: Bool
    let folderID: UUID
    let checkListItems: [CheckListItemNonDB]
    
    init(id: UUID, title: String, taskDescription: String, imageData: Data, createdAt: Date, isCompleted: Bool, folderID: UUID, checkListItems: [CheckListItemNonDB]) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.imageData = imageData
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.folderID = folderID
        self.checkListItems = checkListItems
    }
    
    init(model: TaskItem) {
        self.id = model.id ?? .init()
        self.title = model.title ?? ""
        self.taskDescription = model.taskDescription ?? ""
        self.imageData = model.imageData
        self.createdAt = model.createdAt ?? .init(timeIntervalSinceNow: .init())
        self.isCompleted = model.isCompleted
        self.folderID = model.folder?.id ?? .init()
        let checkListItemModels = (model.checklistItems?.allObjects as? [ChecklistItem]) ?? []
        self.checkListItems = checkListItemModels.map({ .init(model: $0) })
    }
    
    func getDBModel(context: NSManagedObjectContext) -> TaskItem {
        let model: TaskItem = .init(context: context)
        model.id = id
        model.title = title
        model.taskDescription = taskDescription
        model.imageData = imageData
        model.createdAt = createdAt
        model.isCompleted = isCompleted
        model.folder = DB.TaskFolderManager.getFolder(in: context, with: folderID)
        model.checklistItems = NSSet(array: checkListItems.map({ $0.getDBModel(in: context) }))
        return model
    }
}
