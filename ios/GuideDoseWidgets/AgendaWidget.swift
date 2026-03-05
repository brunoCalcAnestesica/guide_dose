import WidgetKit
import SwiftUI

private struct AgendaEntry: TimelineEntry {
    let date: Date
    let items: [AgendaItem]
}

private struct AgendaProvider: TimelineProvider {
    func placeholder(in context: Context) -> AgendaEntry {
        AgendaEntry(date: Date(), items: [
            AgendaItem(t: "h", label: "Hoje, 26 de fev", hospital: nil, time: nil, type: nil, color: nil, value: nil, date: nil),
            AgendaItem(t: "e", label: nil, hospital: "Hospital", time: "07:00 - 19:00", type: "Diurno", color: nil, value: nil, date: nil)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (AgendaEntry) -> Void) {
        completion(buildEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AgendaEntry>) -> Void) {
        let entry = buildEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func buildEntry() -> AgendaEntry {
        AgendaEntry(date: Date(), items: WidgetDataReader.agendaItems())
    }
}

private let googleBlue = Color(red: 0.102, green: 0.451, blue: 0.910)
private let guideDosePrimary = Color(red: 0.102, green: 0.157, blue: 0.282)
private let textPrimary = Color(red: 0.125, green: 0.129, blue: 0.141)
private let textSecondary = Color(red: 0.373, green: 0.388, blue: 0.416)

private struct AgendaWidgetView: View {
    let entry: AgendaEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Text("Guide Dose")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textPrimary)
                Spacer()
                Link(destination: URL(string: "guidedose://divider")!) {
                    Image(systemName: "rectangle.split.1x2")
                        .font(.system(size: 14))
                        .foregroundColor(guideDosePrimary)
                }
                Link(destination: URL(string: "guidedose://ai")!) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(guideDosePrimary)
                }
                Link(destination: URL(string: "guidedose://notes")!) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 14))
                        .foregroundColor(guideDosePrimary)
                }
                Link(destination: URL(string: "guidedose://home")!) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(googleBlue)
                }
            }
            .padding(.bottom, 8)

            Divider()
                .padding(.bottom, 4)

            if entry.items.isEmpty || !entry.items.contains(where: { $0.t == "e" }) {
                Spacer()
                HStack {
                    Spacer()
                    Text("Sem plantões nos próximos dias")
                        .font(.system(size: 13))
                        .foregroundColor(textSecondary)
                    Spacer()
                }
                Spacer()
            } else {
                let maxItems = family == .systemLarge ? 12 : 5
                let visibleItems = Array(entry.items.prefix(maxItems))

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<visibleItems.count, id: \.self) { i in
                        let item = visibleItems[i]
                        if item.t == "h" {
                            dayHeaderView(item)
                        } else if let dateStr = item.date, let url = URL(string: "guidedose://day?date=\(dateStr)") {
                            Link(destination: url) {
                                eventRowView(item)
                            }
                        } else {
                            eventRowView(item)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(12)
    }

    @ViewBuilder
    private func dayHeaderView(_ item: AgendaItem) -> some View {
        Text(item.label ?? "")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(googleBlue)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    @ViewBuilder
    private func eventRowView(_ item: AgendaItem) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(WidgetDataReader.colorFromString(item.color))
                .frame(width: 4, height: 36)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.hospital ?? "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(textPrimary)
                    .lineLimit(1)

                Text(item.time ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(textSecondary)
            }

            Spacer()

            Text(item.type ?? "")
                .font(.system(size: 11))
                .foregroundColor(textSecondary)
        }
        .padding(.vertical, 4)
    }
}

struct AgendaGoogleWidget: Widget {
    let kind: String = "AgendaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AgendaProvider()) { entry in
            AgendaWidgetView(entry: entry)
                .containerBackground(.white, for: .widget)
        }
        .configurationDisplayName("Agenda")
        .description("Próximos plantões dos 3 dias")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
