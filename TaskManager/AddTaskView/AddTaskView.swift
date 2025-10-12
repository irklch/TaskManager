//
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import CoreData

struct AddTaskView: View {
    @StateObject private var vm: AddTaskViewModel = .init()
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @FocusState private var isNewItemFieldFocused: Bool
    @FocusState private var editingItemId: UUID?
    @State private var isFolderPopupVisible = false
    private let context: NSManagedObjectContext
    @State private var selectedFolder: TaskFolderNonDB
    @Binding private var parentSelectedFolder: TaskFolderNonDB
    
    init(context: NSManagedObjectContext, folder: Binding<TaskFolderNonDB>) {
        self.context = context
        self._parentSelectedFolder = folder
        self._selectedFolder = State(initialValue: folder.wrappedValue)
    }

    var body: some View {
        ZStack {
            Color.hexF2F2F2.ignoresSafeArea()

            VStack(spacing: 16) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        selectedFolderView
                        titleCard
                        descriptionCard
                        checklistCard
                        attachmentsCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }

            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotos,
            maxSelectionCount: nil,
            matching: .images,
            photoLibrary: .shared()
        )
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.data], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    // Начинаем безопасный доступ к файлу
                    guard url.startAccessingSecurityScopedResource() else {
                        continue
                    }
                    
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    
                    // Загружаем данные файла
                    if let fileData = try? Data(contentsOf: url) {
                        vm.attachments.append(.init(
                            preview: Image(systemName: "doc.text.fill"),
                            type: .file,
                            data: fileData))
                    }
                }
            case .failure:
                break
            }
        }
        .onChange(of: selectedPhotos) { _, newItems in
            Task {
                for newItem in newItems {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            vm.attachments.append(.init(
                                preview: Image(uiImage: uiImage),
                                type: .image,
                                data: data))
                        }
                    }
                }
                // Очищаем выбор после обработки
                await MainActor.run {
                    selectedPhotos.removeAll()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isFolderPopupVisible) {
            TaskFolderPopupView(
                viewModel: .init(
                    viewContext: context),
                isPresented: $isFolderPopupVisible,
                selectedFolder: $selectedFolder)
            .presentationDetents([.height(300), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
    }
    
    private var selectedFolderView: some View {
        Button(action: {
            isFolderPopupVisible = true
        }) {
            HStack(spacing: 4) {
                Text(selectedFolder.name)
                    .font(.title2)
                    .foregroundColor(.hex316AFD)
                    .multilineTextAlignment(.leading)
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.hex316AFD)
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: Sections

    private var header: some View {
        HStack {
            Button("Отмена") { dismiss() }
                .foregroundStyle(.gray)
                .font(.system(size: 16, weight: .light))

            Spacer()
            Spacer()
            
            Text("Новая задача")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.hex000101)

            Spacer()

            Button {
                if vm.isButtonEnabled {
                    vm.saveTask(folder: selectedFolder, context: context)
                    // Обновляем выбранную папку в родительском view только при сохранении
                    parentSelectedFolder = selectedFolder
                    dismiss()
                }
            } label: {
                Text("Сохранить")
                    .font(.system(size: 16, weight: .light))
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Capsule().fill(Color.hex316AFD))
                    .foregroundColor(.white)
                
            }
            .disabled(vm.isButtonEnabled == false)
            .opacity(vm.isButtonEnabled ? 1.0 : 0.5 )
        }
        .padding(.horizontal, 12)
    }

    private var titleCard: some View {
        PlaceholderTextField(
            placeholder: "Заголовок",
            font: Fonts.titleTextFieldFont,
            text: $vm.title,
            onSubmit: nil,
            placeholderColor: .gray.opacity(0.5),
            textColor: .hex000101)
        .font(Fonts.titleTextFieldFont)
        .tint(.hex316AFD)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Color.white))
    }

    private var descriptionCard: some View {
        GrowingTextView(
            text: $vm.details,
            placeholder: "Опишите детали задачи...",
            placeholderFont: Fonts.descriptionTextViewFont)
        .font(Fonts.descriptionTextViewFont)
        .tint(.hex316AFD)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Color.white))
    }

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            List {
                ForEach($vm.checklist, id: \.id) { $item in
                    HStack(spacing: 12) {
                        Toggle("", isOn: $item.isDone)
                            .toggleStyle(CircleCheckmarkToggleStyle())
                        
                        PlaceholderTextField(
                            placeholder: "",
                            font: Fonts.checkboxFont,
                            text: $item.text,
                            onSubmit: {
                                handleItemCommit(item: item)
                            },
                            placeholderColor: .gray.opacity(0.5),
                            textColor: .hex000101)
                        .frame(height: 44)
                        .strikethrough(item.isDone, color: .secondary)
                        .foregroundStyle(item.isDone ? .secondary : Color.hex000101)
                        .focused($editingItemId, equals: item.id)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            vm.delete(item: item)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .listStyle(.plain)
            .frame(height: CGFloat(vm.checklist.count * 44)) // Примерная высота
            .scrollDisabled(true)
            .animation(.easeInOut(duration: 0.3), value: vm.checklist.count)

            HStack(spacing: 12) {
                Toggle("", isOn: .constant(false))
                    .toggleStyle(CircleCheckmarkToggleStyle())
                PlaceholderTextField(
                    placeholder: "Добавить пункт",
                    font: Fonts.checkboxFont,
                    text: $vm.newItemText,
                    onSubmit: {
                        handleNewItemCommit()
                    },
                    placeholderColor: .gray.opacity(0.5),
                    textColor: .hex000101)
                .focused($isNewItemFieldFocused)
                .onChange(of: isNewItemFieldFocused) { _, isFocused in
                    if isFocused {
                        handleNewFieldFocused()
                    }
                }
            }
            .padding(.top, 6)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Color.white))
    }

    private var attachmentsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.attachments) { att in
                        AttachmentThumb(image: att.preview)
                    }
                }
            }

            HStack(spacing: 12) {
                Button {
                    showPhotoPicker = true
                } label: {
                    Label("Изображение", systemImage: "photo")
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(Capsule().fill(Color(.hexF2F2F2)))
                }

                Button {
                    showFileImporter = true
                } label: {
                    Label("Файл", systemImage: "paperclip")
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(Capsule().fill(Color(.hexF2F2F2)))
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Color.white))
    }
    
    // MARK: - Helper Functions
    
    private func handleNewFieldFocused() {
        // Когда пользователь кликает на поле ввода, создаем новый пустой элемент с анимацией
        let newItem = AddTaskViewModel.ChecklistItem(text: "", isDone: false)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            vm.checklist.append(newItem)
        }
        
        // Очищаем поле ввода
        vm.newItemText = ""
        
        // Небольшая задержка перед переключением фокуса для плавной анимации
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            editingItemId = newItem.id
        }
    }
    
    private func handleNewItemCommit() {
        vm.addChecklistItem()
        isNewItemFieldFocused = false
    }
    
    private func handleItemCommit(item: AddTaskViewModel.ChecklistItem) {
        let trimmed = item.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            // Если пункт стал пустым - удаляем его
            withAnimation(.easeInOut(duration: 0.3)) {
                vm.delete(item: item)
            }
        } else {
            // Скрываем клавиатуру после редактирования существующего пункта
            editingItemId = nil
        }
    }
}
