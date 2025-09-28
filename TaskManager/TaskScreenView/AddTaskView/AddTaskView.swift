//
//  AddTaskView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import PhotosUI
import CoreData

struct AddTaskView: View {
    @Binding var isPresented: Bool
    let context: NSManagedObjectContext
    let selectedFolder: TaskFolder?
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var taskSteps: [TaskStep] = [TaskStep()]
    @State private var deadline: Date?
    @State private var hasDeadline = false
    @State private var showingDatePicker = false
    @State private var showingFolderPicker = false
    @State private var selectedFolderForTask: TaskFolder?
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    
    init(isPresented: Binding<Bool>, context: NSManagedObjectContext, selectedFolder: TaskFolder? = nil) {
        self._isPresented = isPresented
        self.context = context
        self.selectedFolder = selectedFolder
        self._selectedFolderForTask = State(initialValue: selectedFolder)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Заголовок - большое поле ввода
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            if taskTitle.isEmpty {
                                Text("Название задачи")
                                    .font(.system(size: 20))
                                    .fontWeight(.regular)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 0)
                            }
                            
                            TextField("", text: $taskTitle, axis: .vertical)
                                .font(.system(size: 20))
                                .fontWeight(.regular)
                                .foregroundColor(.hex000101)
                                .focused($isTitleFocused)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true) // Автоматическое изменение высоты
                                .accentColor(.gray) // Цвет курсора
                        }
                        
                        // Разделительная линия
                        Rectangle()
                            .fill(Color.hex316AFD)
                            .frame(height: 1)
                            .padding(.top, 8)
                    }
                    
                    // Описание задачи
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .topLeading) {
                            TextField(
                                "",
                                text: $taskDescription,
                                axis: .vertical
                            )
                            .font(.subheadline)
                            .foregroundColor(.hex000101)
                            .focused($isDescriptionFocused)
                            .lineLimit(nil) // Убираем ограничение строк для автоматического расширения
                            .padding(16)
                            .frame(minHeight: 100, alignment: .topLeading) // Минимальная высота 100, выравнивание по верху
                            .background(Color.white)
                            .cornerRadius(28)
                            .fixedSize(horizontal: false, vertical: true) // Автоматическое изменение высоты
                            .accentColor(.gray)
                            
                            if taskDescription.isEmpty {
                                Text("Описание задачи")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 16)
                                    .allowsHitTesting(false) // Позволяет клики проходить через плейсхолдер
                            }
                        }
                        .onTapGesture {
                            isDescriptionFocused = true
                        }
                    }
                    
                    // Этапы задач
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Этапы выполнения")
                            .font(.headline)
                            .foregroundColor(.hex000101)
                        
                        ForEach(taskSteps.indices, id: \.self) { index in
                            HStack(spacing: 12) {
                                // Кружок для этапа
                                Circle()
                                    .fill(taskSteps[index].isCompleted ? Color.hex316AFD : Color.hexF2F2F2)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.hex316AFD, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        taskSteps[index].isCompleted.toggle()
                                    }
                                
                                // Поле ввода текста этапа
                                TextField(
                                    TaskStep.placeholder,
                                    text: $taskSteps[index].title,
                                    axis: .vertical
                                )
                                .font(.body)
                                .foregroundColor(taskSteps[index].isEmpty ? .gray : .hex000101)
                                .lineLimit(1...3)
                                .onChange(of: taskSteps[index].title) { newValue in
                                    updateTaskStep(at: index, with: newValue)
                                }
                                
                                // Кнопка удаления (только если этапов больше одного)
                                if index > 0 {
                                    Button(action: {
                                        removeTaskStep(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 20))
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                    
                    // Дедлайн
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Дедлайн")
                            .font(.headline)
                            .foregroundColor(.hex000101)
                        
                        Button(action: {
                            showingDatePicker = true
                        }) {
                            HStack {
                                Text(formattedDeadline())
                                    .font(.body)
                                    .foregroundColor(hasDeadline ? .hex000101 : .gray)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.hex000101)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Выбор папки
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Название проекта")
                                .font(.headline)
                                .foregroundColor(.hex000101)
                            
                            Spacer()
                            
                            Button("Добавить новую") {
                                // TODO: Добавить логику создания новой папки
                            }
                            .font(.body)
                            .foregroundColor(.hex316AFD)
                        }
                        
                        Button(action: {
                            showingFolderPicker = true
                        }) {
                            HStack {
                                Text(selectedFolderForTask?.wrappedName ?? "Все задачи")
                                    .font(.body)
                                    .foregroundColor(.hex000101)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.hex000101)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(20)
            }
            .background(Color.hexF2F2F2)
            .navigationTitle("Создание задачи")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                    .foregroundColor(.hex316AFD)
                }
            }
            
            // Нижние кнопки
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
                    // Кнопка добавления файла
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "paperclip")
                                .font(.system(size: 16, weight: .medium))
                            Text("Добавить файл")
                                .font(.body)
                        }
                        .foregroundColor(.hex000101)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    
                    // Кнопка сохранения
                    Button(action: {
                        saveTask()
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .medium))
                            Text("Сохранить задачу")
                                .font(.body)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.hex316AFD)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .disabled(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingDatePicker) {
            VStack {
                DeadlinePickerView(
                    selectedDate: $deadline,
                    hasDeadline: $hasDeadline,
                    onDateSelected: setDeadline,
                    onNoDateSelected: removeDeadline
                )
                .padding(20)
                
                Spacer()
            }
            .presentationDetents([.height(400), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
        .sheet(isPresented: $showingFolderPicker) {
            TaskFolderPopupView(
                isPresented: $showingFolderPicker,
                selectedFolder: $selectedFolderForTask,
                folders: fetchFolders()
            )
            .presentationDetents([.height(300), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
        .onAppear {
            isTitleFocused = true
        }
        .onChange(of: showingFolderPicker) { isShowing in
            if isShowing {
                // Обновляем список папок при открытии picker'а
                _ = fetchFolders()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    var validTaskSteps: [TaskStep] {
        taskSteps.filter { !$0.isEmpty }
    }
    
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
    
    func formattedDeadline() -> String {
        guard let deadline = deadline else { return "Без даты" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: deadline)
    }
    
    func setDeadline(_ date: Date) {
        deadline = date
        hasDeadline = true
        showingDatePicker = false
    }
    
    func removeDeadline() {
        deadline = nil
        hasDeadline = false
        showingDatePicker = false
    }
    
    func fetchFolders() -> [TaskFolder] {
        let request: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskFolder.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch folders: \(error)")
            return []
        }
    }
    
    private func saveTask() {
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        // Используем выбранную папку или создаем папку по умолчанию
        let targetFolder = selectedFolderForTask ?? {
            let folderRequest: NSFetchRequest<TaskFolder> = TaskFolder.fetchRequest()
            let folders = (try? context.fetch(folderRequest)) ?? []
            
            if let existingFolder = folders.first {
                return existingFolder
            } else {
                let newFolder = TaskFolder(context: context)
                newFolder.id = UUID()
                newFolder.name = "Все задачи"
                newFolder.isSelected = true
                return newFolder
            }
        }()
        
        // Создаем новую задачу
        let newTask = Task.createNew(
            title: taskTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            imageData: imageData,
            folder: targetFolder,
            in: context
        )
        
        // Сохраняем контекст
        do {
            try context.save()
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ContentView()
}
