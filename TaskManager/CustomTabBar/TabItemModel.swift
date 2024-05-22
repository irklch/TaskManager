//
//  TabItemModel.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 22.05.2024.
//

import SwiftUI

struct TabItemModel: Identifiable {
    let id: UUID = .init()
    let icon: String
    let view: AnyView
}
