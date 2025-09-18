//
//  CustomTabBarViewModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 22.05.2024.
//

import SwiftUI

struct CustomTabBarViewModel {
    @Binding var selectedIndex: Int
    let tabItems: [TabItemModel]
    let onPlusTapped: (() -> Void)?
    
    init(selectedIndex: Binding<Int>, tabItems: [TabItemModel], onPlusTapped: (() -> Void)? = nil) {
        self._selectedIndex = selectedIndex
        self.tabItems = tabItems
        self.onPlusTapped = onPlusTapped
    }
}

