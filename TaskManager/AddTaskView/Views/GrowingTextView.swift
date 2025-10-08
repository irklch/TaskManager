//
//  GrowingTextView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 08.10.2025.
//

import SwiftUI

struct GrowingTextView: View {
    @Binding var text: String
    @State private var textHeight: CGFloat = 120
    var placeholder: String
    var placeholderFont: Font
    
    private let minHeight: CGFloat = 120

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(placeholderFont)
                    .foregroundStyle(Color.gray.opacity(0.5))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
            }
            TextField("", text: $text, axis: .vertical)
                .font(placeholderFont)
                .foregroundColor(.hex000101)
                .lineLimit(5...10000)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
        }
        .onPreferenceChange(TextHeightPreferenceKey.self) { height in
            withAnimation(.easeInOut(duration: 0.1)) {
                textHeight = height
            }
        }
    }
}

// MARK: - Preference Key
private struct TextHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 120
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    AddTaskView()
}
