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
                    return []
                }
                
                // Теперь ищем задачи, связанные с этой папкой
                let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
                request.predicate = NSPredicate(format: "folder == %@", dbFolder)
                request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskItem.createdAt, ascending: false)]
                
                let tasks = try context.fetch(request)
                
                return tasks.map({ .init(model: $0) })
            } catch {
                return []
            }
        }
        
        static func addNewTask(
            model: TaskItemNonDB,
            in context: NSManagedObjectContext
        ) {
            // Получаем существующую папку из БД
            guard let dbFolder = DB.TaskFolderManager.getFolder(in: context, with: model.folderID) else {
                return
            }
            
            // Создаем новую задачу
            let newTask = model.getDBModel(folder: dbFolder, context: context)
            
            DB.save(in: context)
        }
        
        static func change(item: TaskItemNonDB, in context: NSManagedObjectContext) {
            let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            
            do {
                guard let model = try context.fetch(request).first,
                let dbFolder = DB.TaskFolderManager.getFolder(in: context, with: item.folderID) else {
                    return
                }
                
                model.title = item.title
                model.taskDescription = item.taskDescription
                model.isCompleted = item.isCompleted
                model.folder = dbFolder
                model.checklistItems = NSSet(array: item.checkListItems.map({ $0.getDBModel(in: context) }))
                model.images = NSSet(array: item.images.map({ $0.getDBModel(context: context) }))
                model.files = NSSet(array: item.files.map({ $0.getDBModel(context: context) }))
                
                // Сохраняем изменения
                DB.save(in: context)
                
            } catch {
                return
            }
        }
    }
}

struct TaskItemNonDB: Identifiable {
    let id: UUID
    var title: String
    var taskDescription: String
    var createdAt: Date
    var isCompleted: Bool
    var folderID: UUID
    var checkListItems: [CheckListItemNonDB]
    var images: [FileNonDB]
    var files: [FileNonDB]
    
    init(
        id: UUID,
        title: String,
        taskDescription: String,
        createdAt: Date,
        isCompleted: Bool,
        folderID: UUID,
        checkListItems: [CheckListItemNonDB],
        images: [FileNonDB],
        files: [FileNonDB]
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.folderID = folderID
        self.checkListItems = checkListItems
        self.images = images
        self.files = files
    }
    
    init(model: TaskItem) {
        self.id = model.id ?? .init()
        self.title = model.title ?? ""
        self.taskDescription = model.taskDescription ?? ""
        self.createdAt = model.createdAt ?? .init(timeIntervalSinceNow: .init())
        self.isCompleted = model.isCompleted
        self.folderID = model.folder?.id ?? .init()
        let checkListItemModels = (model.checklistItems?.allObjects as? [ChecklistItem]) ?? []
        self.checkListItems = checkListItemModels.map({ .init(model: $0) })
        let images = (model.images?.allObjects as? [File]) ?? []
        self.images = images.map({ .init(model: $0) })
        let files = (model.files?.allObjects as? [File]) ?? []
        self.files = files.map({ .init(model: $0) })
    }
    
    func getDBModel(
        folder: TaskFolder? = nil,
        context: NSManagedObjectContext
    ) -> TaskItem {
        let model: TaskItem = .init(context: context)
        model.id = id
        model.title = title
        model.taskDescription = taskDescription
        model.createdAt = createdAt
        model.isCompleted = isCompleted
        model.folder = folder ?? DB.TaskFolderManager.getFolder(in: context, with: folderID)
        model.checklistItems = NSSet(array: checkListItems.map({ $0.getDBModel(in: context) }))
        model.images = NSSet(array: images.map({ $0.getDBModel(context: context) }))
        model.files = NSSet(array: files.map({ $0.getDBModel(context: context) }))
        return model
    }
}
