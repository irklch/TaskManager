//
//  CustomTabBar+Offset.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 22.05.2024.
//

import Foundation

extension CustomTabBar {
    enum Offset {
        static let pageSize: CGFloat = 60.0
        static let pageCornerRadius: CGFloat = pageSize / 2
        static let superViewBorderSpacing: CGFloat = 10.0
        static let pageSizeWithSpaces: CGFloat = pageSize + superViewBorderSpacing
        static let pageLeadingPadding: CGFloat = 4.0
        static let superViewCornerRadius: CGFloat = pageSizeWithSpaces / 2
    }
}
