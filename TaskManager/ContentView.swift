//
//  ContentView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedIndex = 0
    private let tabItems = [
        TabItemModel(icon: "calendar", view: AnyView(TaskScreenView())),
        TabItemModel(icon: "list.clipboard", view: AnyView(CalendarView()))
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            tabItems[selectedIndex].view

            getCustomTabBar()
                .padding(.bottom, 16)
                .padding(.trailing, 16)

        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.white)
    }

    private func getCustomTabBar() -> CustomTabBar {
        let customTabBarViewModel: CustomTabBarViewModel = .init(
            selectedIndex: $selectedIndex,
            tabItems: tabItems)
        return .init(viewModel: customTabBarViewModel)
    }
}


#Preview {
    ContentView()
}
