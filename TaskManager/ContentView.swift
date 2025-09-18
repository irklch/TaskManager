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
    
    private var tabItems: [TabItemModel] {
        [
            TabItemModel(icon: "list.clipboard", title: "Задачи", view: AnyView(TaskScreenView(tasks: Array(tasks), folders: Array(folders)))),
            TabItemModel(icon: "calendar", title: "Календарь", view: AnyView(CalendarView()))
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
                                    // Используем относительное смещение жеста по вертикали (CGSize.height)
                                    let dy = value.translation.height
                                    // Скролл вниз (палец вверх, dy < 0) — скрыть таббар
                                    if dy < -50 && isTabBarVisible {
                                        isTabBarVisible = false
                                    }
                                    // Скролл вверх (палец вниз, dy > 0) — показать таббар
                                    else if dy > 50 && !isTabBarVisible {
                                        isTabBarVisible = true
                                    }
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
                context: viewContext
            )
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
