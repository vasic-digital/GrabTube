package com.grabtube.android.domain.usecase

import com.grabtube.android.domain.repository.DownloadRepository
import com.grabtube.android.domain.repository.ServerRepository
import javax.inject.Inject

/**
 * Use case for connecting to server and syncing downloads
 */
class ConnectToServerUseCase @Inject constructor(
    private val serverRepository: ServerRepository,
    private val downloadRepository: DownloadRepository
) {
    suspend operator fun invoke(): Result<Unit> {
        // Connect to server
        return serverRepository.connect().onSuccess {
            // Sync downloads after successful connection
            downloadRepository.syncWithServer()
        }
    }
}
