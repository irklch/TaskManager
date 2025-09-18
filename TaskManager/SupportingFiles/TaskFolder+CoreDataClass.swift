//
//  TaskFolder+CoreDataClass.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import Foundation
import CoreData

@objc(TaskFolder)
public class TaskFolder: NSManagedObject {
    
    // MARK: - Computed Properties
    
    var taskCount: Int {
        return tasks?.count ?? 0
    }
    
    // MARK: - Convenience Methods
    
    static func createSampleFolders(in context: NSManagedObjectContext) {
        let sampleFolders = [
            ("Все задачи", false),
            ("Рабочие", true),
            ("Личные", false),
            ("Покупки", false),
            ("Здоровье", false),
            ("Путешествия", false)
        ]
        
        for (name, isSelected) in sampleFolders {
            let folder = TaskFolder(context: context)
            folder.id = UUID()
            folder.name = name
            folder.isSelected = isSelected
        }
        
        do {
            try context.save()
        } catch {
            print("Error creating sample folders: \(error)")
        }
    }
    
    static func fetchAll(in context: NSManagedObjectContext) -> [TaskFolder] {
        let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskFolder.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching folders: \(error)")
            return []
        }
    }
    
    static func fetchSelected(in context: NSManagedObjectContext) -> TaskFolder? {
        let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
        request.predicate = NSPredicate(format: "isSelected == YES")
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching selected folder: \(error)")
            return nil
        }
    }
}
