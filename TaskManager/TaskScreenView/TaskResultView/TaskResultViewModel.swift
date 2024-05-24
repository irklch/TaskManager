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
        tasksCount: Int,
        doneTasksCount: Int,
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
                return "Today's Task"
            case .progressTasks:
                return "In Progress"
            }
        }

        func getSubtitleText(
            doneCount: Int,
            allCount: Int
        ) -> String {
            let count = doneCount.description + "/" + allCount.description + " "
            switch self {
            case .doneTasks:
                return count + "Done"
            case .progressTasks:
                return count + "Tasks"
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
#Preview {
    TaskScreenView()
}
