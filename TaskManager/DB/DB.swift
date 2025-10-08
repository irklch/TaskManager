//
//  DB.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 30.09.2025.
//

import Foundation
import CoreData

enum DB {
    
    static func save(
        in context: NSManagedObjectContext
    ) {
        do {
            try context.save()
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}
