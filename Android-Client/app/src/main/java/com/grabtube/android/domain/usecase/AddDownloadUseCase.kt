package com.grabtube.android.domain.usecase

import com.grabtube.android.domain.model.Download
import com.grabtube.android.domain.model.DownloadRequest
import com.grabtube.android.domain.repository.DownloadRepository
import javax.inject.Inject

/**
 * Use case for adding a new download
 */
class AddDownloadUseCase @Inject constructor(
    private val downloadRepository: DownloadRepository
) {
    suspend operator fun invoke(request: DownloadRequest): Result<Download> {
        // Validate URL
        if (request.url.isBlank()) {
            return Result.failure(IllegalArgumentException("URL cannot be empty"))
        }

        // Add download
        return downloadRepository.addDownload(request)
    }
}
