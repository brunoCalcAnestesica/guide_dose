import Foundation
import SwiftUI

let appGroupId = "group.com.companyname.medcalc.group"

struct CalendarEvent: Codable {
    let n: String
    let c: Int
}

struct CalendarDay: Codable {
    let day: Int
    let inMonth: Bool
    let isToday: Bool
    let events: [CalendarEvent]
}

struct AgendaItem: Codable {
    let t: String
    let label: String?
    let hospital: String?
    let time: String?
    let type: String?
    let color: String?
    let value: String?
    let date: String?
}

struct WidgetDataReader {
    private static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    static func calendarMonthLabel() -> String {
        userDefaults?.string(forKey: "calendar_month_label") ?? ""
    }

    static func calendarYear() -> Int {
        userDefaults?.integer(forKey: "calendar_year") ?? 0
    }

    static func calendarMonth() -> Int {
        userDefaults?.integer(forKey: "calendar_month") ?? 0
    }

    static func calendarDays() -> [CalendarDay] {
        guard let json = userDefaults?.string(forKey: "calendar_days_json"),
              let data = json.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([CalendarDay].self, from: data)) ?? []
    }

    static func agendaItems() -> [AgendaItem] {
        guard let json = userDefaults?.string(forKey: "agenda_items_json"),
              let data = json.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([AgendaItem].self, from: data)) ?? []
    }

    static func colorFromInt(_ value: Int) -> Color {
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }

    static func colorFromString(_ str: String?) -> Color {
        guard let str = str, let val = Int(str) else {
            return Color(red: 0.1, green: 0.45, blue: 0.91)
        }
        return colorFromInt(val)
    }
}
