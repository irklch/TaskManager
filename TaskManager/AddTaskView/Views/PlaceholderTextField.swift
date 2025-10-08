//
//  PlaceholderTextField.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 08.10.2025.
//

import SwiftUI

struct PlaceholderTextField: View {
    var placeholder: String
    var placeholderFont: Font
    @Binding var text: String
    let onCommit: (() -> Void)?

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(placeholderFont)
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            if let onCommit {
                TextField("", text: $text, onCommit: onCommit)
                    .foregroundColor(.hex000101)
            } else {
                TextField("", text: $text)
                    .foregroundColor(.hex000101)
            }
        }
    }
}
