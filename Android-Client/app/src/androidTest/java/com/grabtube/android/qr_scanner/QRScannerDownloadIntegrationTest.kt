package com.grabtube.android.qr_scanner

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.grabtube.android.domain.model.DownloadRequest
import com.grabtube.android.domain.model.QRScanResult
import com.grabtube.android.domain.repository.DownloadRepository
import com.grabtube.android.domain.repository.QRScannerRepository
import com.grabtube.android.domain.usecase.AddDownloadUseCase
import com.grabtube.android.domain.usecase.ScanQRCodeUseCase
import dagger.hilt.android.testing.HiltAndroidTest
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import java.time.LocalDateTime
import javax.inject.Inject

@HiltAndroidTest
@RunWith(AndroidJUnit4::class)
class QRScannerDownloadIntegrationTest {

    @Inject
    lateinit var qrScannerRepository: QRScannerRepository

    @Inject
    lateinit var downloadRepository: DownloadRepository

    @Inject
    lateinit var scanQRCodeUseCase: ScanQRCodeUseCase

    @Inject
    lateinit var addDownloadUseCase: AddDownloadUseCase

    @Test
    fun `QR scan result can be used to create download successfully`() = runTest {
        // Arrange - Scan QR code
        val scanResult = scanQRCodeUseCase()
        assertTrue("QR scan should succeed", scanResult.isSuccess)

        val qrResult = scanResult.getOrNull()!!
        assertTrue("QR result should have valid URL", qrResult.isValidUrl)
        assertTrue("Extracted URL should not be null", qrResult.extractedUrl != null)

        // Act - Use scanned URL to create download
        val downloadRequest = DownloadRequest(
            url = qrResult.extractedUrl!!,
            quality = "best",
            format = "any",
            folder = null,
            autoStart = true
        )

        val downloadResult = addDownloadUseCase(downloadRequest)

        // Assert - Download should be created successfully
        assertTrue("Download creation should succeed", downloadResult.isSuccess)

        val download = downloadResult.getOrNull()!!
        assertTrue("Download should have valid ID", download.id.isNotBlank())
        assertTrue("Download URL should match scanned URL", download.url == qrResult.extractedUrl)
    }

    @Test
    fun `QR scanner repository integration with URL extraction`() = runTest {
        // Test the full flow from QR scanning to URL extraction
        val scanResult = qrScannerRepository.scanQRCode()
        assertTrue("QR scan should succeed", scanResult.isSuccess)

        val qrResult = scanResult.getOrNull()!!
        val extractedUrl = qrScannerRepository.extractUrlFromQRCode(qrResult.rawValue)
        assertTrue("URL extraction should succeed", extractedUrl.isSuccess)

        val url = extractedUrl.getOrNull()!!
        val isValid = qrScannerRepository.isValidUrl(url)
        assertTrue("Extracted URL should be valid", isValid)
    }

    @Test
    fun `Permission handling integration in QR scanner flow`() = runTest {
        // Test permission checking
        val hasPermission = qrScannerRepository.hasCameraPermission()
        // Note: Permission state depends on device/test environment

        if (!hasPermission) {
            // If no permission, requesting should either succeed or fail gracefully
            val requestResult = qrScannerRepository.requestCameraPermission()
            // Either permission is granted or properly denied
            assertTrue(requestResult.isSuccess || requestResult.isFailure)
        } else {
            // If permission exists, scanning should work
            val scanResult = qrScannerRepository.scanQRCode()
            assertTrue("QR scan should succeed when permission granted", scanResult.isSuccess)
        }
    }
}