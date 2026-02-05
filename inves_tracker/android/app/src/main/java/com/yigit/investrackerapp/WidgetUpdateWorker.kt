package com.yigit.investrackerapp

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*
import androidx.core.content.edit

/**
 * Background worker for updating widget data
 * FIX: Supports manual refresh (bypasses rate limiting) and automatic periodic updates
 */
class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val API_URL = "http://45.131.3.173:5000/api/MarketData"
        private const val CONNECT_TIMEOUT = 15000
        private const val READ_TIMEOUT = 15000
        private const val MIN_UPDATE_INTERVAL_MS = 30_000 // 30 seconds

        // OPTIMIZED: Define widget-specific data requirements
        private val WIDGET_CURRENCIES = listOf("USD", "EUR", "GBP", "CAD", "CHF")
        private val WIDGET_GOLDS = listOf("GRA", "HAS", "CEYREKALTIN")
        private val WIDGET_CRYPTOS = listOf("BTC", "ETH", "USDT")
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            // FIX: Check if this is a manual refresh (triggered by refresh button)
            val isManualRefresh = tags.contains("widget_manual_refresh")

            android.util.Log.d(
                "WidgetUpdateWorker",
                "========== WIDGET UPDATE STARTED =========="
            )
            android.util.Log.d(
                "WidgetUpdateWorker",
                "Update type: ${if (isManualRefresh) "MANUAL (user tapped refresh)" else "AUTOMATIC (periodic)"}"
            )

            // Skip rate limiting for manual refreshes
            if (!isManualRefresh && !shouldUpdate()) {
                android.util.Log.d("WidgetUpdateWorker", "Skipping update - too soon since last update")
                android.util.Log.d("WidgetUpdateWorker", "========== WIDGET UPDATE SKIPPED ==========")
                return@withContext Result.success()
            }

            android.util.Log.d("WidgetUpdateWorker", "Fetching market data from API...")

            val marketData = fetchMarketData()

            if (marketData != null) {
                android.util.Log.d("WidgetUpdateWorker", "✓ Market data fetched successfully")
                saveWidgetData(marketData)
                android.util.Log.d("WidgetUpdateWorker", "✓ Widget data saved to SharedPreferences")
                updateWidget()
                android.util.Log.d("WidgetUpdateWorker", "✓ Widget UI updated")
                android.util.Log.d("WidgetUpdateWorker", "========== WIDGET UPDATE COMPLETED ==========")
                Result.success()
            } else {
                android.util.Log.e("WidgetUpdateWorker", "✗ Failed to fetch market data from API")
                // For manual refresh, don't retry to avoid user confusion
                if (isManualRefresh) {
                    updateWidgetWithError()
                    android.util.Log.d("WidgetUpdateWorker", "========== WIDGET UPDATE FAILED ==========")
                    Result.failure()
                } else {
                    android.util.Log.d("WidgetUpdateWorker", "========== WIDGET UPDATE FAILED (will retry) ==========")
                    Result.retry()
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetUpdateWorker", "✗ Error in doWork", e)

            // Show error state for manual refresh
            if (tags.contains("widget_manual_refresh")) {
                updateWidgetWithError()
                android.util.Log.d("WidgetUpdateWorker", "========== WIDGET UPDATE ERROR ==========")
                Result.failure()
            } else {
                android.util.Log.d("WidgetUpdateWorker", "========== WIDGET UPDATE ERROR (will retry) ==========")
                Result.retry()
            }
        }
    }

    /**
     * Check if enough time has passed since last update
     * Used only for automatic periodic updates, not manual refreshes
     */
    private fun shouldUpdate(): Boolean {
        val prefs = HomeWidgetPlugin.getData(applicationContext)
        val lastUpdate = prefs.getString("last_update", "0")?.toLongOrNull() ?: 0
        return System.currentTimeMillis() - lastUpdate >= MIN_UPDATE_INTERVAL_MS
    }

    /**
     * Fetch market data from API
     */
    private suspend fun fetchMarketData(): JSONObject? = withContext(Dispatchers.IO) {
        var connection: HttpURLConnection? = null
        try {
            connection = (URL(API_URL).openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = CONNECT_TIMEOUT
                readTimeout = READ_TIMEOUT
                setRequestProperty("Accept", "application/json")
                setRequestProperty("User-Agent", "InvesTracker-Widget/1.0")
            }

            val responseCode = connection.responseCode
            android.util.Log.d("WidgetUpdateWorker", "API response code: $responseCode")

            if (responseCode == HttpURLConnection.HTTP_OK) {
                val responseText = connection.inputStream.bufferedReader().readText()
                val response = JSONObject(responseText)

                // DEBUG: Log first currency item to see its structure
                if (response.has("currencies")) {
                    val currencies = response.getJSONArray("currencies")
                    if (currencies.length() > 0) {
                        val firstCurrency = currencies.getJSONObject(0)
                        android.util.Log.d("WidgetUpdateWorker", "=== FIRST CURRENCY ITEM STRUCTURE ===")
                        android.util.Log.d("WidgetUpdateWorker", "Full JSON: ${firstCurrency.toString()}")
                        android.util.Log.d("WidgetUpdateWorker", "Available keys: ${firstCurrency.keys().asSequence().toList()}")

                        // Log each field's value
                        val keys = firstCurrency.keys()
                        while (keys.hasNext()) {
                            val key = keys.next()
                            val value = firstCurrency.get(key)
                            android.util.Log.d("WidgetUpdateWorker", "  $key: $value (type: ${value.javaClass.simpleName})")
                        }
                        android.util.Log.d("WidgetUpdateWorker", "=====================================")
                    }
                }

                android.util.Log.d("WidgetUpdateWorker", "API response received successfully")
                response
            } else {
                android.util.Log.e("WidgetUpdateWorker", "API returned error: $responseCode")
                null
            }
        } catch (e: java.net.SocketTimeoutException) {
            android.util.Log.e("WidgetUpdateWorker", "Connection timeout", e)
            null
        } catch (e: java.net.UnknownHostException) {
            android.util.Log.e("WidgetUpdateWorker", "Unknown host - check network connection", e)
            null
        } catch (e: Exception) {
            android.util.Log.e("WidgetUpdateWorker", "Network error", e)
            null
        } finally {
            connection?.disconnect()
        }
    }

    /**
     * Save fetched data to shared preferences
     * FIX: Use updateTime from API response
     */
    private fun saveWidgetData(data: JSONObject) {
        val prefs = HomeWidgetPlugin.getData(applicationContext)
        val locale = prefs.getString("widget_locale", "en") ?: "en"

        // FIX: Get updateTime from API response
        val apiUpdateTime = data.optString("updateTime", "")

        android.util.Log.d("WidgetUpdateWorker", "API updateTime: $apiUpdateTime")

        // OPTIMIZED: Extract and filter only the required instruments
        val widgetData = JSONObject().apply {
            put("currencies", extractFilteredCurrencies(data))
            put("golds", extractFilteredGolds(data))
            put("cryptos", extractFilteredCryptos(data))
            put("updateTime", apiUpdateTime)  // Use API's updateTime
            put("labels", getLabels(locale))
        }

        android.util.Log.d("WidgetUpdateWorker", "Saving widget data: ${widgetData.toString().length} bytes")

        prefs.edit {
            putString("widget_data", widgetData.toString())
            putString("last_update", System.currentTimeMillis().toString())
        }
    }

    /**
     * OPTIMIZED: Extract only the top 5 currencies needed for the widget
     * FIX: API uses "change" field, properly handle negative values
     * FIX: Zero change should show as green (increasing)
     */
    private fun extractFilteredCurrencies(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.getJSONArray("currencies")

        android.util.Log.d("WidgetUpdateWorker", "Processing ${items.length()} total currencies from API")

        // Create a map for quick lookup
        val currencyMap = mutableMapOf<String, JSONObject>()
        for (i in 0 until items.length()) {
            val currency = items.getJSONObject(i)
            val code = currency.getString("code")
            if (WIDGET_CURRENCIES.contains(code)) {
                currencyMap[code] = currency
                android.util.Log.d("WidgetUpdateWorker", "Found widget currency: $code")
            }
        }

        // Add currencies in the specified order
        for (code in WIDGET_CURRENCIES) {
            currencyMap[code]?.let { currency ->
                // FIX: API returns "change" field - this can be positive or negative
                val change = currency.optDouble("change", 0.0)
                // FIX: Zero or positive = green, only negative = red
                val isIncreasing = change >= 0.0
                // Use absolute value for display percentage
                val changeRate = kotlin.math.abs(change)

                android.util.Log.d(
                    "WidgetUpdateWorker",
                    "Currency $code: raw change=$change, abs changeRate=$changeRate, isIncreasing=$isIncreasing"
                )

                list.put(
                    JSONObject().apply {
                        put("code", currency.getString("code"))
                        put("buying", currency.getDouble("buying"))
                        put("selling", currency.getDouble("selling"))
                        put("changeRate", changeRate)
                        put("isIncreasing", isIncreasing)
                    }
                )
            } ?: android.util.Log.w("WidgetUpdateWorker", "Currency $code not found in API response")
        }

        android.util.Log.d("WidgetUpdateWorker", "Filtered currencies: ${list.length()} items")
        return list
    }

    /**
     * OPTIMIZED: Extract only the top 3 gold types needed for the widget
     * FIX: API uses "change" field, properly handle negative values
     * FIX: Zero change should show as green (increasing)
     */
    private fun extractFilteredGolds(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.optJSONArray("golds") ?: JSONArray()

        android.util.Log.d("WidgetUpdateWorker", "Processing ${items.length()} total golds from API")

        // Create a map for quick lookup
        val goldMap = mutableMapOf<String, JSONObject>()
        for (i in 0 until items.length()) {
            val gold = items.getJSONObject(i)
            val code = gold.getString("code")
            if (WIDGET_GOLDS.contains(code)) {
                goldMap[code] = gold
                android.util.Log.d("WidgetUpdateWorker", "Found widget gold: $code")
            }
        }

        // Add golds in the specified order
        for (code in WIDGET_GOLDS) {
            goldMap[code]?.let { gold ->
                // FIX: API returns "change" field - this can be positive or negative
                val change = gold.optDouble("change", 0.0)
                // FIX: Zero or positive = green, only negative = red
                val isIncreasing = change >= 0.0
                // Use absolute value for display percentage
                val changeRate = kotlin.math.abs(change)

                android.util.Log.d(
                    "WidgetUpdateWorker",
                    "Gold $code: raw change=$change, abs changeRate=$changeRate, isIncreasing=$isIncreasing"
                )

                list.put(
                    JSONObject().apply {
                        put("code", gold.getString("code"))
                        put("buying", gold.getDouble("buying"))
                        put("selling", gold.getDouble("selling"))
                        put("changeRate", changeRate)
                        put("isIncreasing", isIncreasing)
                    }
                )
            } ?: android.util.Log.w("WidgetUpdateWorker", "Gold $code not found in API response")
        }

        android.util.Log.d("WidgetUpdateWorker", "Filtered golds: ${list.length()} items")
        return list
    }

    /**
     * OPTIMIZED: Extract only the top 3 cryptocurrencies needed for the widget
     * FIX: API uses "change" field, properly handle negative values
     * FIX: Zero change should show as green (increasing)
     */
    private fun extractFilteredCryptos(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.optJSONArray("cryptos") ?: JSONArray()

        android.util.Log.d("WidgetUpdateWorker", "Processing ${items.length()} total cryptos from API")

        // Create a map for quick lookup
        val cryptoMap = mutableMapOf<String, JSONObject>()
        for (i in 0 until items.length()) {
            val crypto = items.getJSONObject(i)
            val code = crypto.getString("code")
            if (WIDGET_CRYPTOS.contains(code)) {
                cryptoMap[code] = crypto
                android.util.Log.d("WidgetUpdateWorker", "Found widget crypto: $code")
            }
        }

        // Add cryptos in the specified order
        for (code in WIDGET_CRYPTOS) {
            cryptoMap[code]?.let { crypto ->
                val usdPrice = crypto.getDouble("usdPrice")

                // For cryptos, use "selling" field directly (API provides it)
                val sellingUsd = crypto.optDouble("selling", usdPrice * 1.001)

                // FIX: API returns "change" field - this can be positive or negative
                val change = crypto.optDouble("change", 0.0)
                // FIX: Zero or positive = green, only negative = red
                val isIncreasing = change >= 0.0
                // Use absolute value for display percentage
                val changeRate = kotlin.math.abs(change)

                android.util.Log.d(
                    "WidgetUpdateWorker",
                    "Crypto $code: usdPrice=$usdPrice, sellingUsd=$sellingUsd, raw change=$change, abs changeRate=$changeRate, isIncreasing=$isIncreasing"
                )

                list.put(
                    JSONObject().apply {
                        put("code", crypto.getString("code"))
                        put("usdPrice", usdPrice)
                        put("sellingUsd", sellingUsd)
                        put("changeRate", changeRate)
                        put("isIncreasing", isIncreasing)
                    }
                )
            } ?: android.util.Log.w("WidgetUpdateWorker", "Crypto $code not found in API response")
        }

        android.util.Log.d("WidgetUpdateWorker", "Filtered cryptos: ${list.length()} items")
        return list
    }

    /**
     * Get localized labels based on locale
     */
    private fun getLabels(locale: String): JSONObject =
        if (locale == "tr") {
            JSONObject().apply {
                put("currency", "Döviz")
                put("gold", "Altın")
                put("crypto", "Kripto")
                put("code", "Kod")
                put("buying", "Alış")
                put("selling", "Satış")
                put("change", "Değişim")
                put("updated", "Güncellendi")
            }
        } else {
            JSONObject().apply {
                put("currency", "Currency")
                put("gold", "Gold")
                put("crypto", "Crypto")
                put("code", "Code")
                put("buying", "Buy")
                put("selling", "Sell")
                put("change", "Change")
                put("updated", "Updated")
            }
        }

    /**
     * Update all widget instances with new data
     */
    private fun updateWidget() {
        val manager = AppWidgetManager.getInstance(applicationContext)
        val ids = manager.getAppWidgetIds(
            ComponentName(applicationContext, HomeWidget::class.java)
        )

        android.util.Log.d("WidgetUpdateWorker", "Updating ${ids.size} widget instances")

        for (id in ids) {
            updateAppWidget(applicationContext, manager, id)
        }

        val intent = Intent(applicationContext, HomeWidget::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        applicationContext.sendBroadcast(intent)
    }

    /**
     * Update widget with error message when data fetch fails
     */
    private fun updateWidgetWithError() {
        try {
            val prefs = HomeWidgetPlugin.getData(applicationContext)
            val locale = prefs.getString("widget_locale", "en") ?: "en"
            val errorMessage = if (locale == "tr") "Güncelleme başarısız" else "Update failed"

            prefs.edit {
                putString("widget_update_time", errorMessage)
            }

            val manager = AppWidgetManager.getInstance(applicationContext)
            val ids = manager.getAppWidgetIds(
                ComponentName(applicationContext, HomeWidget::class.java)
            )

            for (id in ids) {
                val views = android.widget.RemoteViews(
                    applicationContext.packageName,
                    R.layout.home_widget
                )
                views.setTextViewText(R.id.widget_update_time, errorMessage)

                // Keep refresh button active - inline implementation
                val refreshIntent = Intent(applicationContext, HomeWidget::class.java).apply {
                    action = HomeWidget.ACTION_REFRESH
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    applicationContext,
                    id,
                    refreshIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.refresh_button, pendingIntent)

                manager.partiallyUpdateAppWidget(id, views)
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetUpdateWorker", "Failed to show error state", e)
        }
    }
}