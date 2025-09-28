//
//  TaskScreenView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//
import SwiftUI
import CoreData

struct TaskScreenView: View {
    @StateObject private var viewModel: TaskScreenViewModel
    
    init(tasks: [Task], folders: [TaskFolder]) {
        self._viewModel = StateObject(wrappedValue: TaskScreenViewModel(tasks: tasks, folders: folders))
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
                    TaskResultView(viewModel: viewModel.createTaskResultViewModel(for: .doneTasks))

                    TaskResultView(viewModel: viewModel.createTaskResultViewModel(for: .progressTasks))
                }
                .padding(
                    .horizontal,
                    Offset.screenBorderOffset)

                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            viewModel.showFolderPopup()
                        }) {
                            HStack(spacing: 4) {
                                Text(viewModel.selectedFolder?.wrappedName ?? "Все задачи")
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
                    VStack(
                        alignment: .leading,
                        spacing: Offset.screenBorderOffset
                    ) {
                        ForEach(viewModel.getFilteredTasks()) { task in
                            TaskItemView(viewModel: viewModel.createTaskItemViewModel(for: task))
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
        .sheet(isPresented: $viewModel.isPopupFolderVisible) {
            TaskFolderPopupView(
                isPresented: $viewModel.isPopupFolderVisible,
                selectedFolder: $viewModel.selectedFolder,
                folders: viewModel.folders
            )
            .presentationDetents([.height(300), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
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
