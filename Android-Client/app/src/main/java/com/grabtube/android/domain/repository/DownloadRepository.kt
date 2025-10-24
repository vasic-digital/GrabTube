package com.grabtube.android.domain.repository

import com.grabtube.android.domain.model.Download
import com.grabtube.android.domain.model.DownloadHistory
import com.grabtube.android.domain.model.DownloadRequest
import kotlinx.coroutines.flow.Flow

/**
 * Repository interface for download operations
 */
interface DownloadRepository {
    /**
     * Observe all active downloads
     */
    fun observeDownloads(): Flow<List<Download>>

    /**
     * Observe a specific download by ID
     */
    fun observeDownload(id: String): Flow<Download?>

    /**
     * Get download history
     */
    fun getHistory(limit: Int = 100, offset: Int = 0): Flow<List<DownloadHistory>>

    /**
     * Add a new download
     */
    suspend fun addDownload(request: DownloadRequest): Result<Download>

    /**
     * Start a pending download
     */
    suspend fun startDownload(id: String): Result<Unit>

    /**
     * Cancel an active download
     */
    suspend fun cancelDownload(id: String): Result<Unit>

    /**
     * Pause an active download
     */
    suspend fun pauseDownload(id: String): Result<Unit>

    /**
     * Resume a paused download
     */
    suspend fun resumeDownload(id: String): Result<Unit>

    /**
     * Delete a download from queue
     */
    suspend fun deleteDownload(id: String): Result<Unit>

    /**
     * Clear completed downloads
     */
    suspend fun clearCompleted(): Result<Unit>

    /**
     * Clear all downloads
     */
    suspend fun clearAll(): Result<Unit>

    /**
     * Retry a failed download
     */
    suspend fun retryDownload(id: String): Result<Unit>

    /**
     * Sync downloads with server
     */
    suspend fun syncWithServer(): Result<Unit>

    /**
     * Toggle favorite status of a download
     */
    suspend fun toggleFavorite(id: String): Result<Unit>

    /**
     * Observe favorite downloads
     */
    fun observeFavorites(): Flow<List<Download>>

    /**
     * Search downloads with filters
     */
    suspend fun searchDownloads(
        query: String? = null,
        favoritesOnly: Boolean = false,
        status: String? = null,
        sortBy: String = "date",
        limit: Int = 20,
        offset: Int = 0
    ): Result<Pair<List<Download>, Int>>
}
