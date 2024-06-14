//
//  CalendarView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 23.05.2024.
//

import SwiftUI

struct CalendarView: View {
    @State var selectedDateIndex: Int = 0

    struct DateFormat: Hashable {
        let index: Int
        let number: String
        let numberWithMonth: String

        init(
            index: Int
        ) {
            let today = Date()
            let calendar = Calendar.current
            let todateDay = calendar.date(byAdding: .day, value: index, to: today)!
            let dateMonthFormatter = DateFormatter()
            dateMonthFormatter.dateFormat = "dd MMMM"
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
            self.number = dayFormatter.string(from: todateDay)
            self.numberWithMonth = dateMonthFormatter.string(from: todateDay)
            self.index = index
        }
    }

    static func getDates(newIndex: Int) -> [DateFormat] {
        return [
            .init(index: newIndex-1),
            .init(index: newIndex),
            .init(index: newIndex+1),
            .init(index: newIndex+2)
        ]
    }

    @State var dates: [DateFormat] = getDates(newIndex: 0)

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dates = Self.getDates(newIndex: selectedDateIndex - 1)
                    selectedDateIndex = selectedDateIndex - 1

                }) {
                    Image(systemName: "chevron.left")
                }
                .tint(Color.hex000101)
                Spacer()
                ForEach(dates, id: \.self) { date in
                    Button(action: {
                        selectedDateIndex = date.index
                    }) {
                        if date.index == selectedDateIndex {
                            Text(date.numberWithMonth)
                                .font(.title3)
                                .padding([.top, .bottom], 7)
                                .padding([.leading, .trailing], 16)
                                .background(RoundedRectangle(cornerRadius: 20.0)
                                    .tint(Color.hex316AFD))
                                .tint(Color.hexF2F2F2)

                        } else {
                            Text(date.number)
                                .font(.title3)
                                .tint(Color.hex000101)
                        }
                    }
                    Spacer()
                }
                Button(action: {
                    dates = Self.getDates(newIndex: selectedDateIndex + 1)
                    selectedDateIndex = selectedDateIndex + 1
                }) {
                    Image(systemName: "chevron.right")
                }
                .tint(Color.hex000101)
            }
            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing], 16)
            ScrollView {
            }
            .background(Color.hexF2F2F2)
            .cornerRadius(20)
        }
    }
}


#Preview {
    ContentView()
}
