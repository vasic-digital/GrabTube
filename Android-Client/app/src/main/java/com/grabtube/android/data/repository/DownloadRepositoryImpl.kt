package com.grabtube.android.data.repository

import com.grabtube.android.data.local.dao.DownloadDao
import com.grabtube.android.data.local.entity.toDomain
import com.grabtube.android.data.local.entity.toEntity
import com.grabtube.android.data.remote.api.GrabTubeApi
import com.grabtube.android.data.remote.dto.AddDownloadRequestDto
import com.grabtube.android.data.remote.dto.toDomain
import com.grabtube.android.data.remote.websocket.SocketManager
import com.grabtube.android.domain.model.Download
import com.grabtube.android.domain.model.DownloadHistory
import com.grabtube.android.domain.model.DownloadRequest
import com.grabtube.android.domain.model.DownloadStatus
import com.grabtube.android.domain.repository.DownloadRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class DownloadRepositoryImpl @Inject constructor(
    private val api: GrabTubeApi,
    private val downloadDao: DownloadDao,
    private val socketManager: SocketManager
) : DownloadRepository {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    init {
        // Observe socket events and update local database
        scope.launch {
            socketManager.observeDownloadEvents().collect { event ->
                when (event) {
                    is SocketManager.DownloadEvent.Added -> {
                        val download = event.download.toDomain()
                        downloadDao.insert(download.toEntity())
                    }
                    is SocketManager.DownloadEvent.Updated -> {
                        val download = event.download.toDomain()
                        downloadDao.insert(download.toEntity())
                    }
                    is SocketManager.DownloadEvent.Completed -> {
                        downloadDao.getById(event.downloadId)?.let { entity ->
                            val updated = entity.copy(
                                status = DownloadStatus.COMPLETED.name,
                                completedAt = System.currentTimeMillis() / 1000
                            )
                            downloadDao.update(updated)
                        }
                    }
                    is SocketManager.DownloadEvent.Canceled -> {
                        downloadDao.getById(event.downloadId)?.let { entity ->
                            val updated = entity.copy(status = DownloadStatus.CANCELED.name)
                            downloadDao.update(updated)
                        }
                    }
                    is SocketManager.DownloadEvent.Cleared -> {
                        downloadDao.deleteAll()
                    }
                }
            }
        }
    }

    override fun observeDownloads(): Flow<List<Download>> {
        return downloadDao.observeAll().map { entities ->
            entities.map { it.toDomain() }
        }
    }

    override fun observeDownload(id: String): Flow<Download?> {
        return downloadDao.observeById(id).map { it?.toDomain() }
    }

    override fun getHistory(limit: Int, offset: Int): Flow<List<DownloadHistory>> {
        return downloadDao.getHistory(limit, offset).map { entities ->
            entities.map { entity ->
                val download = entity.toDomain()
                DownloadHistory(
                    id = download.id,
                    url = download.url,
                    title = download.title,
                    thumbnail = download.thumbnail,
                    quality = download.quality,
                    format = download.format,
                    folder = download.folder,
                    status = download.status,
                    completedAt = download.completedAt ?: download.addedAt,
                    duration = download.completedAt?.let { completed ->
                        download.startedAt?.let { started ->
                            completed.epochSecond - started.epochSecond
                        }
                    },
                    fileSize = download.totalBytes
                )
            }
        }
    }

    override suspend fun addDownload(request: DownloadRequest): Result<Download> {
        return try {
            val requestDto = AddDownloadRequestDto(
                url = request.url,
                quality = request.quality,
                format = request.format,
                folder = request.folder,
                autoStart = request.autoStart
            )

            val response = api.addDownload(requestDto)

            if (response.status == "ok" && response.id != null) {
                // Fetch the full download details
                syncWithServer()
                val download = downloadDao.getById(response.id)?.toDomain()
                    ?: return Result.failure(Exception("Download not found after adding"))
                Result.success(download)
            } else {
                Result.failure(Exception(response.error ?: "Failed to add download"))
            }
        } catch (e: Exception) {
            Timber.e(e, "Failed to add download")
            Result.failure(e)
        }
    }

    override suspend fun startDownload(id: String): Result<Unit> {
        return try {
            api.startDownload(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Timber.e(e, "Failed to start download")
            Result.failure(e)
        }
    }

    override suspend fun cancelDownload(id: String): Result<Unit> {
        return try {
            api.cancelDownload(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Timber.e(e, "Failed to cancel download")
            Result.failure(e)
        }
    }

    override suspend fun pauseDownload(id: String): Result<Unit> {
        // Note: Pause functionality may not be supported by the backend
        // This is a placeholder for future implementation
        return Result.failure(UnsupportedOperationException("Pause not yet supported"))
    }

    override suspend fun resumeDownload(id: String): Result<Unit> {
        // Resume is equivalent to start for now
        return startDownload(id)
    }

    override suspend fun deleteDownload(id: String): Result<Unit> {
        return try {
            api.deleteDownload(id)
            downloadDao.deleteById(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Timber.e(e, "Failed to delete download")
            Result.failure(e)
        }
    }

    override suspend fun clearCompleted(): Result<Unit> {
        return try {
            api.clearCompleted()
            downloadDao.deleteCompleted()
            Result.success(Unit)
        } catch (e: Exception) {
            Timber.e(e, "Failed to clear completed")
            Result.failure(e)
        }
    }

    override suspend fun clearAll(): Result<Unit> {
        return try {
            api.clearAll()
            downloadDao.deleteAll()
            Result.success(Unit)
        } catch (e: Exception) {
            Timber.e(e, "Failed to clear all")
            Result.failure(e)
        }
    }

    override suspend fun retryDownload(id: String): Result<Unit> {
        return try {
            // Delete the failed download and re-add it
            val download = downloadDao.getById(id)?.toDomain()
                ?: return Result.failure(Exception("Download not found"))

            deleteDownload(id)
            addDownload(
                DownloadRequest(
                    url = download.url,
                    quality = download.quality,
                    format = download.format,
                    folder = download.folder,
                    autoStart = true
                )
            )
            Result.success(Unit)
        } catch (e: Exception) {
            Timber.e(e, "Failed to retry download")
            Result.failure(e)
        }
    }

    override suspend fun syncWithServer(): Result<Unit> {
        return try {
            val downloads = api.getDownloads()
            val entities = downloads.map { it.toDomain().toEntity() }
            downloadDao.insertAll(entities)
            Result.success(Unit)
        } catch (e: Exception) {
            Timber.e(e, "Failed to sync with server")
            Result.failure(e)
        }
    }
}
