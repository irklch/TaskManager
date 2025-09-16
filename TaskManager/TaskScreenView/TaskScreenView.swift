//
//  TaskScreenView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//
import SwiftUI

struct TaskScreenView: View {
    @State private var selectedFolder = "Все задачи"
    @State private var showFolderPopup = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                Text("Задачи")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundStyle(.hex000101)
                    .padding(.leading, Offset.titlesLeadingOffset)
                    

                HStack(spacing: Offset.screenBorderOffset) {
                    TaskResultView(viewModel: .init(
                        tasksCount: 8,
                        doneTasksCount: 3,
                        resultType: .doneTasks))

                    TaskResultView(viewModel: .init(
                        tasksCount: 5,
                        doneTasksCount: 1,
                        resultType: .progressTasks))
                }
                .padding(
                    .horizontal,
                    Offset.screenBorderOffset)

                VStack(alignment: .leading) {
                    Button(action: {
                        showFolderPopup = true
                    }) {
                        HStack {
                            Text(selectedFolder)
                                .font(.title2)
                                .foregroundColor(.hex316AFD)
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.hex316AFD)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .padding(.leading, Offset.titlesLeadingOffset)
                    .padding(.top, 20)
                    let sideArrowVM: SideArrowViewModel = .init(
                        backgroundColor: .hexF2F2F2,
                        arrowColor: .hex000101)
                    VStack(
                        alignment: .leading,
                        spacing: Offset.screenBorderOffset
                    ) {
                        TaskItemView(viewModel: .init(
                            title: "UX Research",
                            timeInterval: "Started 10:30 PM",
                            description: "Formulating design strategies on user data",
                            itemType: .progress(.init(progressViewModel: .init(tasksCount: 11, doneTasksCount: 3, doneTasksColor: .hex316AFD))),
                            isDone: false,
                            style: .whiteStyle,
                        sideArrowViewModel: sideArrowVM))
                        TaskItemView(viewModel: .init(
                            title: "Feature Implementation",
                            timeInterval: "Today 08:00 AM",
                            description: "Developing new features for an iOS application",
                            itemType: .checkbox,
                            isDone: true,
                            style: .whiteStyle,
                        sideArrowViewModel: sideArrowVM))
                        TaskItemView(viewModel: .init(
                            title: "Bug Fixing",
                            timeInterval: "Tomorrow 12:20 PM",
                            description: "Identifying and fixing bugs reported by QA testers",
                            itemType: .progress(.init(progressViewModel: .init(tasksCount: 10, doneTasksCount: 10, doneTasksColor: .hex316AFD))),
                            isDone: true,
                            style: .whiteStyle,
                        sideArrowViewModel: sideArrowVM))
                        TaskItemView(viewModel: .init(
                            title: "Code Optimization",
                            timeInterval: "Today 09:00 AM",
                            description: "Improving the performance",
                            itemType: .checkbox,
                            isDone: false,
                            style: .whiteStyle,
                            sideArrowViewModel: sideArrowVM))
                    }
                    .padding(
                        .horizontal,
                        Offset.screenBorderOffset)
                }
            }
            .padding(.bottom, 150)
        }
        .background(Color.hexF2F2F2)
        .sheet(isPresented: $showFolderPopup) {
            TaskFolderPopupView(
                isPresented: $showFolderPopup,
                selectedFolder: $selectedFolder,
                folders: TaskFolderModel.sampleFolders
            )
        }
    }
}


#Preview {
    ContentView()
}

extension TaskScreenView {
    enum Offset {
        static let screenBorderOffset: CGFloat = 12.0
        static let titlesLeadingOffset: CGFloat = 18.0
    }
}
