package com.grabtube.android.domain.repository

import com.grabtube.android.domain.model.QRScanResult

interface QRScannerRepository {
    suspend fun scanQRCode(): Result<QRScanResult>
    suspend fun extractUrlFromQRCode(qrData: String): Result<String>
    suspend fun isValidUrl(url: String): Boolean
    suspend fun requestCameraPermission(): Result<Unit>
    suspend fun hasCameraPermission(): Boolean
}