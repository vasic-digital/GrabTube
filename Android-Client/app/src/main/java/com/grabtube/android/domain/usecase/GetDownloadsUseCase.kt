package com.grabtube.android.domain.usecase

import com.grabtube.android.domain.model.Download
import com.grabtube.android.domain.repository.DownloadRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

/**
 * Use case for observing all downloads
 */
class GetDownloadsUseCase @Inject constructor(
    private val downloadRepository: DownloadRepository
) {
    operator fun invoke(): Flow<List<Download>> {
        return downloadRepository.observeDownloads()
    }
}
