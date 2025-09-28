//
//  TaskStep.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import Foundation
import SwiftUI

struct TaskStep: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
    
    init(title: String = "", isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}

extension TaskStep {
    static let placeholder = "Добавьте этап задачи"
    
    var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var displayTitle: String {
        isEmpty ? TaskStep.placeholder : title
    }
}
