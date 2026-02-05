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

class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val API_URL = "http://45.131.3.173:5000/api/MarketData"
        private const val CONNECT_TIMEOUT = 15000
        private const val READ_TIMEOUT = 15000
        private const val MIN_UPDATE_INTERVAL_MS = 30_000
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            if (!shouldUpdate()) {
                return@withContext Result.success()
            }

            val marketData = fetchMarketData()

            if (marketData != null) {
                saveWidgetData(marketData)
                updateWidget()
                Result.success()
            } else {
                Result.retry()
            }
        } catch (e: Exception) {
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
                JSONObject(connection.inputStream.bufferedReader().readText())
            } else null
        } catch (_: Exception) {
            null
        }
    }

       private fun saveWidgetData(data: JSONObject) {
        val prefs = HomeWidgetPlugin.getData(applicationContext)
        val locale = prefs.getString("widget_locale", "en") ?: "en"

        val widgetData = JSONObject().apply {
            put("currencies", extractCurrencies(data))
            put("golds", extractGolds(data))
            put("cryptos", extractCryptos(data))
            put(
                "updateTime",
                SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
            )
            put("labels", getLabels(locale))
        }

        prefs.edit()
            .putString("widget_data", widgetData.toString())
            .putString("last_update", System.currentTimeMillis().toString())
            .apply()
    }

    private fun extractCurrencies(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.getJSONArray("currencies")
        for (i in 0 until minOf(5, items.length())) {
            val c = items.getJSONObject(i)
            list.put(
                JSONObject().apply {
                    put("code", c.getString("code"))
                    put("buying", c.getDouble("buying"))
                    put("selling", c.getDouble("selling"))
                    put("changeRate", c.optDouble("changeRate", 0.0))
                    put("isIncreasing", c.optBoolean("isIncreasing", false))
                }
            )
        }
        return list
    }

    private fun extractGolds(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.optJSONArray("golds") ?: JSONArray()
        for (i in 0 until minOf(3, items.length())) {
            val g = items.getJSONObject(i)
            list.put(
                JSONObject().apply {
                    put("code", g.getString("code"))
                    put("buying", g.getDouble("buying"))
                    put("selling", g.getDouble("selling"))
                    put("changeRate", g.optDouble("changeRate", 0.0))
                    put("isIncreasing", g.optBoolean("isIncreasing", false))
                }
            )
        }
        return list
    }

    private fun extractCryptos(data: JSONObject): JSONArray {
        val list = JSONArray()
        val items = data.optJSONArray("cryptos") ?: JSONArray()
        for (i in 0 until minOf(3, items.length())) {
            val c = items.getJSONObject(i)
            list.put(
                JSONObject().apply {
                    put("code", c.getString("code"))
                    put("usdPrice", c.getDouble("usdPrice"))
                    put("sellingUsd", c.optDouble("sellingUsd", 0.0))
                    put("changeRate", c.optDouble("changeRate", 0.0))
                    put("isIncreasing", c.optBoolean("isIncreasing", false))
                }
            )
        }
        return list
    }

    private fun getLabels(locale: String): JSONObject =
        if (locale == "tr") {
            JSONObject().apply {
                put("currency", "Döviz")
                put("gold", "Altın")
                put("crypto", "Kripto")
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
                put("buying", "Buying")
                put("selling", "Selling")
                put("change", "Change")
                put("updated", "Updated")
            }
        }

    private fun updateWidget() {
        val manager = AppWidgetManager.getInstance(applicationContext)
        val ids = manager.getAppWidgetIds(
            ComponentName(applicationContext, HomeWidget::class.java)
        )

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
