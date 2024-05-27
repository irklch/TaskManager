//
//  TaskItemView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI

final class TaskItemViewModel: ObservableObject {
    let sideArrowViewModel: SideArrowViewModel = .init(
        backgroundColor: .hexF2F2F2,
        arrowColor: .hex000101)
    let title: String
    let timeInterval: String
    let description: String
    let itemType: ItemType
    @Published var isDone: Bool

    init(title: String, timeInterval: String, description: String, itemType: ItemType, isDone: Bool) {
        self.title = title
        self.timeInterval = timeInterval
        self.description = description
        self.itemType = itemType
        self.isDone = isDone
    }

    enum ItemType {
        case progress(ProgressModel)
        case checkbox
    }

    struct ProgressModel {
        let progressViewModel: CustomProgressViewModel
        let percentText: String

        init(
            allItems: Double,
            doneItems: Double
        ) {
            self.progressViewModel = .init(
                tasksCount: allItems,
                doneTasksCount: doneItems,
                doneTasksColor: .hex316AFD)
            self.percentText = (doneItems / allItems * 100).rounded().formatted().description + "%"
        }
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
                Text(viewModel.title)
                    .font(.system(size: 20))
                    .fontWeight(.regular)
                    .foregroundColor(.hex000101)
                    .strikethrough(viewModel.isDone)

                Text(viewModel.timeInterval)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding([.top, .bottom], 1.0)

                Text(viewModel.description)
                    .font(.subheadline)
                    .foregroundColor(.hex000101)
                    .font(.system(size: 14))
                switch viewModel.itemType {
                case .progress(let progressModel):
                    getProgressView(model: progressModel)
                case .checkbox:
                    getCheckboxView()
                }
            }
            .padding(18)
            .background(Color.white)
            .cornerRadius(28)

            SideArrowView(viewModel: viewModel.sideArrowViewModel)
            .padding(4)
        }
    }

    

    private func getCheckboxView() -> some View {
        return GeometryReader(content: { geometry in
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

                Text(viewModel.isDone ? "Done" : "Tap to make it done")
                    .font(.title3)
                    .padding(.leading, 4)
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

#Preview {
    ContentView()
}
struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1.0) // Оставляем непрозрачность неизменной
            .scaleEffect(1.0) // Оставляем масштаб неизменным
    }
}
