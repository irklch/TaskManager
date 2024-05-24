//
//  SideArrowView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI

struct SideArrowView: View {
    let viewModel: SideArrowViewModel

    init(
        viewModel: SideArrowViewModel
    ) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 40)
                .fill(viewModel.backgroundColor)
                .frame(width: 50, height: 50)
            Image(systemName: "arrow.up.right")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundStyle(viewModel.arrowColor)
        }

    }
}

