//
//  CustomProgressViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI

struct CustomProgressViewModel {
    let doneTasksPercent: Double
    let doneTasksColor: Color

    init(
        tasksCount: Int,
        doneTasksCount: Int,
        doneTasksColor: Color
    ) {
        self.doneTasksColor = doneTasksColor
        self.doneTasksPercent = Double(doneTasksCount) / Double(tasksCount)
    }
}
