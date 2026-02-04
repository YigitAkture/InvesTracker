package com.yigit.investrackerapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import org.json.JSONArray
import android.graphics.Color
import android.app.PendingIntent
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale

/**
 * Home Screen Widget for InvesTracker
 * Displays live market data (currencies, gold, crypto) with full localization support
 */
class HomeWidget : AppWidgetProvider() {

    companion object {
        const val ACTION_REFRESH = "com.yigit.investrackerapp.ACTION_REFRESH"
    }

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

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.action == ACTION_REFRESH) {
            // Handle refresh button tap
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, HomeWidget::class.java)
            )

            // Trigger background refresh via Flutter
            val updateIntent = Intent(context, HomeWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            context.sendBroadcast(updateIntent)

            // Update all widgets
            onUpdate(context, appWidgetManager, appWidgetIds)

            android.util.Log.d("HomeWidget", "Refresh button tapped")
        }
    }

    override fun onEnabled(context: Context) {
        // First widget added
    }

    override fun onDisabled(context: Context) {
        // Last widget removed
    }
}

/**
 * Data class to hold widget item IDs
 */
data class ItemIds(
    val iconId: Int,
    val codeId: Int,
    val buyingId: Int,
    val sellingId: Int,
    val changeId: Int,
    val type: String
)

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

        if (widgetDataJson != null) {
            val data = JSONObject(widgetDataJson)
            val labels = data.getJSONObject("labels")

            // Get formatter based on locale
            val formatter = getNumberFormatter(locale)

            // Update header
            views.setTextViewText(R.id.widget_title, "InvesTracker")

            // Update time
            val updateTime = data.optString("updateTime", "")
            if (updateTime.isNotEmpty()) {
                views.setTextViewText(
                    R.id.widget_update_time,
                    "${labels.getString("updated")}: $updateTime"
                )
            }

            // Get data arrays
            val currencies = data.getJSONArray("currencies")
            val golds = data.optJSONArray("golds")
            val cryptos = data.optJSONArray("cryptos")

            // Display all data
            displayAllMarketData(views, currencies, golds, cryptos, formatter, context)

            // Setup refresh button
            setupRefreshButton(views, context, appWidgetId)

        } else {
            // No data available
            views.setTextViewText(R.id.widget_title, "InvesTracker")
            views.setTextViewText(R.id.item_1_code, "No data")
        }

    } catch (e: Exception) {
        // Handle error gracefully
        views.setTextViewText(R.id.widget_title, "InvesTracker")
        views.setTextViewText(R.id.item_1_code, "Error loading data")
        android.util.Log.e("HomeWidget", "Error updating widget", e)
    }

    // Update widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

/**
 * Setup refresh button with pending intent
 */
