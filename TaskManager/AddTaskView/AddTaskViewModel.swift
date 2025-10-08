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
final class AddTaskViewModel: ObservableObject {
    @Published var taskTitle = ""
    @Published var taskDescription = ""
    @Published var selectedImage: UIImage?
    @Published var selectedImageItem: PhotosPickerItem?
    @Published var showingImagePicker = false
    @Published var isDescriptionFocused = false
    @Published var isPresented = false
    @Published var selectedFolder: TaskFolderNonDB = .getTemplate()
    @Published var taskSteps: [TaskStep] = [TaskStep()]
    @Published var showingFolderPicker = false
    @Published var folders: [TaskFolderNonDB] = []
    
    private let context: NSManagedObjectContext
    
    init(
        context: NSManagedObjectContext,
        selectedFolder: TaskFolderNonDB
    ) {
        self.context = context
        self.selectedFolder = selectedFolder
        loadFolders()
    }
    
    init(
        context: NSManagedObjectContext
    ) {
        self.context = context
        loadFolders()
    }
    
    private func loadFolders() {
        folders = DB.TaskFolderManager.getAllFolders(in: context)
        if selectedFolder.id == UUID() {
            selectedFolder = folders.first ?? .getTemplate()
        }
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
        
        DB.TaskItemManager.addNewTask(
            title: taskTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            imageData: imageData,
            folder: selectedFolder,
            in: context)
        
        // Clear form after saving
        clearForm()
    }
    
    func clearForm() {
        taskTitle = ""
        taskDescription = ""
        selectedImage = nil
        selectedImageItem = nil
        taskSteps = [TaskStep()]
    }
    
    func dismissView() {
        clearForm()
        isPresented = false
    }
    
    // MARK: - Folder Management
    func showFolderPicker() {
        showingFolderPicker = true
    }
    
    func hideFolderPicker() {
        showingFolderPicker = false
    }
    
    func selectFolder(_ folder: TaskFolderNonDB) {
        selectedFolder = folder
        hideFolderPicker()
    }
    
    // MARK: - Task Steps Management
    func updateTaskStep(at index: Int, with title: String) {
        guard index < taskSteps.count else { return }
        taskSteps[index].title = title
        
        // Если текущий этап заполнен и это последний этап, добавляем новый
        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && index == taskSteps.count - 1 {
            addNewTaskStep()
        }
    }
    
    func addNewTaskStep() {
        taskSteps.append(TaskStep())
    }
    
    func removeTaskStep(at index: Int) {
        guard taskSteps.count > 1 && index < taskSteps.count else { return }
        taskSteps.remove(at: index)
    }
    
    // MARK: - Computed Properties
    var validTaskSteps: [TaskStep] {
        taskSteps.filter { !$0.isEmpty }
    }
}