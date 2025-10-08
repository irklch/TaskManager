//
//  TaskFolderPopupViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import Foundation
import CoreData
import SwiftUICore

final class TaskFolderPopupViewModel: ObservableObject {
    @Published var folders: [TaskFolderNonDB]
    @Published var isCreatingNewFolder = false
    @Published var newFolderName = ""
    
    private let viewContext: NSManagedObjectContext
    
    init(
        viewContext: NSManagedObjectContext
    ) {
        self.viewContext = viewContext
        let allFolders = DB.TaskFolderManager.getAllFolders(in: viewContext)
        self.folders = allFolders
    }
    
    
    func getNewFolder(selectedFolder: TaskFolderNonDB) -> TaskFolderNonDB {
        let folderName: String = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !folderName.isEmpty else {
            return selectedFolder
        }
        selectedFolder.isSelected = false
        DB.TaskFolderManager.change(item: selectedFolder, in: viewContext)
        
        // Create new folder in Core Data
        let newFolder: TaskFolderNonDB = .init(
            id: .init(),
            name: folderName,
            isSelected: true,
            tasks: [])
        DB.TaskFolderManager.addNew(item: newFolder, in: viewContext)
        return newFolder
    }
    
    func select(currentFolder: TaskFolderNonDB, newFolder: TaskFolderNonDB) {
        currentFolder.isSelected = false
        newFolder.isSelected = true
        DB.TaskFolderManager.change(items: [currentFolder, newFolder], in: viewContext)
    }
}
