package com.yigit.investrackerapp

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

class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val API_URL = "http://45.131.3.173:5000/api/MarketData"
        private const val CONNECT_TIMEOUT = 15000
        private const val READ_TIMEOUT = 15000
        private const val MIN_UPDATE_INTERVAL_MS = 30_000

        // OPTIMIZED: Define widget-specific data requirements
        private val WIDGET_CURRENCIES = listOf("USD", "EUR", "GBP", "CAD", "CHF")
        private val WIDGET_GOLDS = listOf("GRA", "HAS", "CEYREKALTIN") // Gram Gold, Has Gold, Quarter Gold
        private val WIDGET_CRYPTOS = listOf("BTC", "ETH", "USDT") // Bitcoin, Ethereum, Tether
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            if (!shouldUpdate()) {
                android.util.Log.d("WidgetUpdateWorker", "Skipping update - too soon since last update")
                return@withContext Result.success()
            }

            android.util.Log.d("WidgetUpdateWorker", "Fetching market data for widget...")
            val marketData = fetchMarketData()

            if (marketData != null) {
                android.util.Log.d("WidgetUpdateWorker", "Market data fetched successfully")
                saveWidgetData(marketData)
                updateWidget()
                android.util.Log.d("WidgetUpdateWorker", "Widget updated successfully")
                Result.success()
            } else {
                android.util.Log.e("WidgetUpdateWorker", "Failed to fetch market data")
                Result.retry()
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetUpdateWorker", "Error in doWork", e)
            Result.retry()
        }
    }

    private fun shouldUpdate(): Boolean {
        val prefs = HomeWidgetPlugin.getData(applicationContext)
        val lastUpdate = prefs.getString("last_update", "0")?.toLongOrNull() ?: 0
        return System.currentTimeMillis() - lastUpdate >= MIN_UPDATE_INTERVAL_MS
    }

    private suspend fun fetchMarketData(): JSONObject? = withContext(Dispatchers.IO) {
        try {
            val connection = (URL(API_URL).openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = CONNECT_TIMEOUT
                readTimeout = READ_TIMEOUT
                setRequestProperty("Accept", "application/json")
            }

            if (connection.responseCode == HttpURLConnection.HTTP_OK) {
                val response = JSONObject(connection.inputStream.bufferedReader().readText())
                android.util.Log.d("WidgetUpdateWorker", "API response received successfully")
                response
            } else {
                android.util.Log.e("WidgetUpdateWorker", "API returned error: ${connection.responseCode}")
                null
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetUpdateWorker", "Network error", e)
            null
        }
    }

    private fun saveWidgetData(data: JSONObject) {
        val prefs = HomeWidgetPlugin.getData(applicationContext)
        val locale = prefs.getString("widget_locale", "en") ?: "en"

        // OPTIMIZED: Extract and filter only the required instruments
        val widgetData = JSONObject().apply {
            put("currencies", extractFilteredCurrencies(data))
            put("golds", extractFilteredGolds(data))
            put("cryptos", extractFilteredCryptos(data))
            put(
                "updateTime",
                SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
            )
            put("labels", getLabels(locale))
        }

        android.util.Log.d("WidgetUpdateWorker", "Saving widget data: ${widgetData.toString().length} bytes")

        prefs.edit {
            putString("widget_data", widgetData.toString())
                .putString("last_update", System.currentTimeMillis().toString())
        }
    }

    /**
     * OPTIMIZED: Extract only the top 5 currencies needed for the widget
     * Order: USD, EUR, GBP, CAD, CHF
     * FIX: Properly extract changeRate and isIncreasing from API response
     */
    private fun extractFilteredCurrencies(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.getJSONArray("currencies")

        // Create a map for quick lookup
        val currencyMap = mutableMapOf<String, JSONObject>()
        for (i in 0 until items.length()) {
            val currency = items.getJSONObject(i)
            val code = currency.getString("code")
            if (WIDGET_CURRENCIES.contains(code)) {
                currencyMap[code] = currency
            }
        }

        // Add currencies in the specified order
        for (code in WIDGET_CURRENCIES) {
            currencyMap[code]?.let { currency ->
                val changeRate = currency.optDouble("changeRate", 0.0)
                val isIncreasing = currency.optBoolean("isIncreasing", false)

                android.util.Log.d(
                    "WidgetUpdateWorker",
                    "Currency $code: changeRate=$changeRate, isIncreasing=$isIncreasing"
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
            }
        }

        android.util.Log.d("WidgetUpdateWorker", "Filtered currencies: ${list.length()} items")
        return list
    }

    /**
     * OPTIMIZED: Extract only the top 3 gold types needed for the widget
     * Order: Gram Gold (GRA), Has Gold (HAS), Quarter Gold (CEYREKALTIN)
     */
    private fun extractFilteredGolds(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.optJSONArray("golds") ?: JSONArray()

        // Create a map for quick lookup
        val goldMap = mutableMapOf<String, JSONObject>()
        for (i in 0 until items.length()) {
            val gold = items.getJSONObject(i)
            val code = gold.getString("code")
            if (WIDGET_GOLDS.contains(code)) {
                goldMap[code] = gold
            }
        }

        // Add golds in the specified order
        for (code in WIDGET_GOLDS) {
            goldMap[code]?.let { gold ->
                val changeRate = gold.optDouble("changeRate", 0.0)
                val isIncreasing = gold.optBoolean("isIncreasing", false)

                android.util.Log.d(
                    "WidgetUpdateWorker",
                    "Gold $code: changeRate=$changeRate, isIncreasing=$isIncreasing"
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
            }
        }

        android.util.Log.d("WidgetUpdateWorker", "Filtered golds: ${list.length()} items")
        return list
    }

    /**
     * OPTIMIZED: Extract only the top 3 cryptocurrencies needed for the widget
     * Order: BTC, ETH, USDT
     * FIX #1: Properly extract sellingUsd (not sellingUsd)
     * FIX #2: Properly extract changeRate and isIncreasing from API response
     */
    private fun extractFilteredCryptos(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.optJSONArray("cryptos") ?: JSONArray()

        // Create a map for quick lookup
        val cryptoMap = mutableMapOf<String, JSONObject>()
        for (i in 0 until items.length()) {
            val crypto = items.getJSONObject(i)
            val code = crypto.getString("code")
            if (WIDGET_CRYPTOS.contains(code)) {
                cryptoMap[code] = crypto
            }
        }

        // Add cryptos in the specified order
        for (code in WIDGET_CRYPTOS) {
            cryptoMap[code]?.let { crypto ->
                val usdPrice = crypto.getDouble("usdPrice")

                // FIX: Try multiple possible field names for selling price
                val sellingUsd = when {
                    crypto.has("sellingUsd") -> crypto.getDouble("sellingUsd")
                    crypto.has("selling_usd") -> crypto.getDouble("selling_usd")
                    crypto.has("selling") -> crypto.getDouble("selling")
                    else -> {
                        // If no selling price, calculate estimated selling (buying + 0.1% spread)
                        usdPrice * 1.001
                    }
                }

                val changeRate = crypto.optDouble("changeRate", 0.0)
                val isIncreasing = crypto.optBoolean("isIncreasing", false)

                android.util.Log.d(
                    "WidgetUpdateWorker",
                    "Crypto $code: usdPrice=$usdPrice, sellingUsd=$sellingUsd, changeRate=$changeRate, isIncreasing=$isIncreasing"
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
            }
        }

        android.util.Log.d("WidgetUpdateWorker", "Filtered cryptos: ${list.length()} items")
        return list
    }

    /**
     * FIX #3: Return localized labels for ALL widget texts
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
}