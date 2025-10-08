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
                return folders.map { TaskFolderNonDB(model: $0) }
            } catch {
                print("Failed to fetch folders: \(error)")
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
                print("Failed to fetch selected folder: \(error)")
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
            newFolder.tasks = .init(array: item.tasks)
            DB.save(in: context)
        }
        
        static func change(item: TaskFolderNonDB, in context: NSManagedObjectContext) {
            let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            
            do {
                guard let folder = try context.fetch(request).first else {
                    print("Failed to find folder with id: \(item.id)")
                    return
                }
                
                // Обновляем параметры объекта
                folder.name = item.name
                folder.isSelected = item.isSelected
                folder.tasks = NSSet(array: item.tasks)
                
                // Сохраняем изменения
                DB.save(in: context)
                
            } catch {
                print("Failed to update folder: \(error)")
            }
        }
        
        static func change(items: [TaskFolderNonDB], in context: NSManagedObjectContext) {
            let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
            do {
                let folders = try context.fetch(request)
                for item in items {
                    guard let selectedFolder = folders.first(where: { $0.id == item.id }) else {
                        continue
                    }
                    selectedFolder.name = item.name
                    selectedFolder.isSelected = item.isSelected
                    selectedFolder.tasks = NSSet(array: item.tasks)
                }
                
                DB.save(in: context)
                
            } catch {
                print("Failed to update folder: \(error)")
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
    var tasks: [TaskItem]
    
    init(id: UUID, name: String, isSelected: Bool, tasks: [TaskItem]) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
        self.tasks = tasks
    }
    
    init(model: TaskFolder) {
        self.id = model.id ?? .init()
        self.name = model.name ?? ""
        self.isSelected = model.isSelected
        self.tasks = (model.tasks?.allObjects as? [TaskItem]) ?? []
    }
    
    func getDBModel(in context: NSManagedObjectContext) -> TaskFolder {
        let model: TaskFolder = .init(context: context)
        model.id = self.id
        model.name = self.name
        model.isSelected = self.isSelected
        model.tasks = NSSet(array: self.tasks)
        return model
    }
}

extension TaskFolderNonDB {
    static func getTemplate() -> TaskFolderNonDB {
        return .init(id: .init(), name: "", isSelected: false, tasks: [])
    }
}
