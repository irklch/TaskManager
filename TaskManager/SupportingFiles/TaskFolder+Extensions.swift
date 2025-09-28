import Foundation
import CoreData
import SwiftUI

extension TaskFolder {
    public var wrappedName: String {
        name ?? "Unknown Folder"
    }
    
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    public var taskCount: Int {
        tasks?.count ?? 0
    }
    
    public static func createSampleFolders(in context: NSManagedObjectContext) {
        let foldersData = [
            ("Все задачи", 8, false),
            ("Рабочие", 5, true),
            ("Личные", 3, false),
            ("Покупки", 2, false),
            ("Здоровье", 1, false),
            ("Путешествия", 0, false)
        ]
        
        for (name, count, isSelected) in foldersData {
            let folder = TaskFolder(context: context)
            folder.id = UUID()
            folder.name = name
            folder.isSelected = isSelected
        }
    }
    
    public static func fetchAll(in context: NSManagedObjectContext) -> [TaskFolder] {
        let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskFolder.name, ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch folders: \(error)")
            return []
        }
    }
    
    public static func fetchSelected(in context: NSManagedObjectContext) -> TaskFolder? {
        let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
        request.predicate = NSPredicate(format: "isSelected == %@", NSNumber(value: true))
        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch selected folder: \(error)")
            return nil
        }
    }
}

