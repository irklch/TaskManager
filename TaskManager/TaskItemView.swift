//
//  TaskItemView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI

final class TaskItemViewModel: ObservableObject {
    let sideArrowViewModel: SideArrowViewModel?
    let title: String
    let timeInterval: String
    let description: String
    let progress: ProgressModel?
    let style: Style

    @Published var isDone: Bool

    init(
        title: String,
        timeInterval: String,
        description: String,
        progress: ProgressModel?,
        isDone: Bool,
        style: Style,
        sideArrowViewModel: SideArrowViewModel?
    ) {
        self.title = title
        self.timeInterval = timeInterval
        self.description = description
        self.progress = progress
        self.isDone = isDone
        self.style = style
        self.sideArrowViewModel = sideArrowViewModel
    }
    
    struct ProgressModel {
        let progressViewModel: CustomProgressViewModel
        let percentText: String

        init(
            progressViewModel: CustomProgressViewModel
        ) {
            self.progressViewModel = progressViewModel
            self.percentText = (progressViewModel.doneTasksPercent * 100).rounded().formatted().description + "%"
        }
    }

    struct Style {
        let textColor: Color
        let backgroundColor: Color
        let timeColor: Color

        static let whiteStyle: Style = .init(
            textColor: .hex000101,
            backgroundColor: .white,
            timeColor: .gray)

        static let blueStyle: Style = .init(
            textColor: .white,
            backgroundColor: .hex316AFD,
            timeColor: .white.opacity(10))
        
        static let grayStyle: Style = .init(
            textColor: .hex000101,
            backgroundColor: .hexF2F2F2,
            timeColor: .hex000101.opacity(10))
    }
}

struct TaskItemView: View {
    @ObservedObject private var viewModel: TaskItemViewModel

    init(viewModel: TaskItemViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {

            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.title)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 20))
                        .fontWeight(.regular)
                        .foregroundColor(viewModel.style.textColor)
                        .strikethrough(viewModel.isDone)
                    if viewModel.sideArrowViewModel == nil {
                        checkboxView
                    }
                }.frame(maxWidth: .infinity)

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
        GeometryReader(content: { geometry in
            HStack(alignment: .center) {
                Button(action: {
                    withAnimation(nil) {
                        viewModel.isDone.toggle()
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
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
        })
        .frame(height: 40.0)
        .padding(.top, 10)
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
