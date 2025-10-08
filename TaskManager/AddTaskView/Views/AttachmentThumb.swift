//
//  AttachmentThumb.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 08.10.2025.
//

import SwiftUI

// MARK: - Attachment Thumb
struct AttachmentThumb: View {
    let image: Image
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: 116, height: 96)
            .clipped()
            .cornerRadius(16)
    }
}
