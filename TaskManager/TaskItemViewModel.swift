//
//  TaskItemViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 27.10.2025.
//

import SwiftUI
import Combine

final class TaskItemViewModel: ObservableObject {
    let sideArrowViewModel: SideArrowViewModel?
    let title: String
    let timeInterval: String
    let description: String
    let progress: ProgressModel?
    let style: Style

    @Published var isDone: Bool
    let onChangeDoneCheckbox: ((Bool) -> Void)?

    init(
        title: String,
        timeInterval: String,
        description: String,
        progress: ProgressModel?,
        isDone: Bool,
        style: Style,
        sideArrowViewModel: SideArrowViewModel?,
        onChangeDoneCheckbox: ((Bool) -> Void)?
    ) {
        self.title = title
        self.timeInterval = timeInterval
        self.description = description
        self.progress = progress
        self.isDone = isDone
        self.style = style
        self.sideArrowViewModel = sideArrowViewModel
        self.onChangeDoneCheckbox = onChangeDoneCheckbox
    }
    
    struct ProgressModel {
        let progressViewModel: CustomProgressViewModel
        let percentText: String

        init(
            progressViewModel: CustomProgressViewModel
        ) {
            self.progressViewModel = progressViewModel
            self.percentText = (progressViewModel.doneTasksPercent * 100).rounded().formatted().description + "%"
        }
    }

    struct Style {
        let textColor: Color
        let backgroundColor: Color
        let timeColor: Color

        static let whiteStyle: Style = .init(
            textColor: .hex000101,
            backgroundColor: .white,
            timeColor: .gray)

        static let blueStyle: Style = .init(
            textColor: .white,
            backgroundColor: .hex316AFD,
            timeColor: .white.opacity(0.5))
        
        static let grayStyle: Style = .init(
            textColor: .hex000101,
            backgroundColor: .hexF2F2F2,
            timeColor: .gray)
    }
    
    func toggleDoneState() {
        isDone.toggle()
        onChangeDoneCheckbox?(isDone)
    }
}
