package com.yigit.investrackerapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import org.json.JSONArray
import android.app.PendingIntent
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale
import android.os.Bundle
import androidx.core.graphics.toColorInt

/**
 * Home Screen Widget for InvesTracker
 *
 * ══════════════════════════════════════════════════════════════════════════
 * HEIGHT-ADAPTIVE DISPLAY MODES
 * ══════════════════════════════════════════════════════════════════════════
 *
 *   Mode 1 — MIN_HEIGHT < 369 dp  :  header + column-headers + 4 currencies
 *   Mode 2 — MIN_HEIGHT < 514 dp  :  Mode 1 + divider + 4 golds
 *   Mode 3 — MIN_HEIGHT ≥ 514 dp  :  Mode 2 + divider + 4 cryptos
 *
 * Measured content heights (all dp — must match home_widget.xml exactly):
 *   Root padding top+bottom          :  12  (6dp × 2)
 *   Header row  (24dp + 4dp margin)  :  28
 *   Column-header row                :  18
 *   4 item rows × (32dp + 2dp gap)   : 136
 *                                   ─────
 *   Mode 1 total                     : 194 dp
 *
 *   Divider (1dp + 2dp + 6dp)        :   9
 *   4 gold rows                      : 136
 *                                   ─────
 *   Mode 2 total                     : 339 dp
 *
 *   Divider                          :   9
 *   4 crypto rows                    : 136
 *                                   ─────
 *   Mode 3 total                     : 484 dp
 *
 * Thresholds = content height + 30 dp safety buffer:
 *   MODE_2_THRESHOLD_DP = 369   (= 339 + 30)
 *   MODE_3_THRESHOLD_DP = 514   (= 484 + 30)
 *
 * ══════════════════════════════════════════════════════════════════════════
 * WHY OPTION_APPWIDGET_MIN_HEIGHT
 * ══════════════════════════════════════════════════════════════════════════
 * MIN_HEIGHT is the smallest guaranteed height for the current widget size
 * in portrait orientation. MAX_HEIGHT can be inflated by some launchers
 * (especially Samsung One UI), causing over-estimation of available space
 * and partially-visible rows. MIN_HEIGHT is the conservative, reliable value.
 *
 * ══════════════════════════════════════════════════════════════════════════
 * WHY ROOT LAYOUT IS match_parent
 * ══════════════════════════════════════════════════════════════════════════
 * Android draws resize handles at the ALLOCATED cell boundary, not at the
 * edge of widget content. With wrap_content, the background shrinks to the
 * content size but handles remain at the full cell edge — they visually
 * extend "outside" the visible widget. With match_parent, the background
 * and handles are always flush with each other.
 */
class HomeWidget : AppWidgetProvider() {

    companion object {
        const val ACTION_REFRESH = "com.yigit.investrackerapp.ACTION_REFRESH"

        /**
         * Height thresholds in dp.
         * Must match the content-height calculations documented above.
         */
        internal const val MODE_2_THRESHOLD_DP = 369   // show golds   when ≥ this
        internal const val MODE_3_THRESHOLD_DP = 514   // show cryptos when ≥ this
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle?
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        android.util.Log.d("HomeWidget", "onReceive: ${intent.action}")

        if (intent.action == ACTION_REFRESH) {
            try {
                val workRequest =
                    androidx.work.OneTimeWorkRequestBuilder<WidgetUpdateWorker>()
                        .addTag("widget_manual_refresh")
                        .setInitialDelay(0, java.util.concurrent.TimeUnit.SECONDS)
                        .build()
                androidx.work.WorkManager.getInstance(context).enqueue(workRequest)
                android.util.Log.d("HomeWidget", "Refresh work enqueued")
                showLoadingState(context)
            } catch (e: Exception) {
                android.util.Log.e("HomeWidget", "Error in refresh handler", e)
            }
        }
    }

