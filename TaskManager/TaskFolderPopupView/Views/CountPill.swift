//
//  CountPill.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 12.10.2025.
//

import SwiftUI

struct CountPill: View {
    let count: Int
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text("Задач:")
                .font(.system(size: 14, weight: .light))
                .opacity(0.92)
            Text("\(count)")
                .font(.system(size: 14, weight: .light))
        }
        .foregroundColor(isSelected ? .white : .hex000101)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(isSelected ? Color.white.opacity(0.15) : .hexF2F2F2)
        )
    }
}
