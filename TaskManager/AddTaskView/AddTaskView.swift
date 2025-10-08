//
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AddTaskView: View {
    @StateObject private var vm = AddTaskViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false
    @FocusState private var isNewItemFieldFocused: Bool
    @FocusState private var editingItemId: UUID?

    var body: some View {
        ZStack {
            Color.hexF2F2F2.ignoresSafeArea()

            VStack(spacing: 16) {
                header

                ScrollView {
                    VStack(spacing: 16) {
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
        .sheet(isPresented: $showPhotoPicker) {
            // Заглушка: в проде — PhotosPicker
            VStack(spacing: 20) {
                Text("Здесь будет PhotosPicker")
                Button("Добавить заглушку") {
                    vm.attachments.append(.init(preview: Image(systemName: "photo.on.rectangle"), type: .image))
                    showPhotoPicker = false
                }
            }.padding()
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.data], allowsMultipleSelection: false) { result in
            if case .success(_) = result {
                vm.attachments.append(.init(preview: Image(systemName: "doc.fill"), type: .file))
            }
        }
        .navigationBarHidden(true)
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
                // save action
                dismiss()
            } label: {
                Text("Сохранить")
                    .font(.system(size: 16, weight: .light))
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Capsule().fill(Color.hex316AFD))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 12)
//        .padding(.vertical, 12)
    }

    private var titleCard: some View {
        PlaceholderTextField(
            placeholder: "Заголовок",
            placeholderFont: Fonts.titleTextFieldFont,
            text: $vm.title, onSubmit: nil)
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
        VStack(alignment: .leading, spacing: 8) {
            
            ForEach($vm.checklist, id: \.id) { $item in
                HStack(spacing: 12) {
                    Toggle("", isOn: $item.isDone)
                        .toggleStyle(CircleCheckmarkToggleStyle())
                    
                    PlaceholderTextField(
                        placeholder: "",
                        placeholderFont: Fonts.checkboxFont,
                        text: $item.text, onSubmit: {
                            handleItemCommit(item: item)
                        })
                    .frame(height: 44)
                    .strikethrough(item.isDone, color: .secondary)
                    .foregroundStyle(item.isDone ? .secondary : Color.hex000101)
                    .focused($editingItemId, equals: item.id)
                }
                .contextMenu {
                    Button(role: .destructive) { vm.checklist.removeAll{ $0.id == item.id } } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }

            HStack(spacing: 12) {
                Toggle("", isOn: .constant(false))
                    .toggleStyle(CircleCheckmarkToggleStyle())
                PlaceholderTextField(
                    placeholder: "Добавить пункт",
                    placeholderFont: Fonts.checkboxFont,
                    text: $vm.newItemText,
                    onSubmit: {
                        handleNewItemCommit()
                    })
                .focused($isNewItemFieldFocused)
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
    
    private func handleNewItemCommit() {
        let text = vm.newItemText
        vm.addChecklistItem()
        // Клавиатура остается активной для добавления следующего пункта
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isNewItemFieldFocused = text.isEmpty == false
        }
    }
    
    private func handleItemCommit(item: AddTaskViewModel.ChecklistItem) {
        let trimmed = item.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            // Если пункт стал пустым - удаляем его
            vm.delete(item: item)
        }
        
        // Скрываем клавиатуру после редактирования существующего пункта
        editingItemId = nil
    }
}


#Preview {
    AddTaskView()
}
