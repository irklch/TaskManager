//
//  Task+CoreDataClass.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import Foundation
import CoreData
import UIKit

@objc(Task)
public class Task: NSManagedObject {
    
    // MARK: - Computed Properties
    
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    // MARK: - Convenience Methods
    
    static func createSampleTasks(in context: NSManagedObjectContext) {
        let sampleTasks = [
            ("UX Research", "Formulating design strategies on user data"),
            ("Design System", "Creating consistent design components"),
            ("User Testing", "Conducting usability tests with real users")
        ]
        
        // Get the "Рабочие" folder
        let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "Рабочие")
        
        do {
            let folders = try context.fetch(request)
            let folder = folders.first
            
            for (title, description) in sampleTasks {
                let task = Task(context: context)
                task.id = UUID()
                task.title = title
                task.taskDescription = description
                task.createdAt = Date()
                task.isCompleted = false
                task.folder = folder
            }
            
            try context.save()
        } catch {
            print("Error creating sample tasks: \(error)")
        }
    }
    
    static func fetchAll(in context: NSManagedObjectContext) -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    static func fetchByFolder(_ folder: TaskFolder?, in context: NSManagedObjectContext) -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        if let folder = folder {
            request.predicate = NSPredicate(format: "folder == %@", folder)
        } else {
            request.predicate = NSPredicate(format: "folder == nil")
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching tasks by folder: \(error)")
            return []
        }
    }
    
    static func createNew(title: String, description: String = "", imageData: Data? = nil, folder: TaskFolder?, in context: NSManagedObjectContext) -> Task {
        let task = Task(context: context)
        task.id = UUID()
        task.title = title
        task.taskDescription = description
        task.imageData = imageData
        task.createdAt = Date()
        task.isCompleted = false
        task.folder = folder
        
        do {
            try context.save()
        } catch {
            print("Error saving new task: \(error)")
        }
        
        return task
    }
}
