//
//  ContentView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = ContentViewViewModel()
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $viewModel.selectedIndex) {
                ForEach(viewModel.tabItems.indices, id: \.self) { index in
                    viewModel.tabItems[index].view
                        .tag(index)
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    viewModel.handleScrollGesture(translation: value.translation)
                                }
                        )
                }
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
            AddTaskView(
                isPresented: $viewModel.showAddTask,
                context: viewContext
            )
        }
    }

    private func getCustomTabBar() -> CustomTabBar {
        let customTabBarViewModel: CustomTabBarViewModel = .init(
            selectedIndex: $viewModel.selectedIndex,
            tabItems: viewModel.tabItems,
            onPlusTapped: {
                viewModel.showAddTaskView()
            }
        )
        return .init(viewModel: customTabBarViewModel)
    }
}


#Preview {
    ContentView()
}
