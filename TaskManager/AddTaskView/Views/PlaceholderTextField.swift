//
//  PlaceholderTextField.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 08.10.2025.
//

import SwiftUI

struct PlaceholderTextField: View {
    var placeholder: String
    var font: Font
    @Binding var text: String
    let onSubmit: (() -> Void)?
    var placeholderColor: Color 
    var textColor: Color 
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(font)
                    .foregroundColor(placeholderColor)
            }
            TextField("", text: $text)
                .onSubmit {
                    onSubmit?()
                }
                .font(font)
                .foregroundColor(textColor)
        }
    }
}
