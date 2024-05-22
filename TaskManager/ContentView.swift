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
        TabItemModel(icon: "list.clipboard", view: AnyView(TemplateView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext))),
        TabItemModel(icon: "calendar", view: AnyView(TaskView()))
    ]

    var body: some View {
        ZStack {
            tabItems[selectedIndex].view
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    getCustomTabBar()
                        .padding(.bottom, 16)
                        .padding(.trailing, 16)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
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
