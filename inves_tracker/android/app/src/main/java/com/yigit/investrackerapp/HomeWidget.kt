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
import android.util.TypedValue
import androidx.core.graphics.toColorInt

/**
 * REFACTORED Home Screen Widget for InvesTracker
 * - Displays exactly 4 items per category (currencies, golds, cryptos)
 * - Uses 'change' field directly from API
 * - Properly localizes gold names
 */
class HomeWidget : AppWidgetProvider() {

    companion object {
        const val ACTION_REFRESH = "com.yigit.investrackerapp.ACTION_REFRESH"

        // Layout dimension constants (in dp)
        internal const val HEADER_HEIGHT_DP = 40f
        internal const val COLUMN_HEADERS_HEIGHT_DP = 24f
        internal const val ITEM_HEIGHT_DP = 28f
        internal const val DIVIDER_HEIGHT_DP = 9f
        internal const val PADDING_VERTICAL_DP = 16f
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

        android.util.Log.d("HomeWidget", "========== onReceive CALLED ==========")
        android.util.Log.d("HomeWidget", "Action: ${intent.action}")

        if (intent.action == ACTION_REFRESH) {
            try {
                android.util.Log.d("HomeWidget", "✓ Refresh action matched!")

                // Create work request
                val workRequest = androidx.work.OneTimeWorkRequestBuilder<WidgetUpdateWorker>()
                    .addTag("widget_manual_refresh")
                    .setInitialDelay(0, java.util.concurrent.TimeUnit.SECONDS)
                    .build()

                // Enqueue work
                androidx.work.WorkManager.getInstance(context)
                    .enqueue(workRequest)

                android.util.Log.d("HomeWidget", "✓ Work enqueued to WorkManager")

                // Show loading state
                showLoadingState(context)

            } catch (e: Exception) {
                android.util.Log.e("HomeWidget", "✗ ERROR in refresh handler", e)
            }
        }

        android.util.Log.d("HomeWidget", "========== onReceive FINISHED ==========")
    }

    /**
     * Show a temporary loading indicator while refresh is in progress
     */
    private fun showLoadingState(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, HomeWidget::class.java)
        )

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.home_widget)
            views.setTextViewText(R.id.widget_update_time, "Updating...")

            // Setup refresh button (keep it clickable)
            setupRefreshButton(views, context, appWidgetId)

            appWidgetManager.partiallyUpdateAppWidget(appWidgetId, views)
        }
    }

    override fun onEnabled(context: Context) {
        // Widget is added to home screen
        android.util.Log.d("HomeWidget", "Widget enabled - setting up periodic updates")

        // Setup periodic background updates
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
            .let { workRequest ->
                androidx.work.WorkManager.getInstance(context)
                    .enqueueUniquePeriodicWork(
                        "widget_periodic_update",
                        androidx.work.ExistingPeriodicWorkPolicy.KEEP,
                        workRequest
                    )
            }
    }

    override fun onDisabled(context: Context) {
        // Last widget is removed from home screen
        android.util.Log.d("HomeWidget", "Widget disabled - cancelling background updates")

        // Cancel all background work
        androidx.work.WorkManager.getInstance(context)
            .cancelAllWorkByTag("widget_periodic_update")
    }
}

/**
 * Data class to hold calculated item capacities
 */
data class ItemCapacity(
    val currencies: Int,
    val golds: Int,
    val cryptos: Int
)

/**
 * UPDATED: Calculate item capacity for exactly 4 items per section
 */