private fun setupRefreshButton(
    views: RemoteViews,
    context: Context,
    appWidgetId: Int
) {
    val refreshIntent = Intent(context, HomeWidget::class.java).apply {
        action = HomeWidget.ACTION_REFRESH
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
    }

    val pendingIntent = PendingIntent.getBroadcast(
        context,
        appWidgetId,
        refreshIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    views.setOnClickPendingIntent(R.id.refresh_button, pendingIntent)
}

/**
 * Display all market data (currencies, golds, cryptos)
 */
private fun displayAllMarketData(
    views: RemoteViews,
    currencies: JSONArray,
    golds: JSONArray?,
    cryptos: JSONArray?,
    formatter: DecimalFormat,
    context: Context
) {
    // Define all 11 item IDs
    val itemIds = listOf(
        // Currencies (1-5)
        ItemIds(R.id.item_1_icon, R.id.item_1_code, R.id.item_1_buying, R.id.item_1_selling, R.id.item_1_change, "currency"),
        ItemIds(R.id.item_2_icon, R.id.item_2_code, R.id.item_2_buying, R.id.item_2_selling, R.id.item_2_change, "currency"),
        ItemIds(R.id.item_3_icon, R.id.item_3_code, R.id.item_3_buying, R.id.item_3_selling, R.id.item_3_change, "currency"),
        ItemIds(R.id.item_4_icon, R.id.item_4_code, R.id.item_4_buying, R.id.item_4_selling, R.id.item_4_change, "currency"),
        ItemIds(R.id.item_5_icon, R.id.item_5_code, R.id.item_5_buying, R.id.item_5_selling, R.id.item_5_change, "currency"),
        // Golds (6-8)
        ItemIds(R.id.item_6_icon, R.id.item_6_code, R.id.item_6_buying, R.id.item_6_selling, R.id.item_6_change, "gold"),
        ItemIds(R.id.item_7_icon, R.id.item_7_code, R.id.item_7_buying, R.id.item_7_selling, R.id.item_7_change, "gold"),
        ItemIds(R.id.item_8_icon, R.id.item_8_code, R.id.item_8_buying, R.id.item_8_selling, R.id.item_8_change, "gold"),
        // Cryptos (9-11)
        ItemIds(R.id.item_9_icon, R.id.item_9_code, R.id.item_9_buying, R.id.item_9_selling, R.id.item_9_change, "crypto"),
        ItemIds(R.id.item_10_icon, R.id.item_10_code, R.id.item_10_buying, R.id.item_10_selling, R.id.item_10_change, "crypto"),
        ItemIds(R.id.item_11_icon, R.id.item_11_code, R.id.item_11_buying, R.id.item_11_selling, R.id.item_11_change, "crypto")
    )

    var currentIndex = 0

    // Display currencies (first 5 items)
    for (i in 0 until minOf(currencies.length(), 5)) {
        if (currentIndex >= itemIds.size) break
        val item = currencies.getJSONObject(i)
        val ids = itemIds[currentIndex++]
        displayItem(views, item, ids, formatter, context)
    }

    // Display golds (items 6-8)
    if (golds != null) {
        for (i in 0 until minOf(golds.length(), 3)) {
            if (currentIndex >= itemIds.size) break
            val item = golds.getJSONObject(i)
            val ids = itemIds[currentIndex++]
            displayItem(views, item, ids, formatter, context)
        }
    }

    // Display cryptos (items 9-11)
    if (cryptos != null) {
        for (i in 0 until minOf(cryptos.length(), 3)) {
            if (currentIndex >= itemIds.size) break
            val item = cryptos.getJSONObject(i)
            val ids = itemIds[currentIndex++]
            displayCryptoItem(views, item, ids, formatter, context)
        }
    }
}

/**
 * Display a single item (currency or gold)
 */
private fun displayItem(
    views: RemoteViews,
    item: JSONObject,
    ids: ItemIds,
    formatter: DecimalFormat,
    context: Context
) {
    val code = item.getString("code")

    // Set icon based on type
    when (ids.type) {
        "currency" -> {
            val flagResId = context.resources.getIdentifier(
                "flag_${code.lowercase(Locale.getDefault())}",
                "drawable",
                context.packageName
            )
            if (flagResId != 0) {
                views.setImageViewResource(ids.iconId, flagResId)
            } else {
                views.setImageViewResource(ids.iconId, android.R.drawable.ic_menu_report_image)
            }
        }
        "gold" -> {
            // Use default gold icon
            views.setImageViewResource(ids.iconId, android.R.drawable.btn_star_big_on)
        }
    }

    // Set text values
    views.setTextViewText(ids.codeId, code)
    views.setTextViewText(ids.buyingId, formatter.format(item.getDouble("buying")))
    views.setTextViewText(ids.sellingId, formatter.format(item.getDouble("selling")))

    // Set change indicator
    val isIncreasing = item.getBoolean("isIncreasing")
    val changeRate = item.getDouble("changeRate")
    val changeColor = if (isIncreasing) Color.parseColor("#4CAF50") else Color.parseColor("#F44336")
    val changeSymbol = if (isIncreasing) "↑" else "↓"

    views.setTextViewText(ids.changeId, String.format(Locale.getDefault(), "%s %.2f%%", changeSymbol, changeRate))
    views.setTextColor(ids.changeId, changeColor)
}

/**
 * Display a crypto item (slightly different format for USD prices)
 */
private fun displayCryptoItem(
    views: RemoteViews,
    crypto: JSONObject,
    ids: ItemIds,
    formatter: DecimalFormat,
    context: Context
) {
    val code = crypto.getString("code")

    // Load crypto logo
    val logoResId = context.resources.getIdentifier(
        "crypto_${code.lowercase(Locale.getDefault())}",
        "drawable",
        context.packageName
    )
    if (logoResId != 0) {
        views.setImageViewResource(ids.iconId, logoResId)
    } else {
        views.setImageViewResource(ids.iconId, android.R.drawable.ic_menu_info_details)
    }

    // Set text values (with $ symbol for crypto)
    views.setTextViewText(ids.codeId, code)
    views.setTextViewText(ids.buyingId, String.format(Locale.getDefault(), "$%s", formatter.format(crypto.getDouble("usdPrice"))))
    views.setTextViewText(ids.sellingId, String.format(Locale.getDefault(), "$%s", formatter.format(crypto.getDouble("sellingUsd"))))

    // Set change indicator
    val isIncreasing = crypto.getBoolean("isIncreasing")
    val changeRate = crypto.getDouble("changeRate")
    val changeColor = if (isIncreasing) Color.parseColor("#4CAF50") else Color.parseColor("#F44336")
    val changeSymbol = if (isIncreasing) "↑" else "↓"

    views.setTextViewText(ids.changeId, String.format(Locale.getDefault(), "%s %.2f%%", changeSymbol, changeRate))
    views.setTextColor(ids.changeId, changeColor)
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

    return DecimalFormat("#,##0.00##", symbols)
}