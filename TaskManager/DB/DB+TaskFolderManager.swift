//
//  DB+TaskFolderManager.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 30.09.2025.
//

import Foundation
import CoreData

extension DB {
    enum TaskFolderManager {
        static func createPrimaryFolder(in context: NSManagedObjectContext) {
            let allFolders: [TaskFolderNonDB] = getAllFolders(in: context)
            
            guard allFolders.count == 0 else { return }
            
            let allTasksFolder: TaskFolder = .init(context: context)
            allTasksFolder.id = UUID()
            allTasksFolder.name = "Все задачи"
            allTasksFolder.isSelected = true
            
            DB.save(in: context)
        }
        
        static func getAllFolders(in context: NSManagedObjectContext) -> [TaskFolderNonDB] {
            let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskFolder.name, ascending: true)]
            do {
                let folders = try context.fetch(request)
                let nonDBFolders = folders.map { TaskFolderNonDB(model: $0) }
                return nonDBFolders
            } catch {
                return []
            }
        }
        
        static func getSelectedFolder(in context: NSManagedObjectContext) -> TaskFolderNonDB {
            let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
            request.predicate = NSPredicate(format: "isSelected == %@", NSNumber(value: true))
            do {
                guard let folder = try context.fetch(request).first else {
                    return .getTemplate()
                }
                return .init(model: folder)
            } catch {
                return .getTemplate()
            }
        }
        
        static func getFolder(in context: NSManagedObjectContext, with id: UUID) -> TaskFolder? {
            let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            do {
                guard let folder = try context.fetch(request).first else {
                    return nil
                }
                return folder
            } catch {
                return nil
            }
        }
        
        static func getFolderNonDB(in context: NSManagedObjectContext, with id: UUID) -> TaskFolderNonDB {
            if let model = getFolder(in: context, with: id) {
                return .init(model: model)
            } else {
                return .getTemplate()
            }
        }
        
        static func addNew(
            name: String,
            isSelected: Bool,
            in context: NSManagedObjectContext
        ) {
            let newFolder = TaskFolder(context: context)
            newFolder.id = UUID()
            newFolder.name = name
            newFolder.isSelected = isSelected
            newFolder.tasks = nil
            DB.save(in: context)
        }
        
        static func addNew(
            item: TaskFolderNonDB,
            in context: NSManagedObjectContext
        ) {
            let newFolder = TaskFolder(context: context)
            newFolder.id = item.id
            newFolder.name = item.name
            newFolder.isSelected = item.isSelected
            DB.save(in: context)
        }
        
        static func change(item: TaskFolderNonDB, in context: NSManagedObjectContext) {
            let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            
            do {
                guard let folder = try context.fetch(request).first else {
                    return
                }
                
                // Обновляем параметры объекта
                folder.name = item.name
                folder.isSelected = item.isSelected
                // tasks обновляются автоматически через relationship
                
                // Сохраняем изменения
                DB.save(in: context)
                
            } catch {
                return
            }
        }
        
        static func change(item: TaskFolder, in context: NSManagedObjectContext) {
            guard let id = item.id else { return }
            let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                guard let folder = try context.fetch(request).first else {
                    return
                }
                
                // Обновляем параметры объекта
                folder.name = item.name
                folder.isSelected = item.isSelected
                folder.tasks = item.tasks
                
                // Сохраняем изменения
                DB.save(in: context)
            } catch {
                return
            }
        }
    }
}

final class TaskFolderNonDB: Identifiable, Equatable {
    static func == (lhs: TaskFolderNonDB, rhs: TaskFolderNonDB) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID
    var name: String
    var isSelected: Bool
    var tasks: [TaskItemNonDB]
    
    init(id: UUID, name: String, isSelected: Bool, tasks: [TaskItemNonDB]) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
        self.tasks = tasks
    }
    
    init(model: TaskFolder) {
        self.id = model.id ?? .init()
        self.name = model.name ?? ""
        self.isSelected = model.isSelected
        self.tasks = ((model.tasks?.allObjects as? [TaskItem]) ?? []).map({ .init(model: $0) })
    }
    
    func getDBModel(in context: NSManagedObjectContext) -> TaskFolder {
        let model: TaskFolder = .init(context: context)
        model.id = self.id
        model.name = self.name
        model.isSelected = self.isSelected
        // tasks будут получены через relationship автоматически
        return model
    }
}

extension TaskFolderNonDB {
    static func getTemplate() -> TaskFolderNonDB {
        return .init(id: .init(), name: "", isSelected: false, tasks: [])
    }
}
