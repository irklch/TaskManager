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
    @Published var title: String = ""
    @Published var details: String = ""
    @Published var checklist: [ChecklistItem] = []
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
        guard !trimmed.isEmpty else {
            return
        }
        
        checklist.append(.init(text: trimmed, isDone: false))
    }

    func toggle(_ item: ChecklistItem) {
        if let i = checklist.firstIndex(of: item) {
            checklist[i].isDone.toggle()
        }
    }

    func delete(item: ChecklistItem) {
        checklist.removeAll{ $0.id == item.id }
    }
}
