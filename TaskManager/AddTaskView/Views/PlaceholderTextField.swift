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
    let onSubmit: (() -> Void)?

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(placeholderFont)
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            TextField("", text: $text)
                .onSubmit {
                    onSubmit?()
                }
                .foregroundColor(.hex000101)
        }
    }
}
