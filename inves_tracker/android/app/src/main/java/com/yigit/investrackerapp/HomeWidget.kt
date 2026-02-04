package com.yigit.investrackerapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import org.json.JSONArray
import android.graphics.Color
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale

/**
 * Home Screen Widget for InvesTracker
 * Displays live market data (currencies, gold, crypto) with full localization support
 */
class HomeWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Update all active widgets
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // First widget added
    }

    override fun onDisabled(context: Context) {
        // Last widget removed
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val views = RemoteViews(context.packageName, R.layout.home_widget)

    try {
        // Get widget data from Flutter
        val widgetData = HomeWidgetPlugin.getData(context)
        val widgetDataJson = widgetData.getString("widget_data", null)
        val locale = widgetData.getString("widget_locale", "en") ?: "en"
        val lastUpdate = widgetData.getString("last_update", null)

        if (widgetDataJson != null) {
            val data = JSONObject(widgetDataJson)
            val labels = data.getJSONObject("labels")

            // Get formatter based on locale
            val formatter = getNumberFormatter(locale)

            // Update header
            views.setTextViewText(
                R.id.widget_title,
                labels.getString("currency")
            )

            // Update time
            val updateTime = data.optString("updateTime", "")
            if (updateTime.isNotEmpty()) {
                views.setTextViewText(
                    R.id.widget_update_time,
                    "${labels.getString("updated")}: $updateTime"
                )
            }

            // Display currencies
            val currencies = data.getJSONArray("currencies")
            displayCurrencies(views, currencies, labels, formatter)

            // For now, showing currencies. You can add gold/crypto in expanded layouts

        } else {
            // No data available
            views.setTextViewText(R.id.widget_title, "InvesTracker")
            views.setTextViewText(R.id.currency_1_code, "No data")
        }

    } catch (e: Exception) {
        // Handle error gracefully
        views.setTextViewText(R.id.widget_title, "InvesTracker")
        views.setTextViewText(R.id.currency_1_code, "Error loading data")
        e.printStackTrace()
    }

    // Update widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

/**
 * Display currency data in widget
 */
private fun displayCurrencies(
    views: RemoteViews,
    currencies: JSONArray,
    labels: JSONObject,
    formatter: DecimalFormat
) {
    // Currency row IDs (you'll create these in XML)
    val currencyRows = listOf(
        Triple(R.id.currency_1_code, R.id.currency_1_buying, R.id.currency_1_selling),
        Triple(R.id.currency_2_code, R.id.currency_2_buying, R.id.currency_2_selling),
        Triple(R.id.currency_3_code, R.id.currency_3_buying, R.id.currency_3_selling),
        Triple(R.id.currency_4_code, R.id.currency_4_buying, R.id.currency_4_selling)
    )

    for (i in 0 until minOf(currencies.length(), currencyRows.size)) {
        val currency = currencies.getJSONObject(i)
        val (codeId, buyingId, sellingId) = currencyRows[i]

        views.setTextViewText(codeId, currency.getString("code"))
        views.setTextViewText(
            buyingId,
            formatter.format(currency.getDouble("buying"))
        )
        views.setTextViewText(
            sellingId,
            formatter.format(currency.getDouble("selling"))
        )

        // Color code based on change
        val isIncreasing = currency.getBoolean("isIncreasing")
        val changeColor = if (isIncreasing) Color.parseColor("#4CAF50") else Color.parseColor("#F44336")

        // You can set colors on TextView if needed
        // views.setTextColor(codeId, changeColor)
    }
}

/**
 * Get number formatter based on locale
 */
private fun getNumberFormatter(locale: String): DecimalFormat {
    val symbols = if (locale == "tr") {
        DecimalFormatSymbols(Locale("tr", "TR"))
    } else {
        DecimalFormatSymbols(Locale.US)
    }

    return DecimalFormat("#,##0.0000", symbols)
}