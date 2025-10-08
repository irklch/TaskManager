//
//  CircleCheckmarkToggleStyle.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 08.10.2025.
//

import SwiftUI

// MARK: - Apple Notes–like Checkbox
struct CircleCheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                configuration.isOn.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.hexF2F2F2, lineWidth: 2)
                    .frame(width: 26, height: 26)
                if configuration.isOn {
                    Circle()
                        .fill(Color.hex316AFD)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(configuration.isOn ? "checkmark" : "checkmark"))
    }
}
