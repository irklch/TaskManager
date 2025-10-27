//
//  DB+FileManager.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 27.10.2025.
//

import Foundation
import CoreData

struct FileNonDB {
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(model: File) {
        self.data = model.data ?? .init()
    }
    
    func getDBModel(context: NSManagedObjectContext) -> File {
        let model: File = .init(context: context)
        model.data = data
        return model
    }
}
