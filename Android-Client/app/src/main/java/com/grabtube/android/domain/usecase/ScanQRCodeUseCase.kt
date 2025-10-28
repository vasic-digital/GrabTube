package com.grabtube.android.domain.usecase

import com.grabtube.android.domain.model.QRScanResult
import com.grabtube.android.domain.repository.QRScannerRepository
import javax.inject.Inject

class ScanQRCodeUseCase @Inject constructor(
    private val repository: QRScannerRepository
) {
    suspend operator fun invoke(): Result<QRScanResult> {
        val hasPermission = repository.hasCameraPermission()
        if (!hasPermission) {
            val permissionResult = repository.requestCameraPermission()
            if (permissionResult.isFailure) {
                return Result.failure(permissionResult.exceptionOrNull() ?: Exception("Permission denied"))
            }
        }

        return repository.scanQRCode()
    }
}