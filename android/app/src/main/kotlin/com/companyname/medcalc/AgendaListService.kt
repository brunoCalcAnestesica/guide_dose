package com.companyname.medcalc

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray

class AgendaListService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return AgendaListFactory(applicationContext)
    }
}

private class AgendaListFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {

    private sealed class AgendaRow {
        abstract val dateStr: String?
        data class DayHeader(val label: String, override val dateStr: String?) : AgendaRow()
        data class Event(
            val hospital: String,
            val time: String,
            val type: String,
            val color: Int,
            override val dateStr: String?
        ) : AgendaRow()
    }

    private var rows = listOf<AgendaRow>()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val json = prefs.getString("agenda_items_json", "[]") ?: "[]"
        val parsed = mutableListOf<AgendaRow>()
        var currentDateStr: String? = null
        try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                when (obj.getString("t")) {
                    "h" -> {
                        parsed.add(AgendaRow.DayHeader(obj.getString("label"), null))
                    }
                    "e" -> {
                        val colorStr = obj.optString("color", "4280391432")
                        val color = colorStr.toLongOrNull()?.toInt() ?: 0xFF1A73E8.toInt()
                        val date = obj.optString("date", "")
                        if (date.isNotEmpty()) currentDateStr = date
                        parsed.add(
                            AgendaRow.Event(
                                hospital = obj.getString("hospital"),
                                time = obj.getString("time"),
                                type = obj.optString("type", ""),
                                color = color,
                                dateStr = date.ifEmpty { currentDateStr }
                            )
                        )
                    }
                }
            }
        } catch (_: Exception) {}
        rows = parsed
    }

    override fun onDestroy() {}

    override fun getCount(): Int = rows.size

    override fun getViewAt(position: Int): RemoteViews {
        if (position >= rows.size) {
            return RemoteViews(context.packageName, R.layout.widget_agenda_day_header)
        }

        return when (val row = rows[position]) {
            is AgendaRow.DayHeader -> {
                val views = RemoteViews(context.packageName, R.layout.widget_agenda_day_header)
                views.setTextViewText(R.id.tv_day_label, row.label)
                views
            }
            is AgendaRow.Event -> {
                val views = RemoteViews(context.packageName, R.layout.widget_agenda_event)
                views.setTextViewText(R.id.tv_hospital, row.hospital)
                views.setTextViewText(R.id.tv_time, row.time)
                views.setTextViewText(R.id.tv_type, row.type)
                views.setInt(R.id.v_color_bar, "setBackgroundColor", row.color)

                val dateUri = if (!row.dateStr.isNullOrEmpty()) {
                    Uri.parse("guidedose://day?date=${row.dateStr}")
                } else {
                    Uri.parse("guidedose://home")
                }
                val fillInIntent = Intent().apply { data = dateUri }
                views.setOnClickFillInIntent(R.id.widget_agenda_event_root, fillInIntent)

                views
            }
        }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 2

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = false
}