internal fun calculateItemCapacity(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
): ItemCapacity {
    val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
    val heightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 200)

    // Widget will try to show: 4 currencies, 4 golds, 4 cryptos
    val displayMetrics = context.resources.displayMetrics

    // Calculate heights in pixels
    val headerHeightPx = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        HomeWidget.HEADER_HEIGHT_DP,
        displayMetrics
    )

    val columnHeadersHeightPx = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        HomeWidget.COLUMN_HEADERS_HEIGHT_DP,
        displayMetrics
    )

    val itemHeightPx = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        HomeWidget.ITEM_HEIGHT_DP,
        displayMetrics
    )

    val dividerHeightPx = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        HomeWidget.DIVIDER_HEIGHT_DP,
        displayMetrics
    )

    val paddingVerticalPx = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        HomeWidget.PADDING_VERTICAL_DP,
        displayMetrics
    )

    val totalHeightPx = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        heightDp.toFloat(),
        displayMetrics
    )

    // Calculate available height for items
    val fixedOverheadPx = headerHeightPx + paddingVerticalPx + columnHeadersHeightPx
    var remainingHeightPx = totalHeightPx - fixedOverheadPx

    // Start with 4 currencies (always show)
    val currencyItems = 4

    // Check if we have space for golds section (needs divider + at least 1 item)
    var goldItems = 0
    if (remainingHeightPx - (currencyItems * itemHeightPx) >= (dividerHeightPx + itemHeightPx)) {
        // Account for divider space
        remainingHeightPx -= (currencyItems * itemHeightPx + dividerHeightPx)

        // Allocate golds (max 4)
        val goldsPossible = (remainingHeightPx / itemHeightPx).toInt()
        goldItems = minOf(4, goldsPossible)

        // Check if we have space for cryptos section
        if (goldItems > 0) {
            remainingHeightPx -= (goldItems * itemHeightPx)

            var cryptoItems = 0
            if (remainingHeightPx >= (dividerHeightPx + itemHeightPx)) {
                remainingHeightPx -= dividerHeightPx

                // Allocate cryptos (max 4)
                val cryptosPossible = (remainingHeightPx / itemHeightPx).toInt()
                cryptoItems = minOf(4, cryptosPossible)
            }

            android.util.Log.d(
                "HomeWidget",
                "Widget height: ${heightDp}dp -> Currencies: $currencyItems, " +
                        "Golds: $goldItems, Cryptos: $cryptoItems"
            )

            return ItemCapacity(
                currencies = currencyItems,
                golds = goldItems,
                cryptos = cryptoItems
            )
        }
    }

    android.util.Log.d(
        "HomeWidget",
        "Widget height: ${heightDp}dp -> Currencies: $currencyItems, " +
                "Golds: $goldItems, Cryptos: 0"
    )

    return ItemCapacity(
        currencies = currencyItems,
        golds = goldItems,
        cryptos = 0
    )
}

/**
 * Update the widget with current data
 */
internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val views = RemoteViews(context.packageName, R.layout.home_widget)

    try {
        val widgetData = HomeWidgetPlugin.getData(context)
        val widgetDataJson = widgetData.getString("widget_data", null)
        val locale = widgetData.getString("widget_locale", "en") ?: "en"

        if (widgetDataJson != null) {
            val data = JSONObject(widgetDataJson)
            val labels = data.getJSONObject("labels")
            val formatter = getNumberFormatter(locale)

            // Calculate how many items we can display
            val capacity = calculateItemCapacity(context, appWidgetManager, appWidgetId)

            // Update header
            views.setTextViewText(R.id.widget_title, "InvesTracker")

            val updateTime = data.optString("updateTime", "")
            if (updateTime.isNotEmpty()) {
                // FIXED: Extract only time portion (HH:mm) from "2024-12-04 15:26:02"
                val timeOnly = extractTimeFromDateTime(updateTime)
                views.setTextViewText(
                    R.id.widget_update_time,
                    "${labels.getString("updated")}: $timeOnly"
                )
            }

            // Get data arrays
            val currencies = data.getJSONArray("currencies")
            val golds = data.optJSONArray("golds")
            val cryptos = data.optJSONArray("cryptos")

            // Clear all item containers
            views.removeAllViews(R.id.currency_container)
            views.removeAllViews(R.id.gold_container)
            views.removeAllViews(R.id.crypto_container)

            // Set column headers visibility and localized text
            views.setViewVisibility(R.id.column_headers, android.view.View.VISIBLE)
            views.setTextViewText(R.id.header_code, labels.getString("code"))
            views.setTextViewText(R.id.header_buy, labels.getString("buying"))
            views.setTextViewText(R.id.header_sell, labels.getString("selling"))
            views.setTextViewText(R.id.header_change, labels.getString("change"))

            // Display currencies
            displayDynamicItems(
                views,
                R.id.currency_container,
                currencies,
                capacity.currencies,
                formatter,
                context,
                "currency"
            )

            // Display golds (with divider if we have space)
            if (capacity.golds > 0 && golds != null) {
                views.setViewVisibility(R.id.divider_1, android.view.View.VISIBLE)
                displayDynamicItems(
                    views,
                    R.id.gold_container,
                    golds,
                    capacity.golds,
                    formatter,
                    context,
                    "gold"
                )
            } else {
                views.setViewVisibility(R.id.divider_1, android.view.View.GONE)
            }

            // Display cryptos (with divider if we have space)
            if (capacity.cryptos > 0 && cryptos != null) {
                views.setViewVisibility(R.id.divider_2, android.view.View.VISIBLE)
                displayDynamicItems(
                    views,
                    R.id.crypto_container,
                    cryptos,
                    capacity.cryptos,
                    formatter,
                    context,
                    "crypto"
                )
            } else {
                views.setViewVisibility(R.id.divider_2, android.view.View.GONE)
            }

            // Setup refresh button
            setupRefreshButton(views, context, appWidgetId)

        } else {
            views.setTextViewText(R.id.widget_title, "InvesTracker")
            views.removeAllViews(R.id.currency_container)
            val noDataView = createNoDataView(context, "No data")
            views.addView(R.id.currency_container, noDataView)
        }

    } catch (e: Exception) {
        views.setTextViewText(R.id.widget_title, "InvesTracker")
        views.removeAllViews(R.id.currency_container)
        val errorView = createNoDataView(context, "Error loading data")
        views.addView(R.id.currency_container, errorView)
        android.util.Log.e("HomeWidget", "Error updating widget", e)
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

/**
 * Display items dynamically based on capacity
 */
private fun displayDynamicItems(
    views: RemoteViews,
    containerId: Int,
    items: JSONArray,
    maxItems: Int,
    formatter: DecimalFormat,
    context: Context,
    type: String
) {
    val itemsToDisplay = minOf(items.length(), maxItems)

    for (i in 0 until itemsToDisplay) {
        val item = items.getJSONObject(i)
        val itemView = when (type) {
            "crypto" -> createCryptoItemView(context, item, formatter)
            else -> createItemView(context, item, formatter, type)
        }
        views.addView(containerId, itemView)
    }
}

/**
 * REFACTORED: Create item view with simplified change calculation
 * Uses 'change' field directly from API (positive/negative)
 */
@Suppress("DiscouragedApi")
private fun createItemView(
    context: Context,
    item: JSONObject,
    formatter: DecimalFormat,
    type: String
): RemoteViews {
    val layoutId = context.resources.getIdentifier(
        "widget_item_row",
        "layout",
        context.packageName
    )

    val itemView = RemoteViews(context.packageName, layoutId)
    val code = item.getString("code")

    // FIXED: For gold items, use localized name if available, otherwise use code
    val displayText = if (type == "gold" && item.has("name")) {
        item.getString("name")  // "Gram Altın" or "Gram Gold"
    } else {
        code  // "USD", "EUR", etc.
    }

    // Set icon based on type
    when (type) {
        "currency" -> {
            val flagResId = context.resources.getIdentifier(
                "flag_${code.lowercase(Locale.getDefault())}",
                "drawable",
                context.packageName
            )
            if (flagResId != 0) {
                itemView.setImageViewResource(R.id.item_icon, flagResId)
            } else {
                itemView.setImageViewResource(R.id.item_icon, android.R.drawable.ic_menu_report_image)
            }
        }
        "gold" -> {
            val goldResId = context.resources.getIdentifier(
                "gold",
                "drawable",
                context.packageName
            )
            if (goldResId != 0) {
                itemView.setImageViewResource(R.id.item_icon, goldResId)
            } else {
                itemView.setImageViewResource(R.id.item_icon, android.R.drawable.ic_menu_report_image)
            }
        }
    }

    // Set text values - use displayText for gold names
    itemView.setTextViewText(R.id.item_code, displayText)
    itemView.setTextViewText(R.id.item_buying, formatter.format(item.getDouble("buying")))
    itemView.setTextViewText(R.id.item_selling, formatter.format(item.getDouble("selling")))

    // SIMPLIFIED: Get change directly from API (can be positive or negative)
    val change = item.optDouble("change", 0.0)

    // Calculate display values
    val isIncreasing = change >= 0.0  // Zero or positive = green
    val changePercentage = kotlin.math.abs(change)  // Absolute value for display

    val changeColor = if (isIncreasing) "#4CAF50".toColorInt() else "#F44336".toColorInt()
    val changeSymbol = if (isIncreasing) "↑" else "↓"

    itemView.setTextViewText(
        R.id.item_change,
        String.format(Locale.getDefault(), "%s %.2f%%", changeSymbol, changePercentage)
    )
    itemView.setTextColor(R.id.item_change, changeColor)

    return itemView
}

/**
 * REFACTORED: Create crypto item view with simplified change calculation
 */
@Suppress("DiscouragedApi")
private fun createCryptoItemView(
    context: Context,
    crypto: JSONObject,
    formatter: DecimalFormat
): RemoteViews {
    val layoutId = context.resources.getIdentifier(
        "widget_item_row",
        "layout",
        context.packageName
    )

    val itemView = RemoteViews(context.packageName, layoutId)
    val code = crypto.getString("code")

    // Load crypto logo
    val logoResId = context.resources.getIdentifier(
        "crypto_${code.lowercase(Locale.getDefault())}",
        "drawable",
        context.packageName
    )
    if (logoResId != 0) {
        itemView.setImageViewResource(R.id.item_icon, logoResId)
    } else {
        itemView.setImageViewResource(R.id.item_icon, android.R.drawable.ic_menu_info_details)
    }

    // Set text values (with $ symbol for crypto)
    itemView.setTextViewText(R.id.item_code, code)
    itemView.setTextViewText(
        R.id.item_buying,
        String.format(Locale.getDefault(), "$%s", formatter.format(crypto.getDouble("usdPrice")))
    )
    itemView.setTextViewText(
        R.id.item_selling,
        String.format(Locale.getDefault(), "$%s", formatter.format(crypto.getDouble("sellingUsd")))
    )

    // SIMPLIFIED: Get change directly
    val change = crypto.optDouble("change", 0.0)
    val isIncreasing = change >= 0.0
    val changePercentage = kotlin.math.abs(change)

    val changeColor = if (isIncreasing) "#4CAF50".toColorInt() else "#F44336".toColorInt()
    val changeSymbol = if (isIncreasing) "↑" else "↓"

    itemView.setTextViewText(
        R.id.item_change,
        String.format(Locale.getDefault(), "%s %.2f%%", changeSymbol, changePercentage)
    )
    itemView.setTextColor(R.id.item_change, changeColor)

    return itemView
}

/**
 * Create a "no data" view
 */
@Suppress("DiscouragedApi")
private fun createNoDataView(context: Context, message: String): RemoteViews {
    val layoutId = context.resources.getIdentifier(
        "widget_item_row",
        "layout",
        context.packageName
    )

    val itemView = RemoteViews(context.packageName, layoutId)
    itemView.setTextViewText(R.id.item_code, message)
    itemView.setViewVisibility(R.id.item_icon, android.view.View.GONE)
    itemView.setViewVisibility(R.id.item_buying, android.view.View.GONE)
    itemView.setViewVisibility(R.id.item_selling, android.view.View.GONE)
    itemView.setViewVisibility(R.id.item_change, android.view.View.GONE)
    return itemView
}

/**
 * Setup refresh button with pending intent
 */
internal fun setupRefreshButton(
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
 * Get number formatter based on locale
 */
private fun getNumberFormatter(locale: String): DecimalFormat {
    val symbols = if (locale == "tr") {
        DecimalFormatSymbols(Locale.forLanguageTag("tr-TR"))
    } else {
        DecimalFormatSymbols(Locale.US)
    }

    return DecimalFormat("#,##0.00##", symbols)
}

/**
 * Extract time portion from datetime string
 * Input: "2024-12-04 15:26:02"
 * Output: "15:26"
 */
private fun extractTimeFromDateTime(dateTime: String): String {
    return try {
        // Split by space to get time part
        val parts = dateTime.split(" ")
        if (parts.size >= 2) {
            // Get time part and extract HH:mm
            val timeParts = parts[1].split(":")
            if (timeParts.size >= 2) {
                "${timeParts[0]}:${timeParts[1]}"  // "15:26"
            } else {
                parts[1]  // Return full time if parsing fails
            }
        } else {
            dateTime  // Return as-is if no space found
        }
    } catch (e: Exception) {
        dateTime  // Return original on error
    }
}