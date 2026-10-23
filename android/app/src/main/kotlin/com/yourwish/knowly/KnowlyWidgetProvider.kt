package com.yourwish.knowly

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** 今日の雑学を表示するホーム画面ウィジェット。アプリが先の数日ぶんを書き込み、ここで今日の日付のものを選ぶ。 */
class KnowlyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val title = widgetData.getString("w_${today}_title", null)
        val body = widgetData.getString("w_${today}_body", null)
        val appName = widgetData.getString("w_app_name", null) ?: "Knowly"
        val hint = widgetData.getString("w_hint", null) ?: ""

        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pending = PendingIntent.getActivity(
            context, 0, launch ?: Intent(),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.knowly_widget)
            views.setTextViewText(R.id.widget_app_name, appName)
            views.setTextViewText(R.id.widget_title, title ?: hint)
            views.setTextViewText(R.id.widget_body, if (title == null) "" else (body ?: ""))
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
