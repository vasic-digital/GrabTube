package com.grabtube.android.domain.model

import java.time.LocalDateTime

data class QRScanResult(
    val rawValue: String,
    val extractedUrl: String?,
    val scannedAt: LocalDateTime,
    val isValidUrl: Boolean
)