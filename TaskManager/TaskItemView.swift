//
//  TaskItemView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI

struct TaskItemView: View {
    @ObservedObject private var viewModel: TaskItemViewModel

    init(viewModel: TaskItemViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {

            VStack(alignment: .leading) {
                HStack(spacing: 12) {
                    Text(viewModel.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 20))
                        .fontWeight(.regular)
                        .foregroundColor(viewModel.style.textColor)
                        .strikethrough(viewModel.isDone)
                    if viewModel.sideArrowViewModel == nil {
                        checkboxView
                    }
                }

                Text(viewModel.timeInterval)
                    .font(.subheadline)
                    .foregroundColor(viewModel.style.timeColor)
                    .padding([.top, .bottom], 1.0)

                Text(viewModel.description)
                    .font(.subheadline)
                    .foregroundColor(viewModel.style.textColor)
                    .font(.system(size: 14))
                
                if let progressModel = viewModel.progress {
                    getProgressView(model: progressModel)
                }
            }
            .padding(18)
            .background(viewModel.style.backgroundColor)
            .cornerRadius(28)

            if let sideArrowViewModel = viewModel.sideArrowViewModel {
                SideArrowView(viewModel: sideArrowViewModel)
                    .padding(4)
            }
        }
    }

    private var checkboxView: some View {
        Button(action: {
            withAnimation(nil) {
                viewModel.toggleDoneState()
            }
        }) {
            Image(systemName: viewModel.isDone ? "checkmark" : "checkmark")
                .font(.system(size: 15))
                .foregroundColor(viewModel.isDone ? .hexF2F2F2 : .white)
                .frame(
                    width: 40,
                    height: 40)
                .background(
                    ZStack {
                        if viewModel.isDone {
                            RoundedRectangle(cornerRadius: 40.0)
                                .fill(.hex316AFD)
                                .frame(width: 40, height: 40)
                        } else {
                            RoundedRectangle(cornerRadius: 40.0)
                                .stroke(Color.gray.opacity(0.7), lineWidth: 1)
                                .frame(width: 40, height: 40)
                        }
                    }
                )
        }
        .buttonStyle(NoHighlightButtonStyle())
    }

    private func getProgressView(model: TaskItemViewModel.ProgressModel) -> some View {
        return GeometryReader(content: { geometry in
            HStack(alignment: .center) {
                Text(model.percentText)
                    .foregroundStyle(.hex000101)
                    .font(.system(size: 18))

                let width = geometry.size.width / 1.5
                CustomProgressView(viewModel: model.progressViewModel)
                .frame(width: width)


            }
            .frame(
                width: geometry.size.width,
                height: CustomProgressView.Offset.viewHeight,
                alignment: .leading)
        })
        .frame(height: CustomProgressView.Offset.viewHeight)
        .padding([.top, .bottom], 16)
    }
}


struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1.0) // Оставляем непрозрачность неизменной
            .scaleEffect(1.0) // Оставляем масштаб неизменным
    }
}
