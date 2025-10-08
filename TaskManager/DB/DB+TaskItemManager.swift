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
                    print("Folder not found in database")
                    return []
                }
                
                // Теперь ищем задачи, связанные с этой папкой
                let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
                request.predicate = NSPredicate(format: "folder == %@", dbFolder)
                request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskItem.createdAt, ascending: false)]
                
                return try context.fetch(request).map({ .init(model: $0) })
            } catch {
                print("Failed to fetch tasks: \(error)")
                return []
            }
        }
        
        static func addNewTask(
            title: String,
            description: String,
            imageData: Data?,
            folder: TaskFolderNonDB,
            in context: NSManagedObjectContext
        ) {
            let newTask = TaskItem(context: context)
            newTask.id = UUID()
            newTask.title = title
            newTask.taskDescription = description
            newTask.imageData = imageData
            newTask.createdAt = Date()
            newTask.isCompleted = false
            newTask.folder = folder.getDBModel(in: context)
            
            do {
                try context.save()
            } catch {
                print("Failed to save task: \(error)")
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
    let folder: TaskFolderNonDB
    
    init(id: UUID, title: String, taskDescription: String, imageData: Data, createdAt: Date, isCompleted: Bool, folder: TaskFolderNonDB) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.imageData = imageData
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.folder = folder
    }
    
    init(model: TaskItem) {
        self.id = model.id ?? .init()
        self.title = model.title ?? ""
        self.taskDescription = model.taskDescription ?? ""
        self.imageData = model.imageData
        self.createdAt = model.createdAt ?? .init(timeIntervalSinceNow: .init())
        self.isCompleted = model.isCompleted
        if let folder = model.folder {
            self.folder = .init(model: folder)
        } else {
            self.folder = .getTemplate()
        }
    }
}
