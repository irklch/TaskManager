//
//  ContentView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskFolder.name, ascending: true)],
        animation: .default)
    private var folders: FetchedResults<TaskFolder>
    
    @State private var selectedIndex = 0
    @State private var isTabBarVisible = true
    @State private var showAddTask = false
    @State private var selectedFolder: TaskFolder?

    private var tabItems: [TabItemModel] {
        [
            TabItemModel(
                icon: "list.clipboard",
                title: "Задачи",
                view: AnyView(TaskScreenView(
                    tasks: Array(tasks),
                    folders: Array(folders),
                    selectedFolder: .constant(selectedFolder)))),
            TabItemModel(
                icon: "calendar",
                title: "Календарь",
                view: AnyView(CalendarView()))
        ]
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedIndex) {
                ForEach(tabItems.indices, id: \.self) { index in
                    tabItems[index].view
                        .tag(index)
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    handleScrollGesture(translation: value.translation)
                                }
                        )
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: selectedIndex)

            getCustomTabBar()
                .padding(.bottom, 16)
                .padding(.trailing, 16)
                .offset(y: isTabBarVisible ? 0 : 100)
                .animation(.easeInOut(duration: 0.3), value: isTabBarVisible)
        }
        .edgesIgnoringSafeArea([.bottom, .top])
        .background(.white)
        .fullScreenCover(isPresented: $showAddTask) {
            AddTaskView(
                isPresented: $showAddTask,
                context: viewContext,
                selectedFolder: selectedFolder
            )
        }
    }

    private func handleScrollGesture(translation: CGSize) {
        let dy = translation.height
        
        // Скролл вниз (палец вверх, dy < 0) — скрыть таббар
        if dy < -50 && isTabBarVisible {
            isTabBarVisible = false
        }
        // Скролл вверх (палец вниз, dy > 0) — показать таббар
        else if dy > 50 && !isTabBarVisible {
            isTabBarVisible = true
        }
    }
    
    private func getCustomTabBar() -> CustomTabBar {
        let customTabBarViewModel: CustomTabBarViewModel = .init(
            selectedIndex: $selectedIndex,
            tabItems: tabItems,
            onPlusTapped: {
                showAddTask = true
            }
        )
        return .init(viewModel: customTabBarViewModel)
    }
}


#Preview {
    ContentView()
}
