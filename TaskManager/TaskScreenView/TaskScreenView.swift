//
//  TaskScreenView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//
import SwiftUI

struct TaskScreenView: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text("Hi, Irina")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .padding(
                        .leading,
                        Offset.titlesLeadingOffset)

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
                    Text("All Tasks")
                        .font(.title2)
                        .padding(.leading, Offset.titlesLeadingOffset)
                        .padding(.top, 20)

                    VStack(
                        alignment: .leading,
                        spacing: Offset.screenBorderOffset
                    ) {
                        TaskItemView(viewModel: .init(
                            title: "UX Research",
                            timeInterval: "Started 10:30 PM",
                            description: "Formulating design strategies on user data",
                            itemType: .progress(.init(allItems: 11, doneItems: 3)),
                            isDone: false))
                        TaskItemView(viewModel: .init(
                            title: "Feature Implementation",
                            timeInterval: "Today 08:00 AM",
                            description: "Developing new features for an iOS application",
                            itemType: .checkbox,
                            isDone: true))
                        TaskItemView(viewModel: .init(
                            title: "Bug Fixing",
                            timeInterval: "Tomorrow 12:20 PM",
                            description: "Identifying and fixing bugs reported by QA testers",
                            itemType: .progress(.init(allItems: 10, doneItems: 10)),
                            isDone: true))
                        TaskItemView(viewModel: .init(
                            title: "Code Optimization",
                            timeInterval: "Today 09:00 AM",
                            description: "Improving the performance",
                            itemType: .checkbox,
                            isDone: false))
                    }
                    .padding(
                        .horizontal,
                        Offset.screenBorderOffset)
                }
            }
            .padding(.bottom, 150)
        }
        .background(Color.hexF2F2F2)
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
