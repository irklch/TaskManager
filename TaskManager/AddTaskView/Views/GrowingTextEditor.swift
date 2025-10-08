//
//  GrowingTextEditor.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 08.10.2025.
//

import SwiftUI

// MARK: - Auto-growing TextEditor
struct GrowingTextEditor: View {
    @Binding var text: String
    @State private var dynHeight: CGFloat = 120
    var placeholder: String
    var placeholderFont: Font

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(placeholderFont)
                    .foregroundStyle(Color.gray.opacity(0.5))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
            }
            TextEditor(text: $text)
                .frame(minHeight: 120, maxHeight: max(120, dynHeight))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
//                .padding(4)
                .background(GeometryReader { geo in
                    Color.clear
                        .onChange(of: text) {
                            dynHeight = max(120, geo.size.height)
                            #warning("Динамическую высоту сделать")
                        }
                })
        }
    }
}