    private fun showLoadingState(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = android.content.ComponentName(context, HomeWidget::class.java)
        for (id in appWidgetManager.getAppWidgetIds(componentName)) {
            val views = RemoteViews(context.packageName, R.layout.home_widget)
            views.setTextViewText(R.id.widget_update_time, "Updating…")
            setupRefreshButton(views, context, id)
            appWidgetManager.partiallyUpdateAppWidget(id, views)
        }
    }

    override fun onEnabled(context: Context) {
        android.util.Log.d("HomeWidget", "Widget enabled — scheduling periodic updates")
        androidx.work.PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
            30, java.util.concurrent.TimeUnit.MINUTES
        )
            .addTag("widget_periodic_update")
            .setConstraints(
                androidx.work.Constraints.Builder()
                    .setRequiredNetworkType(androidx.work.NetworkType.CONNECTED)
                    .build()
            )
            .build()
            .let { req ->
                androidx.work.WorkManager.getInstance(context)
                    .enqueueUniquePeriodicWork(
                        "widget_periodic_update",
                        androidx.work.ExistingPeriodicWorkPolicy.KEEP,
                        req
                    )
            }
    }

    override fun onDisabled(context: Context) {
        android.util.Log.d("HomeWidget", "Widget disabled — cancelling periodic updates")
        androidx.work.WorkManager.getInstance(context)
            .cancelAllWorkByTag("widget_periodic_update")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────────────────────────────────────

data class ItemCapacity(
    val currencies: Int,
    val golds: Int,
    val cryptos: Int
)

// ─────────────────────────────────────────────────────────────────────────────
// Mode selection
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Maps the current widget height to a display mode.
 *
 * We read OPTION_APPWIDGET_MIN_HEIGHT because it is the conservative,
 * guaranteed-available height in portrait on all launchers. MAX_HEIGHT
 * can be inflated by some launchers causing partial-row clipping.
 *
 * The 30 dp buffer in each threshold accounts for:
 *   • Launcher-internal cell padding not reflected in the reported value
 *   • Rounding differences across screen densities
 *   • Samsung One UI reporting quirks
 */
internal fun calculateItemCapacity(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
): ItemCapacity {
    val options = appWidgetManager.getAppWidgetOptions(appWidgetId)

    // Use MIN_HEIGHT — the reliable conservative value for portrait widgets.
    // Default 200dp keeps us safely in Mode 1 on first inflate before sizing is known.
    val heightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 200)

    android.util.Log.d(
        "HomeWidget",
        "MIN_HEIGHT=${heightDp}dp | " +
                "mode2_thresh=${HomeWidget.MODE_2_THRESHOLD_DP}dp | " +
                "mode3_thresh=${HomeWidget.MODE_3_THRESHOLD_DP}dp"
    )

    return when {
        heightDp < HomeWidget.MODE_2_THRESHOLD_DP -> {
            android.util.Log.d("HomeWidget", "→ Mode 1 (currencies only, content=194dp)")
            ItemCapacity(currencies = 4, golds = 0, cryptos = 0)
        }
        heightDp < HomeWidget.MODE_3_THRESHOLD_DP -> {
            android.util.Log.d("HomeWidget", "→ Mode 2 (currencies+golds, content=339dp)")
            ItemCapacity(currencies = 4, golds = 4, cryptos = 0)
        }
        else -> {
            android.util.Log.d("HomeWidget", "→ Mode 3 (all, content=484dp)")
            ItemCapacity(currencies = 4, golds = 4, cryptos = 4)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget update entry point
// ─────────────────────────────────────────────────────────────────────────────

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val views = RemoteViews(context.packageName, R.layout.home_widget)

    try {
        val prefs = HomeWidgetPlugin.getData(context)
        val widgetDataJson = prefs.getString("widget_data", null)
        val locale = prefs.getString("widget_locale", "en") ?: "en"

        if (widgetDataJson != null) {
            val data = JSONObject(widgetDataJson)
            val labels = data.getJSONObject("labels")
            val formatter = getNumberFormatter(locale)
            val capacity = calculateItemCapacity(context, appWidgetManager, appWidgetId)

            // Header
            views.setTextViewText(R.id.widget_title, "InvesTracker")
            val updateTime = data.optString("updateTime", "")
            if (updateTime.isNotEmpty()) {
                views.setTextViewText(
                    R.id.widget_update_time,
                    "${labels.getString("updated")}: ${extractTimeFromDateTime(updateTime)}"
                )
            }

            // Column headers
            views.setViewVisibility(R.id.column_headers, android.view.View.VISIBLE)
            views.setTextViewText(R.id.header_code, labels.getString("code"))
            views.setTextViewText(R.id.header_buy, labels.getString("buying"))
            views.setTextViewText(R.id.header_sell, labels.getString("selling"))
            views.setTextViewText(R.id.header_change, labels.getString("change"))

            // Clear containers before re-populating
            views.removeAllViews(R.id.currency_container)
            views.removeAllViews(R.id.gold_container)
            views.removeAllViews(R.id.crypto_container)

            val currencies = data.getJSONArray("currencies")
            val golds = data.optJSONArray("golds")
            val cryptos = data.optJSONArray("cryptos")

            // Mode 1 – always shown
            displayItems(views, R.id.currency_container, currencies,
                capacity.currencies, formatter, context, "currency")

            // Mode 2 – golds
            if (capacity.golds > 0 && golds != null) {
                views.setViewVisibility(R.id.divider_1, android.view.View.VISIBLE)
                displayItems(views, R.id.gold_container, golds,
                    capacity.golds, formatter, context, "gold")
            } else {
                views.setViewVisibility(R.id.divider_1, android.view.View.GONE)
            }

            // Mode 3 – cryptos
            if (capacity.cryptos > 0 && cryptos != null) {
                views.setViewVisibility(R.id.divider_2, android.view.View.VISIBLE)
                displayItems(views, R.id.crypto_container, cryptos,
                    capacity.cryptos, formatter, context, "crypto")
            } else {
                views.setViewVisibility(R.id.divider_2, android.view.View.GONE)
            }

            setupRefreshButton(views, context, appWidgetId)

        } else {
            // No data yet — show placeholder
            views.setTextViewText(R.id.widget_title, "InvesTracker")
            views.removeAllViews(R.id.currency_container)
            views.addView(R.id.currency_container, createMessageView(context, "No data"))
        }

    } catch (e: Exception) {
        android.util.Log.e("HomeWidget", "Error updating widget", e)
        views.setTextViewText(R.id.widget_title, "InvesTracker")
        views.removeAllViews(R.id.currency_container)
        views.addView(R.id.currency_container, createMessageView(context, "Error loading data"))
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

// ─────────────────────────────────────────────────────────────────────────────
// View builders
// ─────────────────────────────────────────────────────────────────────────────

private fun displayItems(
    views: RemoteViews,
    containerId: Int,
    items: JSONArray,
    max: Int,
    formatter: DecimalFormat,
    context: Context,
    type: String
) {
    for (i in 0 until minOf(items.length(), max)) {
        val item = items.getJSONObject(i)
        views.addView(
            containerId,
            if (type == "crypto") createCryptoRow(context, item, formatter)
            else createItemRow(context, item, formatter, type)
        )
    }
}

@Suppress("DiscouragedApi")
private fun createItemRow(
    context: Context,
    item: JSONObject,
    formatter: DecimalFormat,
    type: String
): RemoteViews {
    val layoutId = context.resources.getIdentifier(
        "widget_item_row", "layout", context.packageName
    )
    val row = RemoteViews(context.packageName, layoutId)
    val code = item.getString("code")

    // Display text: localised gold name when available, otherwise the code
    val label = if (type == "gold" && item.has("name")) item.getString("name") else code

    // Icon
    when (type) {
        "currency" -> {
            val id = context.resources.getIdentifier(
                "flag_${code.lowercase(Locale.getDefault())}", "drawable", context.packageName
            )
            row.setImageViewResource(
                R.id.item_icon,
                if (id != 0) id else android.R.drawable.ic_menu_report_image
            )
        }
        "gold" -> {
            val id = context.resources.getIdentifier("gold", "drawable", context.packageName)
            row.setImageViewResource(
                R.id.item_icon,
                if (id != 0) id else android.R.drawable.ic_menu_report_image
            )
        }
    }

    row.setTextViewText(R.id.item_code, label)
    row.setTextViewText(R.id.item_buying, formatter.format(item.getDouble("buying")))
    row.setTextViewText(R.id.item_selling, formatter.format(item.getDouble("selling")))

    val change = item.optDouble("change", 0.0)
    applyChangeStyle(row, change)
    return row
}

@Suppress("DiscouragedApi")
private fun createCryptoRow(
    context: Context,
    crypto: JSONObject,
    formatter: DecimalFormat
): RemoteViews {
    val layoutId = context.resources.getIdentifier(
        "widget_item_row", "layout", context.packageName
    )
    val row = RemoteViews(context.packageName, layoutId)
    val code = crypto.getString("code")

    val logoId = context.resources.getIdentifier(
        "crypto_${code.lowercase(Locale.getDefault())}", "drawable", context.packageName
    )
    row.setImageViewResource(
        R.id.item_icon,
        if (logoId != 0) logoId else android.R.drawable.ic_menu_info_details
    )

    row.setTextViewText(R.id.item_code, code)
    row.setTextViewText(
        R.id.item_buying,
        "$${formatter.format(crypto.getDouble("usdPrice"))}"
    )
    row.setTextViewText(
        R.id.item_selling,
        "$${formatter.format(crypto.getDouble("sellingUsd"))}"
    )

    applyChangeStyle(row, crypto.optDouble("change", 0.0))
    return row
}

/** Set the change text and colour on a row. */
private fun applyChangeStyle(row: RemoteViews, change: Double) {
    val increasing = change >= 0.0
    row.setTextViewText(
        R.id.item_change,
        String.format(Locale.getDefault(), "%s %.2f%%",
            if (increasing) "↑" else "↓",
            kotlin.math.abs(change))
    )
    row.setTextColor(
        R.id.item_change,
        if (increasing) "#4CAF50".toColorInt() else "#F44336".toColorInt()
    )
}

@Suppress("DiscouragedApi")
private fun createMessageView(context: Context, message: String): RemoteViews {
    val layoutId = context.resources.getIdentifier(
        "widget_item_row", "layout", context.packageName
    )
    return RemoteViews(context.packageName, layoutId).also { v ->
        v.setTextViewText(R.id.item_code, message)
        v.setViewVisibility(R.id.item_icon, android.view.View.GONE)
        v.setViewVisibility(R.id.item_buying, android.view.View.GONE)
        v.setViewVisibility(R.id.item_selling, android.view.View.GONE)
        v.setViewVisibility(R.id.item_change, android.view.View.GONE)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

internal fun setupRefreshButton(views: RemoteViews, context: Context, appWidgetId: Int) {
    val intent = Intent(context, HomeWidget::class.java).apply {
        action = HomeWidget.ACTION_REFRESH
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
    }
    val pi = PendingIntent.getBroadcast(
        context, appWidgetId, intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    views.setOnClickPendingIntent(R.id.refresh_button, pi)
}

private fun getNumberFormatter(locale: String): DecimalFormat {
    val symbols = if (locale == "tr")
        DecimalFormatSymbols(Locale.forLanguageTag("tr-TR"))
    else
        DecimalFormatSymbols(Locale.US)
    return DecimalFormat("#,##0.00##", symbols)
}

/** "2024-12-04 15:26:02"  →  "15:26" */
private fun extractTimeFromDateTime(dt: String): String =
    try {
        val parts = dt.split(" ")
        if (parts.size >= 2) {
            val t = parts[1].split(":")
            if (t.size >= 2) "${t[0]}:${t[1]}" else parts[1]
        } else dt
    } catch (_: Exception) { dt }