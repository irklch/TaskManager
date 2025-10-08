//
//  TaskScreenViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 01.10.2025.
//

import Foundation
import SwiftUI
import Combine
import CoreData

@MainActor
final class TaskScreenViewModel: ObservableObject {
    @Published var selectedFolder: TaskFolderNonDB = .getTemplate()
    @Published var tasks: [TaskItemNonDB] = []
    let viewContext: NSManagedObjectContext
    
    init(
        selectedFolder: Published<TaskFolderNonDB>.Publisher,
        viewContext: NSManagedObjectContext
    ) {
        self.viewContext = viewContext
        selectedFolder
            .receive(on: DispatchQueue.main)
            .assign(to: &$selectedFolder)
        setupSelectedFolderObserver()
    }
    
    private func setupSelectedFolderObserver() {
        $selectedFolder
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .map({ [weak self] folder in
                guard let self else { return [] }
                return DB.TaskItemManager.getItemsFrom(folder: folder, in: viewContext)
            })
            .assign(to: &$tasks)
    }
}
