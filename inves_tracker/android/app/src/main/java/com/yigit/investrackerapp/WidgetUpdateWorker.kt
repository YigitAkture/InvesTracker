package com.yigit.investrackerapp

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import androidx.core.content.edit

/**
 * REFACTORED Widget Update Worker
 * - Uses exactly 4 items per category
 * - Simplified change calculation (no redundant fields)
 * - Proper gold name localization
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

        // UPDATED: Exactly 4 items per category
        private val WIDGET_CURRENCIES = listOf("USD", "EUR", "GBP", "CHF")

        // Gold API codes mapped to display codes
        private val WIDGET_GOLDS = mapOf(
            "GRA" to "GRA",           // Gram
            "CEYREKALTIN" to "CEYR",  // Quarter
            "YARIMALTIN" to "YARI",   // Half
            "TAMALTIN" to "TAM"       // Full
        )

        private val WIDGET_CRYPTOS = listOf("BTC", "ETH", "USDT", "BNB")
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            val isManualRefresh = tags.contains("widget_manual_refresh")

            android.util.Log.d("WidgetUpdateWorker", "=== WIDGET UPDATE STARTED ===")
            android.util.Log.d(
                "WidgetUpdateWorker",
                "Type: ${if (isManualRefresh) "MANUAL" else "AUTOMATIC"}"
            )

            // Skip rate limiting for manual refreshes
            if (!isManualRefresh && !shouldUpdate()) {
                android.util.Log.d("WidgetUpdateWorker", "Skipping - too soon since last update")
                return@withContext Result.success()
            }

            android.util.Log.d("WidgetUpdateWorker", "Fetching market data...")

            val marketData = fetchMarketData()

            if (marketData != null) {
                android.util.Log.d("WidgetUpdateWorker", "✓ Market data fetched")
                saveWidgetData(marketData)
                android.util.Log.d("WidgetUpdateWorker", "✓ Widget data saved")
                updateWidget()
                android.util.Log.d("WidgetUpdateWorker", "✓ Widget updated")
                android.util.Log.d("WidgetUpdateWorker", "=== WIDGET UPDATE COMPLETED ===")
                Result.success()
            } else {
                android.util.Log.e("WidgetUpdateWorker", "✗ Failed to fetch data")
                if (isManualRefresh) {
                    updateWidgetWithError()
                    Result.failure()
                } else {
                    Result.retry()
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetUpdateWorker", "✗ Error in doWork", e)
            if (tags.contains("widget_manual_refresh")) {
                updateWidgetWithError()
                Result.failure()
            } else {
                Result.retry()
            }
        }
    }

    private fun shouldUpdate(): Boolean {
        val prefs = HomeWidgetPlugin.getData(applicationContext)
        val lastUpdate = prefs.getString("last_update", "0")?.toLongOrNull() ?: 0
        return System.currentTimeMillis() - lastUpdate >= MIN_UPDATE_INTERVAL_MS
    }

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
                android.util.Log.d("WidgetUpdateWorker", "API response received")
                response
            } else {
                android.util.Log.e("WidgetUpdateWorker", "API error: $responseCode")
                null
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetUpdateWorker", "Network error", e)
            null
        } finally {
            connection?.disconnect()
        }
    }

    /**
     * Save widget data with exactly 4 items per category
     * SIMPLIFIED: Uses 'change' field directly from API
     */
    private fun saveWidgetData(data: JSONObject) {
        val prefs = HomeWidgetPlugin.getData(applicationContext)
        val locale = prefs.getString("widget_locale", "en") ?: "en"

        val apiUpdateTime = data.optString("updateTime", "")
        android.util.Log.d("WidgetUpdateWorker", "API updateTime: $apiUpdateTime")

        val widgetData = JSONObject().apply {
            put("currencies", extractCurrencies(data))
            put("golds", extractGolds(data, locale))
            put("cryptos", extractCryptos(data))
            put("updateTime", apiUpdateTime)
            put("labels", getLabels(locale))
        }

        android.util.Log.d(
            "WidgetUpdateWorker",
            "Saving: 4 currencies, 4 golds, 4 cryptos"
        )

        prefs.edit {
            putString("widget_data", widgetData.toString())
            putString("last_update", System.currentTimeMillis().toString())
        }
    }

    /**
     * Extract exactly 4 currencies: USD, EUR, GBP, CHF
     * SIMPLIFIED: Uses 'change' field directly (positive/negative from API)
     */
    private fun extractCurrencies(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.getJSONArray("currencies")

        android.util.Log.d("WidgetUpdateWorker", "Processing currencies...")

        val currencyMap = mutableMapOf<String, JSONObject>()
        for (i in 0 until items.length()) {
            val currency = items.getJSONObject(i)
            val code = currency.getString("code")
            if (WIDGET_CURRENCIES.contains(code)) {
                currencyMap[code] = currency
            }
        }

        // Add in specified order
        for (code in WIDGET_CURRENCIES) {
            currencyMap[code]?.let { currency ->
                // SIMPLIFIED: Use 'change' directly from API
                val change = currency.optDouble("change", 0.0)

                android.util.Log.d(
                    "WidgetUpdateWorker",
                    "Currency $code: change=$change"
                )

                list.put(
                    JSONObject().apply {
                        put("code", code)
                        put("buying", currency.getDouble("buying"))
                        put("selling", currency.getDouble("selling"))
                        put("change", change) // Store raw change
                    }
                )
            } ?: android.util.Log.w("WidgetUpdateWorker", "Currency $code not found")
        }

        android.util.Log.d("WidgetUpdateWorker", "Extracted ${list.length()} currencies")
        return list
    }

    /**
     * Extract exactly 4 golds: Gram, Quarter, Half, Full
     * INCLUDES: Localized gold names based on locale
     */
    private fun extractGolds(data: JSONObject, locale: String): JSONArray {
        val list = JSONArray()
        val items = data.optJSONArray("golds") ?: JSONArray()

        android.util.Log.d("WidgetUpdateWorker", "Processing golds...")

        val goldMap = mutableMapOf<String, JSONObject>()
        for (i in 0 until items.length()) {
            val gold = items.getJSONObject(i)
            val code = gold.getString("code")
            if (WIDGET_GOLDS.containsKey(code)) {
                goldMap[code] = gold
            }
        }

        // Add in specified order with localized names
        for ((apiCode, displayCode) in WIDGET_GOLDS) {
            goldMap[apiCode]?.let { gold ->
                val change = gold.optDouble("change", 0.0)
                val localizedName = getGoldLocalizedName(apiCode, locale)

                android.util.Log.d(
                    "WidgetUpdateWorker",
                    "Gold $displayCode ($localizedName): change=$change"
                )

                list.put(
                    JSONObject().apply {
                        put("code", displayCode) // Use display code (GRA, CEYR, YARI, TAM)
                        put("name", localizedName) // Localized name
                        put("buying", gold.getDouble("buying"))
                        put("selling", gold.getDouble("selling"))
                        put("change", change)
                    }
                )
            } ?: android.util.Log.w("WidgetUpdateWorker", "Gold $apiCode not found")
        }

        android.util.Log.d("WidgetUpdateWorker", "Extracted ${list.length()} golds")
        return list
    }

    /**
     * Extract exactly 4 cryptos: BTC, ETH, USDT, BNB
     */
    private fun extractCryptos(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.optJSONArray("cryptos") ?: JSONArray()

        android.util.Log.d("WidgetUpdateWorker", "Processing cryptos...")

        val cryptoMap = mutableMapOf<String, JSONObject>()
        for (i in 0 until items.length()) {
            val crypto = items.getJSONObject(i)
            val code = crypto.getString("code")
            if (WIDGET_CRYPTOS.contains(code)) {
                cryptoMap[code] = crypto
            }
        }

        for (code in WIDGET_CRYPTOS) {
            cryptoMap[code]?.let { crypto ->
                val usdPrice = crypto.getDouble("usdPrice")
                val sellingUsd = crypto.optDouble("selling", usdPrice)
                val change = crypto.optDouble("change", 0.0)

                android.util.Log.d(
                    "WidgetUpdateWorker",
                    "Crypto $code: usd=$usdPrice, change=$change"
                )

                list.put(
                    JSONObject().apply {
                        put("code", code)
                        put("usdPrice", usdPrice)
                        put("sellingUsd", sellingUsd)
                        put("change", change)
                    }
                )
            } ?: android.util.Log.w("WidgetUpdateWorker", "Crypto $code not found")
        }

        android.util.Log.d("WidgetUpdateWorker", "Extracted ${list.length()} cryptos")
        return list
    }

    /**
     * Get localized gold name
     */
    private fun getGoldLocalizedName(apiCode: String, locale: String): String {
        return if (locale == "tr") {
            when (apiCode) {
                "GRA" -> "Gram Altın"
                "CEYREKALTIN" -> "Çeyrek Altın"
                "YARIMALTIN" -> "Yarım Altın"
                "TAMALTIN" -> "Tam Altın"
                else -> apiCode
            }
        } else {
            when (apiCode) {
                "GRA" -> "Gram Gold"
                "CEYREKALTIN" -> "Quarter Gold"
                "YARIMALTIN" -> "Half Gold"
                "TAMALTIN" -> "Full Gold"
                else -> apiCode
            }
        }
    }

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

    private fun updateWidget() {
        val manager = AppWidgetManager.getInstance(applicationContext)
        val ids = manager.getAppWidgetIds(
            ComponentName(applicationContext, HomeWidget::class.java)
        )

        android.util.Log.d("WidgetUpdateWorker", "Updating ${ids.size} widget instances")

        for (id in ids) {
            updateAppWidget(applicationContext, manager, id)
        }
    }

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
                manager.partiallyUpdateAppWidget(id, views)
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetUpdateWorker", "Failed to show error state", e)
        }
    }
}