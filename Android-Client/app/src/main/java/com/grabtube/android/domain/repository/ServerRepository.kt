package com.grabtube.android.domain.repository

import com.grabtube.android.domain.model.ServerConfig
import kotlinx.coroutines.flow.Flow

/**
 * Repository interface for server configuration and connection
 */
interface ServerRepository {
    /**
     * Observe server configuration and connection status
     */
    fun observeServerConfig(): Flow<ServerConfig>

    /**
     * Get current server URL
     */
    suspend fun getServerUrl(): String

    /**
     * Update server URL
     */
    suspend fun updateServerUrl(url: String): Result<Unit>

    /**
     * Connect to server
     */
    suspend fun connect(): Result<Unit>

    /**
     * Disconnect from server
     */
    suspend fun disconnect()

    /**
     * Test connection to a server URL
     */
    suspend fun testConnection(url: String): Result<Boolean>

    /**
     * Check if connected to server
     */
    fun isConnected(): Flow<Boolean>
}
