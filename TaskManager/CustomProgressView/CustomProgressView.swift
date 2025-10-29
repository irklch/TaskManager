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
            let availableWidth = geometry.size.width.isFinite && geometry.size.width > 0 ? geometry.size.width : 0
            let percent = viewModel.doneTasksPercent.isFinite ? max(0, min(1, viewModel.doneTasksPercent)) : 0
            let colorWidth = max(ceil(availableWidth * percent), 0)
            let diagonalStripesWidth = max(ceil(availableWidth - colorWidth), 0)
            
            let safeColorWidth = colorWidth.isFinite ? colorWidth : 0
            let safeDiagonalStripesWidth = diagonalStripesWidth.isFinite ? diagonalStripesWidth : 0
            HStack(spacing: 0) {
                RoundedRectangle(cornerSize: .init(
                    width: Offset.viewHeight,
                    height: Offset.viewHeight))
                .fill(viewModel.doneTasksColor)
                .frame(width: safeColorWidth, height: Offset.viewHeight)
                .padding(.trailing, 2)
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
                        width: safeDiagonalStripesWidth,
                        height: Offset.viewHeight)
            }
        }
        .frame(height: Offset.viewHeight, alignment: .center)
    }
}
