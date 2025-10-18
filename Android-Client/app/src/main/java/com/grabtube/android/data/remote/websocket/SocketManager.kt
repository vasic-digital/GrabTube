package com.grabtube.android.data.remote.websocket

import com.grabtube.android.data.remote.dto.DownloadDto
import io.socket.client.IO
import io.socket.client.Socket
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.serialization.json.Json
import org.json.JSONObject
import timber.log.Timber
import java.net.URI
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Manages Socket.IO connection for real-time download updates
 */
@Singleton
class SocketManager @Inject constructor(
    private val json: Json
) {
    private var socket: Socket? = null

    private val _connectionState = MutableStateFlow<ConnectionState>(ConnectionState.Disconnected)
    val connectionState: StateFlow<ConnectionState> = _connectionState.asStateFlow()

    sealed class ConnectionState {
        object Connected : ConnectionState()
        object Connecting : ConnectionState()
        object Disconnected : ConnectionState()
        data class Error(val message: String) : ConnectionState()
    }

    sealed class DownloadEvent {
        data class Added(val download: DownloadDto) : DownloadEvent()
        data class Updated(val download: DownloadDto) : DownloadEvent()
        data class Completed(val downloadId: String) : DownloadEvent()
        data class Canceled(val downloadId: String) : DownloadEvent()
        object Cleared : DownloadEvent()
    }

    fun connect(serverUrl: String) {
        try {
            _connectionState.value = ConnectionState.Connecting

            val uri = URI.create(serverUrl)
            val options = IO.Options().apply {
                transports = arrayOf("websocket")
                reconnection = true
                reconnectionDelay = 1000
                reconnectionAttempts = Int.MAX_VALUE
            }

            socket = IO.socket(uri, options).apply {
                on(Socket.EVENT_CONNECT) {
                    Timber.d("Socket connected")
                    _connectionState.value = ConnectionState.Connected
                }

                on(Socket.EVENT_DISCONNECT) {
                    Timber.d("Socket disconnected")
                    _connectionState.value = ConnectionState.Disconnected
                }

                on(Socket.EVENT_CONNECT_ERROR) { args ->
                    Timber.e("Socket connection error: ${args.getOrNull(0)}")
                    _connectionState.value = ConnectionState.Error(
                        args.getOrNull(0)?.toString() ?: "Connection error"
                    )
                }

                connect()
            }
        } catch (e: Exception) {
            Timber.e(e, "Failed to connect socket")
            _connectionState.value = ConnectionState.Error(e.message ?: "Unknown error")
        }
    }

    fun disconnect() {
        socket?.disconnect()
        socket?.close()
        socket = null
        _connectionState.value = ConnectionState.Disconnected
    }

    fun observeDownloadEvents(): Flow<DownloadEvent> = callbackFlow {
        val addedListener = { args: Array<Any> ->
            try {
                val data = args.getOrNull(0) as? JSONObject
                data?.let {
                    val downloadDto = parseDownloadDto(it)
                    trySend(DownloadEvent.Added(downloadDto))
                }
            } catch (e: Exception) {
                Timber.e(e, "Error parsing added event")
            }
        }

        val updatedListener = { args: Array<Any> ->
            try {
                val data = args.getOrNull(0) as? JSONObject
                data?.let {
                    val downloadDto = parseDownloadDto(it)
                    trySend(DownloadEvent.Updated(downloadDto))
                }
            } catch (e: Exception) {
                Timber.e(e, "Error parsing updated event")
            }
        }

        val completedListener = { args: Array<Any> ->
            try {
                val data = args.getOrNull(0) as? JSONObject
                val downloadId = data?.getString("id")
                downloadId?.let { trySend(DownloadEvent.Completed(it)) }
            } catch (e: Exception) {
                Timber.e(e, "Error parsing completed event")
            }
        }

        val canceledListener = { args: Array<Any> ->
            try {
                val data = args.getOrNull(0) as? JSONObject
                val downloadId = data?.getString("id")
                downloadId?.let { trySend(DownloadEvent.Canceled(it)) }
            } catch (e: Exception) {
                Timber.e(e, "Error parsing canceled event")
            }
        }

        val clearedListener = { _: Array<Any> ->
            trySend(DownloadEvent.Cleared)
        }

        socket?.on("added", addedListener)
        socket?.on("updated", updatedListener)
        socket?.on("completed", completedListener)
        socket?.on("canceled", canceledListener)
        socket?.on("cleared", clearedListener)

        awaitClose {
            socket?.off("added", addedListener)
            socket?.off("updated", updatedListener)
            socket?.off("completed", completedListener)
            socket?.off("canceled", canceledListener)
            socket?.off("cleared", clearedListener)
        }
    }

    private fun parseDownloadDto(jsonObject: JSONObject): DownloadDto {
        return json.decodeFromString<DownloadDto>(jsonObject.toString())
    }

    fun isConnected(): Boolean = _connectionState.value == ConnectionState.Connected
}
