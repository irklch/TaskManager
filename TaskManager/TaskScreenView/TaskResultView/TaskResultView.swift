//
//  TaskResultView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI

struct TaskResultView: View {
    private let viewModel: TaskResultViewModel

    init(viewModel: TaskResultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.titleText)
                    .font(.system(size: 12))
                    .frame(alignment: .leading)
                    .foregroundStyle(viewModel.resultType.textColor)
                    .padding(.bottom, 20)

                Text(viewModel.subtitleText)
                    .font(.system(size: 24))
                    .foregroundStyle(viewModel.resultType.textColor)
                    .padding(.bottom, 14)
                CustomProgressView(viewModel: viewModel.progressViewModel)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.resultType.backgroundColor)
            .cornerRadius(28)

            SideArrowView(viewModel: viewModel.sideArrowViewModel)
                .padding(4)
        }
    }
}

#Preview {
    TaskScreenView()
}


