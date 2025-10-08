//
//  CalendarView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 23.05.2024.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()

    var body: some View {
        VStack {
            getCalendarLineHStack()
            Spacer(minLength: 24)
            ScrollView(showsIndicators: false) {
                getDayVStack()
                getDaliTaskHStack()
            }
            .background(Color.white)
            .cornerRadius(20)
            .edgesIgnoringSafeArea(.bottom)
        }
        .background(Color.hexF2F2F2)
    }

    private func getDaliTaskHStack() -> some View {
        VStack(spacing: 16) {
            ForEach(Array(viewModel.tasksForSelectedDate.enumerated()), id: \.offset) { index, task in
                let time = ["10:00", "11:00", "12:00", "13:00"][index]
                let taskRowVM = viewModel.createTaskRowViewModel(for: task, time: time)
                
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text(taskRowVM.time)
                        .foregroundStyle(.hex000101)
                    TaskItemView(viewModel: taskRowVM.taskViewModel)
                }
                .padding([.leading, .trailing], 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 100)
    }

    private func getDayVStack() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.getSelectedDateName())
                .foregroundStyle(.hex000101)
                .font(.system(size: 36, weight: .light))

            Text(viewModel.getTasksCount())
                .foregroundStyle(.gray)
                .font(.system(size: 12))
                .padding(.top, 8)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .top], 16)
    }

    private func getCalendarLineHStack() -> some View {
        return HStack {
            Button(action: {
                viewModel.navigateToPreviousDate()
            }) {
                Image(systemName: "chevron.left")
            }
            .tint(Color.hex000101)
            Spacer()
            ForEach(viewModel.dates, id: \.self) { date in
                Button(action: {
                    viewModel.selectDate(at: date.index)
                }) {
                    if viewModel.isDateSelected(date) {
                        Text(date.numberWithMonth)
                            .font(.title3)
                            .foregroundStyle(.hexF2F2F2)
                            .padding([.top, .bottom], 7)
                            .padding([.leading, .trailing], 16)
                            .background(RoundedRectangle(cornerRadius: 20.0)
                                .tint(Color.hex316AFD))

                    } else {
                        Text(date.number)
                            .font(.title3)
                            .tint(Color.hex000101)
                    }
                }
                Spacer()
            }
            Button(action: {
                viewModel.navigateToNextDate()
            }) {
                Image(systemName: "chevron.right")
            }
            .tint(Color.hex000101)
        }
        .frame(maxWidth: .infinity)
        .padding([.leading, .trailing], 16)
    }
}


//#Preview {
//    ContentView()
//}
