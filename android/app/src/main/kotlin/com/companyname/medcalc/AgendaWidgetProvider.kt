package com.companyname.medcalc

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class AgendaWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_agenda)
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val eventsJson = prefs.getString("agenda_items_json", "[]") ?: "[]"
            val hasEvents = eventsJson != "[]" && eventsJson.contains("\"t\":\"e\"")

            if (hasEvents) {
                views.setViewVisibility(R.id.lv_agenda, View.VISIBLE)
                views.setViewVisibility(R.id.tv_empty, View.GONE)
            } else {
                views.setViewVisibility(R.id.lv_agenda, View.GONE)
                views.setViewVisibility(R.id.tv_empty, View.VISIBLE)
            }

            val serviceIntent = Intent(context, AgendaListService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.lv_agenda, serviceIntent)
            views.setEmptyView(R.id.lv_agenda, R.id.tv_empty)

            val templateIntent = Intent(context, MainActivity::class.java).apply {
                action = "es.antonborri.home_widget.action.LAUNCH"
            }
            val templatePendingIntent = PendingIntent.getActivity(
                context, 1000 + appWidgetId, templateIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            views.setPendingIntentTemplate(R.id.lv_agenda, templatePendingIntent)

            val headerPendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("guidedose://home")
            )
            views.setOnClickPendingIntent(R.id.iv_logo, headerPendingIntent)
            views.setOnClickPendingIntent(R.id.tv_add, headerPendingIntent)

            views.setOnClickPendingIntent(R.id.btn_divider, HomeWidgetLaunchIntent.getActivity(
                context, MainActivity::class.java, Uri.parse("guidedose://divider")
            ))
            views.setOnClickPendingIntent(R.id.btn_ai, HomeWidgetLaunchIntent.getActivity(
                context, MainActivity::class.java, Uri.parse("guidedose://ai")
            ))
            views.setOnClickPendingIntent(R.id.btn_notes, HomeWidgetLaunchIntent.getActivity(
                context, MainActivity::class.java, Uri.parse("guidedose://notes")
            ))

            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.lv_agenda)
        }
    }
}
