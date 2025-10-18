package com.grabtube.android.domain.usecase

import com.grabtube.android.domain.model.DownloadHistory
import com.grabtube.android.domain.repository.DownloadRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

/**
 * Use case for getting download history
 */
class GetDownloadHistoryUseCase @Inject constructor(
    private val downloadRepository: DownloadRepository
) {
    operator fun invoke(limit: Int = 100, offset: Int = 0): Flow<List<DownloadHistory>> {
        return downloadRepository.getHistory(limit, offset)
    }
}
