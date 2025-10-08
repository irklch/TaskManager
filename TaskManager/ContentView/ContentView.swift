//
//  ContentView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var viewContext: NSManagedObjectContext
    @StateObject private var viewModel: ContentViewViewModel = .init()
    @State var selectedFolder: TaskFolderNonDB
    
//    private lazy var tabItems: [TabItemModel] =  [
//        TabItemModel(
//            icon: "list.clipboard",
//            title: "Задачи",
//            view: AnyView()),
//        TabItemModel(
//            icon: "calendar",
//            title: "Календарь",
//            view: AnyView(CalendarView()))
//    ]
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.selectedFolder = DB.TaskFolderManager.getSelectedFolder(in: viewContext)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $viewModel.selectedIndex) {
//                ForEach(self.tabItems) { tabItem in
//                    tabItem.view
//                        .tag(index)
//                        .simultaneousGesture(
//                            DragGesture()
//                                .onChanged { value in
//                                    viewModel.handleScrollGesture(translation: value.translation)
//                                }
//                        )
//                }
                TaskScreenView(selectedFolder: $selectedFolder)
                CalendarView()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedIndex)

            getCustomTabBar()
                .padding(.bottom, 16)
                .padding(.trailing, 16)
                .offset(y: viewModel.isTabBarVisible ? 0 : 100)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isTabBarVisible)
        }
        .edgesIgnoringSafeArea([.bottom, .top])
        .background(.white)
        .fullScreenCover(isPresented: $viewModel.showAddTask) {
//            AddTaskView(
//                viewModel: .init(context: viewContext),
//                isPresented: $viewModel.showAddTask,
//                selectedFolder: $selectedFolder)
            AddTaskView()
        }
    }
    
    private func getCustomTabBar() -> CustomTabBar {
        let tabItems = [
            TabItemModel(
                icon: "list.clipboard",
                title: "Задачи"),
            TabItemModel(
                icon: "calendar",
                title: "Календарь")]
        
        
        let customTabBarViewModel: CustomTabBarViewModel = .init(
            selectedIndex: $viewModel.selectedIndex,
            tabItems: tabItems,
            onPlusTapped: {
                viewModel.showAddTaskView()
            }
        )
        return .init(viewModel: customTabBarViewModel)
    }
}


#Preview {
    ContentView(viewContext: PersistenceController.preview.container.viewContext)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
