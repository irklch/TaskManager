//
//  TaskScreenView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//
import SwiftUI
import CoreData
import Combine

struct TaskScreenView: View {
    @State private var isFolderPopupVisible = false
    @Binding var selectedFolder: TaskFolderNonDB
    @Environment(\.managedObjectContext) private var viewContext
    
    private func getTasks() -> [TaskItemNonDB] {
        DB.TaskItemManager.getItemsFrom(folder: selectedFolder, in: viewContext)
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
                            isFolderPopupVisible = true
                        }) {
                            HStack(spacing: 4) {
                                Text(selectedFolder.name)
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
                        ForEach(getTasks()) { task in
                            TaskItemView(viewModel: .init(
                                title: task.title,
                                timeInterval: formatDate(task.createdAt),
                                description: task.taskDescription,
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
        .sheet(isPresented: $isFolderPopupVisible) {
            TaskFolderPopupView(
                viewModel: .init(
                    viewContext: viewContext),
                isPresented: $isFolderPopupVisible,
                selectedFolder: $selectedFolder)
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

//#Preview {
//    ContentView()
//}

extension TaskScreenView {
    enum Offset {
        static let screenBorderOffset: CGFloat = 12.0
        static let titlesLeadingOffset: CGFloat = 18.0
    }
}
