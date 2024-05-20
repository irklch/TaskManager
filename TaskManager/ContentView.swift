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
        TabItem(icon: "list.clipboard", view: AnyView(TemplateView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext))),
        TabItem(icon: "calendar", view: AnyView(TaskView())),
        TabItem(icon: "calendar", view: AnyView(TaskView())),
        TabItem(icon: "calendar", view: AnyView(TaskView())),
    ]

    var body: some View {
        ZStack {
            tabItems[selectedIndex].view
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CustomTabBar(selectedIndex: $selectedIndex, tabItems: tabItems)
                        .padding(.bottom, 16)
                        .padding(.trailing, 16)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


#Preview {
    ContentView()
}
