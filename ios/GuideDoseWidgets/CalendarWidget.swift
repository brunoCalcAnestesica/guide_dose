import WidgetKit
import SwiftUI

private struct CalendarEntry: TimelineEntry {
    let date: Date
    let monthLabel: String
    let days: [CalendarDay]
    let calendarYear: Int
    let calendarMonth: Int
}

private struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), monthLabel: "Fevereiro 2026", days: [], calendarYear: 2026, calendarMonth: 2)
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(buildEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let entry = buildEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func buildEntry() -> CalendarEntry {
        CalendarEntry(
            date: Date(),
            monthLabel: WidgetDataReader.calendarMonthLabel(),
            days: WidgetDataReader.calendarDays(),
            calendarYear: WidgetDataReader.calendarYear(),
            calendarMonth: WidgetDataReader.calendarMonth()
        )
    }
}

private let googleBlue = Color(red: 0.102, green: 0.451, blue: 0.910)
private let guideDosePrimary = Color(red: 0.102, green: 0.157, blue: 0.282)
private let textPrimary = Color(red: 0.125, green: 0.129, blue: 0.141)
private let textSecondary = Color(red: 0.373, green: 0.388, blue: 0.416)

private struct CalendarWidgetView: View {
    let entry: CalendarEntry

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    private let weekDays = ["D", "S", "T", "Q", "Q", "S", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Text(entry.monthLabel)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textPrimary)
                Spacer()
                Link(destination: URL(string: "guidedose://divider")!) {
                    Image(systemName: "rectangle.split.1x2")
                        .font(.system(size: 13))
                        .foregroundColor(guideDosePrimary)
                }
                Link(destination: URL(string: "guidedose://ai")!) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                        .foregroundColor(guideDosePrimary)
                }
                Link(destination: URL(string: "guidedose://notes")!) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 13))
                        .foregroundColor(guideDosePrimary)
                }
            }
            .padding(.bottom, 4)

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekDays[i])
                        .font(.system(size: 11))
                        .foregroundColor(textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 2)

            if entry.days.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("Abra o app para carregar")
                        .font(.system(size: 12))
                        .foregroundColor(textSecondary)
                    Spacer()
                }
                Spacer()
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<entry.days.count, id: \.self) { i in
                        let day = entry.days[i]
                        if day.day > 0, let url = dayURL(day.day) {
                            Link(destination: url) {
                                dayCellView(day)
                            }
                        } else {
                            dayCellView(day)
                        }
                    }
                }
            }
        }
        .padding(12)
    }

    private func dayURL(_ day: Int) -> URL? {
        let y = entry.calendarYear
        let m = String(format: "%02d", entry.calendarMonth)
        let d = String(format: "%02d", day)
        return URL(string: "guidedose://day?date=\(y)-\(m)-\(d)")
    }

    @ViewBuilder
    private func dayCellView(_ day: CalendarDay) -> some View {
        if day.day == 0 {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: 58)
        } else {
            VStack(spacing: 1) {
                ZStack {
                    if day.isToday {
                        Circle()
                            .fill(googleBlue)
                            .frame(width: 22, height: 22)
                    }
                    Text("\(day.day)")
                        .font(.system(size: 12))
                        .foregroundColor(day.isToday ? .white : textPrimary)
                }
                .frame(height: 22)

                ForEach(0..<min(day.events.count, 3), id: \.self) { ei in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(WidgetDataReader.colorFromInt(day.events[ei].c))
                        .frame(maxWidth: .infinity, minHeight: 4, maxHeight: 4)
                        .padding(.horizontal, 1)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 58)
        }
    }
}

struct CalendarGoogleWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            CalendarWidgetView(entry: entry)
                .containerBackground(.white, for: .widget)
        }
        .configurationDisplayName("Calendário")
        .description("Grade mensal com seus plantões")
        .supportedFamilies([.systemLarge])
    }
}
