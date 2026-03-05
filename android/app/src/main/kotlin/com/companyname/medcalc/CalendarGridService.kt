package com.companyname.medcalc

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray

class CalendarGridService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return CalendarGridFactory(applicationContext)
    }
}

private class CalendarGridFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {

    private data class EventInfo(val name: String, val color: Int)

    private data class DayCell(
        val day: Int,
        val inMonth: Boolean,
        val isToday: Boolean,
        val events: List<EventInfo>
    )

    private var cells = listOf<DayCell>()
    private var calendarYear = 0
    private var calendarMonth = 0

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        calendarYear = prefs.getInt("calendar_year", 0)
        calendarMonth = prefs.getInt("calendar_month", 0)

        val json = prefs.getString("calendar_days_json", "[]") ?: "[]"
        val parsed = mutableListOf<DayCell>()
        try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                val eventsArr = obj.getJSONArray("events")
                val eventsList = mutableListOf<EventInfo>()
                for (e in 0 until eventsArr.length()) {
                    val ev = eventsArr.getJSONObject(e)
                    eventsList.add(
                        EventInfo(
                            name = ev.getString("n"),
                            color = ev.getLong("c").toInt()
                        )
                    )
                }
                parsed.add(
                    DayCell(
                        day = obj.getInt("day"),
                        inMonth = obj.getBoolean("inMonth"),
                        isToday = obj.getBoolean("isToday"),
                        events = eventsList
                    )
                )
            }
        } catch (_: Exception) {}
        cells = parsed
    }

    override fun onDestroy() {}

    override fun getCount(): Int = cells.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_calendar_cell)

        if (position >= cells.size) return views
        val cell = cells[position]

        val eventIds = intArrayOf(R.id.tv_event1, R.id.tv_event2, R.id.tv_event3)

        if (cell.day == 0) {
            views.setTextViewText(R.id.tv_day, "")
            views.setViewVisibility(R.id.iv_today_bg, View.GONE)
            for (id in eventIds) views.setViewVisibility(id, View.GONE)
            return views
        }

        views.setTextViewText(R.id.tv_day, cell.day.toString())

        if (cell.isToday) {
            views.setViewVisibility(R.id.iv_today_bg, View.VISIBLE)
            views.setTextColor(R.id.tv_day, Color.WHITE)
        } else {
            views.setViewVisibility(R.id.iv_today_bg, View.GONE)
            views.setTextColor(R.id.tv_day, Color.parseColor("#202124"))
        }

        for (i in eventIds.indices) {
            if (i < cell.events.size) {
                views.setViewVisibility(eventIds[i], View.VISIBLE)
                views.setInt(eventIds[i], "setBackgroundColor", cell.events[i].color)
            } else {
                views.setViewVisibility(eventIds[i], View.GONE)
            }
        }

        val monthStr = calendarMonth.toString().padStart(2, '0')
        val dayStr = cell.day.toString().padStart(2, '0')
        val dateUri = Uri.parse("guidedose://day?date=$calendarYear-$monthStr-$dayStr")
        val fillInIntent = Intent().apply { data = dateUri }
        views.setOnClickFillInIntent(R.id.widget_calendar_cell_root, fillInIntent)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}
