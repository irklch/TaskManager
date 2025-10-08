//
//  TaskResultViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI


struct TaskResultViewModel {
    let titleText: String
    let subtitleText: String
    let resultType: ResultType
    let progressViewModel: CustomProgressViewModel
    let sideArrowViewModel: SideArrowViewModel

    init(
        tasksCount: Double,
        doneTasksCount: Double,
        resultType: ResultType
    ) {
        self.titleText = resultType.titleText
        self.subtitleText = resultType.getSubtitleText(
            doneCount: doneTasksCount,
            allCount: tasksCount)
        self.resultType = resultType
        self.progressViewModel = .init(
            tasksCount: tasksCount,
            doneTasksCount: doneTasksCount,
            doneTasksColor: resultType.progressDoneTasksColor)
        self.sideArrowViewModel = .init(
            backgroundColor: resultType.sideArrowBackgroundColor,
            arrowColor: resultType.textColor)
    }
}


extension TaskResultViewModel {
    enum ResultType {
        case doneTasks
        case progressTasks

        var titleText: String {
            switch self {
            case .doneTasks:
                return "Текущие задачи"
            case .progressTasks:
                return "В процессе"
            }
        }

        func getSubtitleText(
            doneCount: Double,
            allCount: Double
        ) -> String {
            let count = doneCount.formatted().description 
            + "/"
            + allCount.formatted().description
            + " "
            switch self {
            case .doneTasks:
                return count + "Готово"
            case .progressTasks:
                return count + "Задачи"
            }
        }

        var backgroundColor: Color {
            switch self {
            case .doneTasks:
                return .white
            case .progressTasks:
                return .hex316AFD
            }
        }

        var textColor: Color {
            switch self {
            case .doneTasks:
                return .hex000101
            case .progressTasks:
                return .white
            }
        }

        var progressDoneTasksColor: Color {
            switch self {
            case .doneTasks:
                return .hex316AFD
            case .progressTasks:
                return .white
            }
        }

        var sideArrowBackgroundColor: Color {
            switch self {
            case .doneTasks:
                return .hexF2F2F2
            case .progressTasks:
                return .hex000101
            }
        }
    }
}
