package com.gportente.tesserotto

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class TesserottoWidgetProvider : AppWidgetProvider() {

    private val rowIds = intArrayOf(R.id.row_0, R.id.row_1, R.id.row_2, R.id.row_3, R.id.row_4)
    private val dotIds = intArrayOf(R.id.dot_0, R.id.dot_1, R.id.dot_2, R.id.dot_3, R.id.dot_4)
    private val nameIds = intArrayOf(R.id.name_0, R.id.name_1, R.id.name_2, R.id.name_3, R.id.name_4)

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.widget_layout)
        val widgetData = HomeWidgetPlugin.getData(context)

        val cards = try {
            val json = widgetData.getString("top_cards", null)
            if (json != null) JSONArray(json) else JSONArray()
        } catch (_: Exception) {
            JSONArray()
        }

        val count = minOf(cards.length(), rowIds.size)
        views.setViewVisibility(R.id.tv_empty, if (count == 0) View.VISIBLE else View.GONE)

        for (i in rowIds.indices) {
            if (i < count) {
                val card = cards.getJSONObject(i)
                val id = card.optString("id", "")
                val name = card.optString("name", "")
                val color = if (card.has("colorValue") && !card.isNull("colorValue"))
                    card.getInt("colorValue") else 0xFFFFFFFF.toInt()

                views.setViewVisibility(rowIds[i], View.VISIBLE)
                views.setTextViewText(nameIds[i], name)
                views.setInt(dotIds[i], "setColorFilter", color)

                // Tapping a card opens the app directly on that card.
                views.setOnClickPendingIntent(
                    rowIds[i],
                    launchIntent(context, Uri.parse("tesserotto://card?id=" + Uri.encode(id)), i + 1)
                )
            } else {
                views.setViewVisibility(rowIds[i], View.GONE)
            }
        }

        // Tapping the header (or the empty state) opens the app home.
        val homeIntent = launchIntent(context, Uri.parse("tesserotto://home"), 0)
        views.setOnClickPendingIntent(R.id.tv_title, homeIntent)
        views.setOnClickPendingIntent(R.id.tv_empty, homeIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    /// Builds a PendingIntent that launches MainActivity carrying [uri].
    ///
    /// We build it manually instead of using [HomeWidgetLaunchIntent.getActivity]
    /// because that helper sets `pendingIntentBackgroundActivityStartMode` on
    /// API 34+, which is illegal when *creating* a PendingIntent and crashes the
    /// widget. We keep the same launch action so the home_widget plugin still
    /// detects the tap on the Flutter side.
    private fun launchIntent(context: Context, uri: Uri, requestCode: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
            data = uri
        }
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        return PendingIntent.getActivity(context, requestCode, intent, flags)
    }
}
