import WidgetKit
import SwiftUI

@main
struct GuideDoseWidgetBundle: WidgetBundle {
    var body: some Widget {
        CalendarGoogleWidget()
        AgendaGoogleWidget()
    }
}
