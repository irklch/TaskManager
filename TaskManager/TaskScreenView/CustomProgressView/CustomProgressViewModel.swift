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
        tasksCount: Double,
        doneTasksCount: Double,
        doneTasksColor: Color
    ) {
        self.doneTasksPercent = doneTasksCount / tasksCount
        self.doneTasksColor = doneTasksColor
    }
}
