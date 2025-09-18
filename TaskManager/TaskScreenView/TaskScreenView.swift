//
//  TaskScreenView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//
import SwiftUI
import CoreData

struct TaskScreenView: View {
    let tasks: [Task]
    let folders: [TaskFolder]
    @State private var selectedFolder: TaskFolder?
    @State private var showFolderPopup = false
    
    init(tasks: [Task], folders: [TaskFolder]) {
        self.tasks = tasks
        self.folders = folders
        self._selectedFolder = State(initialValue: folders.first { $0.isSelected } ?? folders.first)
    }
    
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
                    HStack {
                        Button(action: {
                            showFolderPopup = true
                        }) {
                            HStack(spacing: 4) {
                                Text(selectedFolder?.wrappedName ?? "Все задачи")
                                    .font(.title2)
                                    .foregroundColor(.hex316AFD)
                                    .multilineTextAlignment(.leading)
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.hex316AFD)
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, Offset.titlesLeadingOffset)
                    .padding(.top, 20)
                    let sideArrowVM: SideArrowViewModel = .init(
                        backgroundColor: .hexF2F2F2,
                        arrowColor: .hex000101)
                    VStack(
                        alignment: .leading,
                        spacing: Offset.screenBorderOffset
                    ) {
                        ForEach(tasks) { task in
                            TaskItemView(viewModel: .init(
                                title: task.wrappedTitle,
                                timeInterval: formatDate(task.wrappedCreatedAt),
                                description: task.wrappedDescription,
                                itemType: .checkbox,
                                isDone: task.isCompleted,
                                style: .whiteStyle,
                                sideArrowViewModel: sideArrowVM
                            ))
                        }
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
                folders: folders
            )
            .presentationDetents([.height(300), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: date)
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today \(timeString)"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday \(timeString)"
        } else {
            formatter.dateFormat = "MMM dd"
            let dateString = formatter.string(from: date)
            return "\(dateString) \(timeString)"
        }
    }
}

#Preview {
    TaskScreenView(tasks: [], folders: [])
}

extension TaskScreenView {
    enum Offset {
        static let screenBorderOffset: CGFloat = 12.0
        static let titlesLeadingOffset: CGFloat = 18.0
    }
}
