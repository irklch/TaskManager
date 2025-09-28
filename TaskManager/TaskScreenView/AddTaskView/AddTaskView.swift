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
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    
    init(isPresented: Binding<Bool>, context: NSManagedObjectContext, selectedFolder: TaskFolder? = nil) {
        self._isPresented = isPresented
        self.context = context
        self.selectedFolder = selectedFolder
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
                            .fill(Color.gray.opacity(0.3))
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
                    
                    // Выбор папки (упрощенная версия)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Название проекта")
                            .font(.headline)
                            .foregroundColor(.hex000101)
                        
                        HStack {
                            Text(selectedFolder?.wrappedName ?? "Все задачи")
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
                    
                    Spacer(minLength: 100)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("1/45")
                        .font(.body)
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
        .onAppear {
            isTitleFocused = true
        }
    }
    
    private func saveTask() {
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        // Используем выбранную папку или создаем папку по умолчанию
        let targetFolder = selectedFolder ?? {
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
