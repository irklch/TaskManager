//
//  CalendarView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 23.05.2024.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()

    private let calendar: Calendar = .current

    private var days: [String] {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "EE"

        var weekSymbols = formatter.shortWeekdaySymbols ?? []
        let firstWeekdayIndex = calendar.firstWeekday - 1 // firstWeekday is 1-based index
        let sortedWeekSymbols = Array(weekSymbols[firstWeekdayIndex..<weekSymbols.count] + weekSymbols[0..<firstWeekdayIndex])

        return sortedWeekSymbols
    }

    private var monthDates: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        let startDate = monthFirstWeek.start
        let endDate = calendar.date(byAdding: .day, value: 42, to: startDate)!

        return calendar.generateDates(
            inside: DateInterval(start: startDate, end: endDate),
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        )
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(from: selectedDate))
                    .font(.headline)
                    .foregroundColor(.hex000101)
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.hex000101)
                }
            }

            GeometryReader { geometry in
                let width = geometry.size.width / 8
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(width)), count: 7), spacing: 0) {
                    ForEach(monthDates, id: \.self) { date in
                        Text(dateString(from: date))
                            .foregroundColor(isSameMonth(date) ? isToday(date) ? .hexF2F2F2 : .hex000101 : .clear)
                            .frame(width: width, height: width, alignment: .center)
                            .background(isToday(date) ? .hex316AFD : Color.clear)
                            .cornerRadius(width / 2)

                    }
                }
            }
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func isSameMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

#Preview {
    ContentView()
}

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents,
        matchingPolicy: MatchingPolicy
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(startingAfter: interval.start, matching: components, matchingPolicy: matchingPolicy) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}
