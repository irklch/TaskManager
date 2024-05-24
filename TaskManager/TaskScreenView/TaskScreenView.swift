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
                Spacer()
                Text("Hi, Irina")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .padding(.leading, 20)

                HStack(spacing: 20) {
                    TaskResultView(viewModel: .init(
                        tasksCount: 8,
                        doneTasksCount: 3,
                        resultType: .doneTasks))

                    TaskResultView(viewModel: .init(
                        tasksCount: 5,
                        doneTasksCount: 1,
                        resultType: .progressTasks))
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("All Tasks")
                        .font(.title2)
                        .padding(.leading)

                    VStack(alignment: .leading, spacing: 20) {
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                        TaskItemView()
                    }
                    .padding()
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
