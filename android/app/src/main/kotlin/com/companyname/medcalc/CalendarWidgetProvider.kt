package com.companyname.medcalc

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class CalendarWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_calendar)
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

            val monthLabel = prefs.getString("calendar_month_label", "") ?: ""
            views.setTextViewText(R.id.tv_month_label, monthLabel)

            val serviceIntent = Intent(context, CalendarGridService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.gv_calendar, serviceIntent)

            val templateIntent = Intent(context, MainActivity::class.java).apply {
                action = "es.antonborri.home_widget.action.LAUNCH"
            }
            val templatePendingIntent = PendingIntent.getActivity(
                context, appWidgetId, templateIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            views.setPendingIntentTemplate(R.id.gv_calendar, templatePendingIntent)

            val headerPendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("guidedose://home")
            )
            views.setOnClickPendingIntent(R.id.tv_month_label, headerPendingIntent)
            views.setOnClickPendingIntent(R.id.iv_logo, headerPendingIntent)

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
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.gv_calendar)
        }
    }
}
