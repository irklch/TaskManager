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
    @Published var isPresented: Bool
    @Published var selectedFolder: TaskFolderNonDB
    @Published var folders: [TaskFolderNonDB]
    @Published var isCreatingNewFolder = false
    @Published var newFolderName = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    
    init(isPresented: Bool) {
        self.isPresented = isPresented
        let allFolders = DB.TaskFolderManager.getAllFolders(in: viewContext)
        self.folders = allFolders
        self.selectedFolder = allFolders.first(where: { $0.isSelected }) ?? allFolders[0]
    }
    
    
    func createNewFolder() {
        let folderName: String = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !folderName.isEmpty else {
            return
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
        selectedFolder = newFolder
        isPresented = false
    }
    
    func select(folder: TaskFolderNonDB) {
        selectedFolder.isSelected = false
        folder.isSelected = true
        DB.TaskFolderManager.change(items: [selectedFolder, folder], in: viewContext)
        selectedFolder = folder
        isPresented = false
    }
}
