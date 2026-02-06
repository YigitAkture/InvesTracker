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
import kotlin.math.max
import androidx.core.graphics.toColorInt

/**
 * Home Screen Widget for InvesTracker
 * Displays live market data (currencies, gold, crypto) with adaptive height support
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
        internal const val MIN_ITEMS_PER_SECTION = 1
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
        android.util.Log.d("HomeWidget", "Expected action: $ACTION_REFRESH")
        android.util.Log.d("HomeWidget", "Actions match: ${intent.action == ACTION_REFRESH}")

        if (intent.action == ACTION_REFRESH) {
            try {
                android.util.Log.d("HomeWidget", "✓ Refresh action matched!")
                android.util.Log.d("HomeWidget", "Triggering background update via WorkManager...")

                // Create work request
                val workRequest = androidx.work.OneTimeWorkRequestBuilder<WidgetUpdateWorker>()
                    .addTag("widget_manual_refresh")
                    .setInitialDelay(0, java.util.concurrent.TimeUnit.SECONDS)
                    .build()

                android.util.Log.d("HomeWidget", "✓ Work request created")

                // Enqueue work
                androidx.work.WorkManager.getInstance(context)
                    .enqueue(workRequest)

                android.util.Log.d("HomeWidget", "✓ Work enqueued to WorkManager")

                // Show loading state
                showLoadingState(context)
                android.util.Log.d("HomeWidget", "✓ Loading state displayed")

            } catch (e: Exception) {
                android.util.Log.e("HomeWidget", "✗ ERROR in refresh handler", e)
                e.printStackTrace()
            }
        } else {
            android.util.Log.d("HomeWidget", "✗ Action did not match, ignoring")
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
 * Calculate how many items can fit in the widget based on its current height
 */
internal fun calculateItemCapacity(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
): ItemCapacity {
    val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
    val heightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 200)

    // Maximum items available in data
    val maxCurrencies = 5
    val maxGolds = 3
    val maxCryptos = 3

    // Convert dp to pixels for accurate calculation
    val displayMetrics = context.resources.displayMetrics

    // Calculate fixed heights in pixels
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

    // Calculate how many items can fit in remaining space
    val totalPossibleItems = (remainingHeightPx / itemHeightPx).toInt()

    // Distribute items across sections with proper limits
    var goldItems = 0
    var cryptoItems = 0

    // Allocate currencies (priority 1, max 5)
    val currencyItems = minOf(maxCurrencies, max(HomeWidget.MIN_ITEMS_PER_SECTION, totalPossibleItems))

    // Check if we have space for golds section (needs divider + at least 1 item)
    if (remainingHeightPx - (currencyItems * itemHeightPx) >= (dividerHeightPx + itemHeightPx)) {
        // Account for divider space
        remainingHeightPx -= (currencyItems * itemHeightPx + dividerHeightPx)

        // Allocate golds (priority 2, max 3)
        val goldsPossible = (remainingHeightPx / itemHeightPx).toInt()
        goldItems = minOf(maxGolds, goldsPossible)

        // Check if we have space for cryptos section
        if (goldItems > 0) {
            remainingHeightPx -= (goldItems * itemHeightPx)

            if (remainingHeightPx >= (dividerHeightPx + itemHeightPx)) {
                remainingHeightPx -= dividerHeightPx

                // Allocate cryptos (priority 3, max 3)
                val cryptosPossible = (remainingHeightPx / itemHeightPx).toInt()
                cryptoItems = minOf(maxCryptos, cryptosPossible)
            }
        }
    }

    android.util.Log.d(
        "HomeWidget",
        "Widget height: ${heightDp}dp -> Currencies: $currencyItems, Golds: $goldItems, Cryptos: $cryptoItems (Total: ${currencyItems + goldItems + cryptoItems})"
    )

    return ItemCapacity(
        currencies = currencyItems,
        golds = goldItems,
        cryptos = cryptoItems
    )
}

/**
 * Data class to hold calculated item capacities
 */
data class ItemCapacity(
    val currencies: Int,
    val golds: Int,
    val cryptos: Int
)

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
                views.setTextViewText(
                    R.id.widget_update_time,
                    "${labels.getString("updated")}: $updateTime"
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
 * Create a single item view for currency or gold
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

    // Set text values
    itemView.setTextViewText(R.id.item_code, code)
    itemView.setTextViewText(R.id.item_buying, formatter.format(item.getDouble("buying")))
    itemView.setTextViewText(R.id.item_selling, formatter.format(item.getDouble("selling")))

    // Set change indicator
    val isIncreasing = item.getBoolean("isIncreasing")
    val changeRate = item.getDouble("changeRate")

    val changeColor = if (isIncreasing) "#4CAF50".toColorInt() else "#F44336".toColorInt()
    val changeSymbol = if (isIncreasing) "↑" else "↓"

    itemView.setTextViewText(R.id.item_change, String.format(Locale.getDefault(), "%s %.2f%%", changeSymbol, changeRate))
    itemView.setTextColor(R.id.item_change, changeColor)

    return itemView
}

/**
 * Create a crypto item view
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
    itemView.setTextViewText(R.id.item_buying, String.format(Locale.getDefault(), "$%s", formatter.format(crypto.getDouble("usdPrice"))))
    itemView.setTextViewText(R.id.item_selling, String.format(Locale.getDefault(), "$%s", formatter.format(crypto.getDouble("sellingUsd"))))

    // Set change indicator
    val isIncreasing = crypto.getBoolean("isIncreasing")
    val changeRate = crypto.getDouble("changeRate")

    val changeColor = if (isIncreasing) "#4CAF50".toColorInt() else "#F44336".toColorInt()
    val changeSymbol = if (isIncreasing) "↑" else "↓"

    itemView.setTextViewText(R.id.item_change, String.format(Locale.getDefault(), "%s %.2f%%", changeSymbol, changeRate))
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