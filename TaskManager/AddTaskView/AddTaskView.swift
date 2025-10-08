//
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers


// MARK: - ViewModel
final class AddTaskViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var details: String = ""
    @Published var checklist: [ChecklistItem] = [
        .init(text: "Create wireframe", isDone: true),
        .init(text: "Discuss with team", isDone: false),
        .init(text: "Attach Figma link", isDone: false)
    ]
    @Published var newItemText: String = ""
    @Published var attachments: [Attachment] = []

    struct ChecklistItem: Identifiable, Hashable {
        let id = UUID()
        var text: String
        var isDone: Bool
    }

    struct Attachment: Identifiable {
        let id = UUID()
        var preview: Image // thumbnail; для реального проекта подставь из PHImageManager/QuickLook
        var type: Kind
        enum Kind { case image, file }
    }

    func addChecklistItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        newItemText = ""
        guard !trimmed.isEmpty else { return }
        checklist.append(.init(text: trimmed, isDone: false))
    }

    func toggle(_ item: ChecklistItem) {
        if let i = checklist.firstIndex(of: item) {
            checklist[i].isDone.toggle()
        }
    }

    func delete(at offsets: IndexSet) { checklist.remove(atOffsets: offsets) }
}

// MARK: - Apple Notes–like Checkbox
struct CircleCheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                configuration.isOn.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 26, height: 26)
                if configuration.isOn {
                    Circle()
                        .fill(Color.hex316AFD)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(configuration.isOn ? "checkmark" : "checkmark"))
    }
}

struct PlaceholderTextField: View {
    var placeholder: String
    var placeholderFont: Font
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(placeholderFont)
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            TextField("", text: $text)
                .foregroundColor(.hex000101)
        }
    }
}

// MARK: - Auto-growing TextEditor
struct GrowingTextEditor: View {
    @Binding var text: String
    @State private var dynHeight: CGFloat = 120
    var placeholder: String
    var placeholderFont: Font

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(placeholderFont)
                    .foregroundStyle(Color.gray.opacity(0.5))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
            }
            TextEditor(text: $text)
                .frame(minHeight: 120, maxHeight: max(120, dynHeight))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
//                .padding(4)
                .background(GeometryReader { geo in
                    Color.clear
                        .onChange(of: text) {
                            dynHeight = max(120, geo.size.height)
                            #warning("Динамическую высоту сделать")
                        }
                })
        }
    }
}

// MARK: - Attachment Thumb
struct AttachmentThumb: View {
    let image: Image
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: 116, height: 96)
            .clipped()
            .cornerRadius(16)
    }
}

// MARK: - Main Screen
struct AddTaskView: View {
    @StateObject private var vm = AddTaskViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false

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
                .foregroundStyle(.secondary)
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
            text: $vm.title)
        .font(Fonts.titleTextFieldFont)
        .tint(.hex316AFD)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Color.white))
    }

    private var descriptionCard: some View {
        GrowingTextEditor(
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
            
            ForEach($vm.checklist) { $item in
                HStack(spacing: 12) {
                    Toggle("", isOn: $item.isDone)
                        .toggleStyle(CircleCheckmarkToggleStyle())
                    TextField("List item", text: $item.text)
                        .font(.system(size: 16))
                        .strikethrough(item.isDone, color: .secondary)
                        .foregroundStyle(item.isDone ? .secondary : Color.hex000101)
                }
                .padding(.vertical, 8)
                .contextMenu {
                    Button(role: .destructive) { vm.checklist.removeAll{ $0.id == item.id } } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }


            HStack(spacing: 12) {
                Toggle("", isOn: .constant(false))
                    .toggleStyle(CircleCheckmarkToggleStyle())
                TextField("Add item", text: $vm.newItemText, onCommit: vm.addChecklistItem)
                    .font(.system(size: 16))
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
                    Label("Image", systemImage: "photo")
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(Capsule().fill(Color(.systemGray6)))
                }

                Button {
                    showFileImporter = true
                } label: {
                    Label("File", systemImage: "paperclip")
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(Capsule().fill(Color(.systemGray6)))
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Color.white))
    }
}

private struct CircleButton: View {
    let icon: String
    var body: some View {
        Circle()
            .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
            .frame(width: 44, height: 44)
            .overlay(Image(systemName: icon).font(.system(size: 18, weight: .light)))
    }
}

// MARK: - Preview
struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { AddTaskView() }
            .preferredColorScheme(.light)
    }
}

#Preview {
    AddTaskView()
}

extension AddTaskView {
    enum Fonts {
        static let titleTextFieldFont: Font = .system(size: 20, weight: .light)
        static let descriptionTextViewFont: Font = .system(size: 16, weight: .light)
    }
}

