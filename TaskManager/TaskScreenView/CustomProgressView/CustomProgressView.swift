//
//  CustomProgressView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI

struct CustomProgressView: View {
    private let viewModel: CustomProgressViewModel

    init(
        viewModel: CustomProgressViewModel
    ) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            let colorWidth = geometry.size.width * viewModel.doneTasksPercent
            let diagonalStripesWidth = geometry.size.width - colorWidth
            HStack(spacing: 0) {
                RoundedRectangle(cornerSize: .init(
                    width: Offset.viewHeight,
                    height: Offset.viewHeight))
                .fill(viewModel.doneTasksColor)
                .frame(height: Offset.viewHeight)
                .padding(.trailing, 2)
                .frame(width: colorWidth)
                DiagonalStripesShape()
                    .stroke(style: 
                                StrokeStyle(
                                    lineWidth: 0.6))
                    .foregroundColor(.hex000101.opacity(0.7))
                    .background(.clear)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: Offset.viewHeight))
                    .padding(.leading, 2)
                    .frame(
                        width: diagonalStripesWidth,
                        height: Offset.viewHeight)
            }
        }
    }
}
#Preview {
    TaskScreenView()
}
