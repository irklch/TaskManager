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
    
    private func reloadFolders() {
        folders = DB.TaskFolderManager.getAllFolders(in: viewContext)
    }
    
    func createNewFolder(selectedFolder: TaskFolderNonDB) -> TaskFolderNonDB? {
        let folderName: String = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !folderName.isEmpty else {
            return nil
        }
        
        // Снимаем выбор с текущей папки
        selectedFolder.isSelected = false
        DB.TaskFolderManager.change(item: selectedFolder, in: viewContext)
        
        // Создаём новую папку
        let newFolder: TaskFolderNonDB = .init(
            id: .init(),
            name: folderName,
            isSelected: true,
            tasks: [])
        DB.TaskFolderManager.addNew(item: newFolder, in: viewContext)
        
        // Перезагружаем список папок
        reloadFolders()
        
        // Находим созданную папку в новом списке
        return folders.first(where: { $0.id == newFolder.id })
    }
    
    func selectFolder(currentFolder: TaskFolderNonDB, newFolder: TaskFolderNonDB) -> TaskFolderNonDB? {
        // Не делаем ничего, если выбрали ту же папку
        guard currentFolder.id != newFolder.id else {
            return nil
        }
        
        // Обновляем статус в объектах
        currentFolder.isSelected = false
        newFolder.isSelected = true
        
        // Сохраняем изменения в БД
        DB.TaskFolderManager.change(items: [currentFolder, newFolder], in: viewContext)
        
        // Перезагружаем список папок из БД
        reloadFolders()
        
        // Возвращаем обновлённую папку из нового списка
        return folders.first(where: { $0.id == newFolder.id })
    }
}
