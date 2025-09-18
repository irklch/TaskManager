//
//  TaskModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import Foundation
import UIKit

struct TaskModel: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var imageData: Data?
    var createdAt: Date
    var isCompleted: Bool
    
    init(title: String, description: String = "", imageData: Data? = nil) {
        self.title = title
        self.description = description
        self.imageData = imageData
        self.createdAt = Date()
        self.isCompleted = false
    }
}

extension TaskModel {
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    static let sampleTasks = [
        TaskModel(title: "UX Research", description: "Formulating design strategies on user data"),
        TaskModel(title: "Design System", description: "Creating consistent design components"),
        TaskModel(title: "User Testing", description: "Conducting usability tests with real users")
    ]
}
