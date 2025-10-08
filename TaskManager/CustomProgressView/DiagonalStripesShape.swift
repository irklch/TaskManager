//
//  DiagonalStripesShape.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI


struct DiagonalStripesShape: Shape {
    func path(in rect: CGRect) -> Path {
            var path = Path()
            let stripeWidth: CGFloat = 2
            let stripeSpacing: CGFloat = 6

            var x = -rect.height
            while x < rect.width {
                path.move(to: CGPoint(x: x + rect.height, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.maxY))
                x += stripeWidth + stripeSpacing
            }

            return path
        }
}
