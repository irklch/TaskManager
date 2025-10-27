//
//  AddTaskViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData
import PhotosUI
import Combine

// MARK: - ViewModel
final class AddTaskViewModel: ObservableObject {
    private let id: UUID
    @Published var title: String
    @Published var details: String
    @Published var checklist: [CheckListItemNonDB]
    @Published var newItemText: String = ""
    @Published var images: [Attachment]
    @Published var files: [Attachment]
    
    @Published var selectedPhotos: [PhotosPickerItem] = []
    let navBarTitle: String
    private let isNewTask: Bool
    private let createdAt: Date
    
    init(taskInfo: TaskItemNonDB?) {
        if taskInfo == nil {
            self.isNewTask = true
            self.navBarTitle = "Новая задача"
        } else {
            self.isNewTask = false
            self.navBarTitle = "Редактирование"
        }
        
        self.id = taskInfo?.id ?? .init()
        self.title = taskInfo?.title ?? ""
        self.details = taskInfo?.taskDescription ?? ""
        self.checklist = taskInfo?.checkListItems ?? []
        self.createdAt = taskInfo?.createdAt ?? Date()
        self.images = (taskInfo?.images ?? []).map({
            .init(
                id: .init(),
                preview: .init(uiImage: .init(data: $0.data) ?? .init() ),
                data: $0)
        })
        self.files = (taskInfo?.files ?? []).map({
            .init(
                id: .init(),
                preview: Image(systemName: "doc.text.fill"),
                data: $0)
        })
    }
    
    var isButtonEnabled: Bool {
        title != "" && details != ""
    }

    func addChecklistItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        newItemText = ""
        guard !trimmed.isEmpty else {
            return
        }
        let item: CheckListItemNonDB = .init(id: .init(), title: trimmed, isDone: false)
        checklist.append(item)
    }

    func delete(item: CheckListItemNonDB) {
        checklist.removeAll{ $0.id == item.id }
    }
    
    func saveTask(folder: TaskFolderNonDB, context: NSManagedObjectContext) {
        
        let model: TaskItemNonDB = .init(
            id: id,
            title: title,
            taskDescription: details,
            createdAt: createdAt,
            isCompleted: checklist.contains(where: { $0.isDone == false }) == false,
            folderID: folder.id,
            checkListItems: checklist,
            images: images.map({ $0.data }),
            files: files.map({ $0.data }))
        
        if isNewTask {
            // Сохраняем задачу в базу данных
            DB.TaskItemManager.addNewTask(
                model: model,
                in: context)
        } else {
            DB.TaskItemManager.change(
                item: model,
                in: context)
        }
        
        // Отправляем уведомление об добавлении задачи
        NotificationCenter.default.post(name: .taskAdded, object: nil)
    }
    func appendFiles(urls: [URL]) {
        for url in urls {
            // Начинаем безопасный доступ к файлу
            guard url.startAccessingSecurityScopedResource(),
                    let fileData = try? Data(contentsOf: url) else {
                continue
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            files.append(.init(
                id: .init(),
                preview: Image(systemName: "doc.text.fill"),
                data: .init(data: fileData)))
            
        }
    }
    
    func appendImages(newItems: [PhotosPickerItem]) {
        Task {
            for newItem in newItems {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        images.append(.init(
                            id: .init(),
                            preview: Image(uiImage: uiImage),
                            data: .init(data: data)))
                    }
                }
            }
            // Очищаем выбор после обработки
            await MainActor.run {
                selectedPhotos.removeAll()
            }
        }
    }
}

extension Notification.Name {
    static let taskAdded = Notification.Name("taskAdded")
}

extension AddTaskViewModel {
    struct Attachment: Identifiable {
        var id: UUID
        var preview: Image
        var data: FileNonDB
    }
}
