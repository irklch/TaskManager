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

@MainActor
class AddTaskViewModel: ObservableObject {
    @Published var taskTitle = ""
    @Published var taskDescription = ""
    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var isTitleFocused = false
    @Published var isDescriptionFocused = false
    @Published var isPresented = false
    
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        setupObservers()
    }
    
    private func setupObservers() {
        // Автоматически фокусируемся на поле заголовка при появлении
        $isPresented
            .filter { $0 }
            .sink { [weak self] _ in
                self?.isTitleFocused = true
            }
            .store(in: &cancellables)
    }
    
    var isSaveButtonEnabled: Bool {
        !taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var saveButtonOpacity: Double {
        isSaveButtonEnabled ? 1.0 : 0.5
    }
    
    func showImagePicker() {
        showingImagePicker = true
    }
    
    func hideImagePicker() {
        showingImagePicker = false
    }
    
    func setSelectedImage(_ image: UIImage?) {
        selectedImage = image
    }
    
    func saveTask() {
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        // Получаем папку по умолчанию (первую папку или создаем новую)
        let folderRequest: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
        let folders = (try? context.fetch(folderRequest)) ?? []
        
        let defaultFolder = folders.first ?? {
            let newFolder = TaskFolder(context: context)
            newFolder.id = UUID()
            newFolder.name = "Все задачи"
            newFolder.isSelected = true
            return newFolder
        }()
        
        // Создаем новую задачу
        let newTask = Task.createNew(
            title: taskTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            imageData: imageData,
            folder: defaultFolder,
            in: context
        )
        
        // Сохраняем контекст
        do {
            try context.save()
            clearForm()
            isPresented = false
        } catch {
            print("Failed to save task: \(error)")
        }
    }
    
    func clearForm() {
        taskTitle = ""
        taskDescription = ""
        selectedImage = nil
        isTitleFocused = false
        isDescriptionFocused = false
    }
    
    func dismissView() {
        clearForm()
        isPresented = false
    }
}
