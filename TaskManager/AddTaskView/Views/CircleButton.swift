//
//  CircleButton.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 08.10.2025.
//


import SwiftUI

private struct CircleButton: View {
    let icon: String
    var body: some View {
        Circle()
            .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
            .frame(width: 44, height: 44)
            .overlay(Image(systemName: icon).font(.system(size: 18, weight: .light)))
    }
}