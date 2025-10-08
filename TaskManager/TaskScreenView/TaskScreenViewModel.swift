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
    @Environment(\.managedObjectContext) private var viewContext
    
    init(
        selectedFolder: Published<TaskFolderNonDB>.Publisher
    ) {
        selectedFolder
            .receive(on: DispatchQueue.main)
            .assign(to: &$selectedFolder)
        setupSelectedFolderObserver()
    }
    
    private func setupSelectedFolderObserver() {
        $selectedFolder
            .removeDuplicates()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .map({ [weak self] folder in
                guard let self else { return [] }
                return DB.TaskItemManager.getItemsFrom(folder: folder, in: viewContext)
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$tasks)
    }
}
