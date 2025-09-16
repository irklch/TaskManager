//
//  ContentView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedIndex = 1
    @State private var isTabBarVisible = true
    private var tabItems: [TabItemModel] {
        [
            TabItemModel(icon: "list.clipboard", view: AnyView(TaskScreenView())),
            TabItemModel(icon: "calendar", view: AnyView(CalendarView()))
        ]
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            tabItems[selectedIndex].view
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

            getCustomTabBar()
                .padding(.bottom, 16)
                .padding(.trailing, 16)
                .offset(y: isTabBarVisible ? 0 : 100)
                .animation(.easeInOut(duration: 0.3), value: isTabBarVisible)
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
