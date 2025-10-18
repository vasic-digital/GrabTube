package com.grabtube.android.domain.usecase

import com.grabtube.android.domain.repository.DownloadRepository
import javax.inject.Inject

/**
 * Use case for canceling a download
 */
class CancelDownloadUseCase @Inject constructor(
    private val downloadRepository: DownloadRepository
) {
    suspend operator fun invoke(downloadId: String): Result<Unit> {
        if (downloadId.isBlank()) {
            return Result.failure(IllegalArgumentException("Download ID cannot be empty"))
        }

        return downloadRepository.cancelDownload(downloadId)
    }
}
