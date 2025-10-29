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
    @State private var tasks: [TaskItemNonDB] = []
    @State private var refreshTrigger = false
    @State private var visibleTaskItem: TaskItemNonDB?
    
    private func loadTasks() {
        tasks = DB.TaskItemManager.getItemsFrom(folder: selectedFolder, in: viewContext)
    }
    
    private var titleView: some View {
        Text("Задачи")
            .font(.largeTitle)
            .fontWeight(.light)
            .foregroundStyle(.hex000101)
            .padding(.leading, Offset.titlesLeadingOffset)
    }
    private var resultHeaderView: some View {
        HStack(spacing: Offset.screenBorderOffset) {
            let doneTasksCount = tasks.filter { $0.isCompleted }.count
            let inProgressTasksCount = tasks.filter { $0.checkListItems.contains(where: { $0.isDone }) }.count
            
            TaskResultView(viewModel: .init(
                tasksCount: tasks.count,
                doneTasksCount: doneTasksCount,
                resultType: .doneTasks))
            
            TaskResultView(viewModel: .init(
                tasksCount: tasks.count,
                doneTasksCount: inProgressTasksCount,
                resultType: .progressTasks))
        }
        .padding(
            .horizontal,
            Offset.screenBorderOffset)
    }
    
    private var selectedFolderView: some View {
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
    }
    
    private var taskItemsList: some View {
        VStack(
            alignment: .leading,
            spacing: Offset.screenBorderOffset
        ) {
            ForEach(tasks) { task in
                TaskItemView(viewModel: .init(
                    title: task.title,
                    timeInterval: formatDate(task.createdAt),
                    description: task.taskDescription,
                    progress: task.checkListItems.count > 0 ? .init(progressViewModel: .init(tasksCount: task.checkListItems.count, doneTasksCount: task.checkListItems.reduce(0, { $0 + ($1.isDone ? 1 : 0) }), doneTasksColor: .hex316AFD)) : nil,
                    isDone: task.isCompleted,
                    style: .whiteStyle,
                    sideArrowViewModel: task.checkListItems.count > 0 ? .init(backgroundColor: .hexF2F2F2, arrowColor: .hex000101) : nil,
                    onChangeDoneCheckbox: { changeTaskDoneState(task: task, isDone: $0) }
                )).onTapGesture {
                    visibleTaskItem = task
                }
            }
        }
        .padding(
            .horizontal,
            Offset.screenBorderOffset)
    }
    
    private func changeTaskDoneState(task: TaskItemNonDB, isDone: Bool) {
        var changedTask = task
        changedTask.isCompleted = isDone
        DB.TaskItemManager.change(item: changedTask, in: viewContext)
        loadTasks()
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                titleView
                resultHeaderView
                
                VStack(alignment: .leading) {
                    HStack {
                        selectedFolderView
                        Spacer()
                    }
                    .padding(.horizontal, Offset.titlesLeadingOffset)
                    .padding(.top, 20)
                    
                    taskItemsList
                }
            }
            .padding(.bottom, 150)
        }
        .background(Color.hexF2F2F2)
        .onAppear {
            loadTasks()
        }
        .onChange(of: selectedFolder.id) { _, _ in
            loadTasks()
        }
        .onReceive(NotificationCenter.default.publisher(for: .taskAdded)) { _ in
            loadTasks()
        }
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
        .fullScreenCover(item: $visibleTaskItem) { item in
            AddTaskView(context: viewContext, folder: $selectedFolder, taskInfo: item)
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
