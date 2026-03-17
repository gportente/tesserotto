package com.gportente.tesserotto

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject

class TesserottoWidgetProvider : AppWidgetProvider() {
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
        val pinnedJson = widgetData.getString("pinned_card", null)

        if (pinnedJson != null) {
            try {
                val card = JSONObject(pinnedJson)
                val name = card.getString("name")
                val description = card.optString("description", "")
                val colorValue = if (card.has("colorValue") && !card.isNull("colorValue"))
                    card.getInt("colorValue") else null

                views.setTextViewText(R.id.tv_card_name, name)
                views.setTextViewText(R.id.tv_card_description, description)
                views.setViewVisibility(R.id.tv_hint, android.view.View.GONE)
                views.setViewVisibility(R.id.tv_card_description, if (description.isNotEmpty()) android.view.View.VISIBLE else android.view.View.GONE)

                if (colorValue != null) {
                    val bg = android.graphics.drawable.GradientDrawable()
                    bg.setColor(colorValue)
                    bg.cornerRadius = 40f
                    // RemoteViews doesn't support setBackground(Drawable) directly;
                    // use a tinted version of our shape via setInt
                    views.setInt(R.id.widget_root, "setBackgroundColor", colorValue)
                }
            } catch (_: Exception) {
                showPlaceholder(views)
            }
        } else {
            showPlaceholder(views)
        }

        // Tap opens the app
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launchIntent != null) {
            val pendingIntent = android.app.PendingIntent.getActivity(
                context, 0, launchIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun showPlaceholder(views: RemoteViews) {
        views.setTextViewText(R.id.tv_card_name, "Tesserotto")
        views.setTextViewText(R.id.tv_card_description, "")
        views.setViewVisibility(R.id.tv_card_description, android.view.View.GONE)
        views.setViewVisibility(R.id.tv_hint, android.view.View.VISIBLE)
    }
}
