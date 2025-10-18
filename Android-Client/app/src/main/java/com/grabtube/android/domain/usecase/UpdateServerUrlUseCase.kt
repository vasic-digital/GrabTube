package com.grabtube.android.domain.usecase

import com.grabtube.android.domain.repository.ServerRepository
import javax.inject.Inject

/**
 * Use case for updating server URL
 */
class UpdateServerUrlUseCase @Inject constructor(
    private val serverRepository: ServerRepository
) {
    suspend operator fun invoke(url: String): Result<Unit> {
        // Validate URL format
        if (!isValidUrl(url)) {
            return Result.failure(IllegalArgumentException("Invalid URL format"))
        }

        // Test connection first
        return serverRepository.testConnection(url).fold(
            onSuccess = { isReachable ->
                if (isReachable) {
                    serverRepository.updateServerUrl(url)
                } else {
                    Result.failure(Exception("Server is not reachable"))
                }
            },
            onFailure = { error ->
                Result.failure(error)
            }
        )
    }

    private fun isValidUrl(url: String): Boolean {
        return url.matches(Regex("^https?://.*"))
    }
}
