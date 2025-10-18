package com.grabtube.android.data.repository

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import com.grabtube.android.BuildConfig
import com.grabtube.android.data.remote.websocket.SocketManager
import com.grabtube.android.domain.model.ServerConfig
import com.grabtube.android.domain.repository.ServerRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import okhttp3.OkHttpClient
import okhttp3.Request
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ServerRepositoryImpl @Inject constructor(
    private val dataStore: DataStore<Preferences>,
    private val socketManager: SocketManager,
    private val okHttpClient: OkHttpClient
) : ServerRepository {

    companion object {
        private val SERVER_URL_KEY = stringPreferencesKey("server_url")
    }

    override fun observeServerConfig(): Flow<ServerConfig> {
        return dataStore.data.map { preferences ->
            val url = preferences[SERVER_URL_KEY] ?: BuildConfig.DEFAULT_SERVER_URL
            val isConnected = socketManager.connectionState.value == SocketManager.ConnectionState.Connected

            ServerConfig(
                url = url,
                isConnected = isConnected
            )
        }
    }

    override suspend fun getServerUrl(): String {
        return dataStore.data.map { preferences ->
            preferences[SERVER_URL_KEY] ?: BuildConfig.DEFAULT_SERVER_URL
        }.first()
    }

    override suspend fun updateServerUrl(url: String): Result<Unit> {
        return try {
            dataStore.edit { preferences ->
                preferences[SERVER_URL_KEY] = url
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Timber.e(e, "Failed to update server URL")
            Result.failure(e)
        }
    }

    override suspend fun connect(): Result<Unit> {
        return try {
            val url = getServerUrl()
            socketManager.connect(url)
            Result.success(Unit)
        } catch (e: Exception) {
            Timber.e(e, "Failed to connect to server")
            Result.failure(e)
        }
    }

    override suspend fun disconnect() {
        socketManager.disconnect()
    }

    override suspend fun testConnection(url: String): Result<Boolean> {
        return try {
            val request = Request.Builder()
                .url("$url/")
                .head()
                .build()

            val response = okHttpClient.newCall(request).execute()
            Result.success(response.isSuccessful)
        } catch (e: Exception) {
            Timber.e(e, "Connection test failed")
            Result.failure(e)
        }
    }

    override fun isConnected(): Flow<Boolean> {
        return socketManager.connectionState.map { state ->
            state == SocketManager.ConnectionState.Connected
        }
    }
}
