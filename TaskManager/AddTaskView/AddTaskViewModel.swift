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
    @Published var showingImagePicker = false
//    @FocusState var isTitleFocused
    @Published var isDescriptionFocused = false
    @Published var taskSteps: [TaskStep] = [TaskStep()]
    @Published var deadline: Date?
    @Published var hasDeadline = false
    @Published var showingFolderPicker = false
    @Published var showingDatePicker = false
    
    private let context: NSManagedObjectContext
//    private var cancellables = Set<AnyCancellable>()
    
    init(
        context: NSManagedObjectContext
    ) {
        self.context = context
//        setupObservers()
    }
    
//    private func setupObservers() {
//        // Автоматически фокусируемся на поле заголовка при появлении
//        $isPresented
//            .filter { $0 }
//            .sink { [weak self] _ in
//                self?.isTitleFocused = true
//            }
//            .store(in: &cancellables)
//    }
    
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
        
        let folders = DB.TaskFolderManager.getAllFolders(in: context)
        
        DB.TaskItemManager.addNewTask(
            title: taskTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            imageData: imageData,
            folder: folders[0],
            in: context)
    }
    
    // MARK: - Folder Management
    func showFolderPicker() {
        showingFolderPicker = true
    }
    
    func hideFolderPicker() {
        showingFolderPicker = false
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
    
    // MARK: - Deadline Management
    func showDatePicker() {
        showingDatePicker = true
    }
    
    func hideDatePicker() {
        showingDatePicker = false
    }
    
    func setDeadline(_ date: Date) {
        deadline = date
        hasDeadline = true
        hideDatePicker()
    }
    
    func removeDeadline() {
        deadline = nil
        hasDeadline = false
    }
    
    func formattedDeadline() -> String {
        guard let deadline = deadline else { return "Без даты" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: deadline)
    }
    
    // MARK: - Computed Properties
    var validTaskSteps: [TaskStep] {
        taskSteps.filter { !$0.isEmpty }
    }
}
