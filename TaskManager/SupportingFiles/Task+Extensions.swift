import Foundation
import CoreData
import SwiftUI

extension Task {
    public var wrappedTitle: String {
        title ?? "Unknown Task"
    }
    
    public var wrappedDescription: String {
        taskDescription ?? ""
    }
    
    public var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }
    
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var image: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }
    
    public static func createSampleTasks(in context: NSManagedObjectContext) {
        guard let allTasksFolder = TaskFolder.fetchAll(in: context).first(where: { $0.wrappedName == "Все задачи" }) else { return }
        
        let tasksData = [
            ("UX Research", "Formulating design strategies on user data", Date().addingTimeInterval(-3600 * 24 * 2), false),
            ("Feature Implementation", "Developing new features for an iOS application", Date().addingTimeInterval(-3600 * 5), true),
            ("Bug Fixing", "Identifying and fixing bugs reported by QA testers", Date().addingTimeInterval(-3600 * 24 * 7), true),
            ("Code Optimization", "Improving the performance", Date().addingTimeInterval(-3600 * 10), false)
        ]
        
        for (title, description, createdAt, isCompleted) in tasksData {
            let task = Task(context: context)
            task.id = UUID()
            task.title = title
            task.taskDescription = description
            task.createdAt = createdAt
            task.isCompleted = isCompleted
            task.folder = allTasksFolder
        }
    }
    
    public static func fetchAll(in context: NSManagedObjectContext) -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    public static func fetchByFolder(folder: TaskFolder, in context: NSManagedObjectContext) -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "folder == %@", folder)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch tasks for folder \(folder.wrappedName): \(error)")
            return []
        }
    }
    
    public static func createNew(title: String, description: String, imageData: Data?, folder: TaskFolder, in context: NSManagedObjectContext) -> Task {
        let newTask = Task(context: context)
        newTask.id = UUID()
        newTask.title = title
        newTask.taskDescription = description
        newTask.imageData = imageData
        newTask.createdAt = Date()
        newTask.isCompleted = false
        newTask.folder = folder
        return newTask
    }
}
