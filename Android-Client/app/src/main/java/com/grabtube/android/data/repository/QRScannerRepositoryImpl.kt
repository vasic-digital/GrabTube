package com.grabtube.android.data.repository

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import com.grabtube.android.domain.model.QRScanResult
import com.grabtube.android.domain.repository.QRScannerRepository
import kotlinx.coroutines.suspendCancellableCoroutine
import timber.log.Timber
import java.time.LocalDateTime
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

@Singleton
class QRScannerRepositoryImpl @Inject constructor(
    private val context: Context
) : QRScannerRepository {

    private val cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private val scanner = BarcodeScanning.getClient()
    private var cameraProvider: ProcessCameraProvider? = null
    private var imageAnalysis: ImageAnalysis? = null

    override suspend fun scanQRCode(): Result<QRScanResult> {
        return try {
            // For now, return a mock implementation that would be replaced with actual camera integration
            // In a real implementation, this would use CameraX with proper lifecycle management
            // and would be called from a composable or activity with proper camera permissions

            // Mock successful scan for development
            val result = QRScanResult(
                rawValue = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                extractedUrl = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                scannedAt = LocalDateTime.now(),
                isValidUrl = true
            )
            Result.success(result)
        } catch (e: Exception) {
            Timber.e(e, "Failed to scan QR code")
            Result.failure(e)
        }
    }

    override suspend fun extractUrlFromQRCode(qrData: String): Result<String> {
        return try {
            val urlPattern = Regex(
                "https?://(?:[-\\w.])+(?:[:\\d]+)?(?:/(?:[\\w/_.])*(?:\\?(?:[\\w&=%.])*)?(?:#(?:\\w*))?)?",
                RegexOption.IGNORE_CASE
            )

            val matches = urlPattern.findAll(qrData)
            val url = matches.firstOrNull()?.value ?: ""
            Result.success(url)
        } catch (e: Exception) {
            Timber.e(e, "Failed to extract URL from QR code")
            Result.failure(e)
        }
    }

    override suspend fun isValidUrl(url: String): Boolean {
        return try {
            val urlPattern = Regex("^https?://.*")
            urlPattern.matches(url)
        } catch (e: Exception) {
            Timber.e(e, "Failed to validate URL")
            false
        }
    }

    override suspend fun requestCameraPermission(): Result<Unit> {
        return try {
            val hasPermission = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED

            if (hasPermission) {
                Result.success(Unit)
            } else {
                Result.failure(Exception("Camera permission not granted"))
            }
        } catch (e: Exception) {
            Timber.e(e, "Failed to request camera permission")
            Result.failure(e)
        }
    }

    override suspend fun hasCameraPermission(): Boolean {
        return try {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED
        } catch (e: Exception) {
            Timber.e(e, "Failed to check camera permission")
            false
        }
    }

    private inner class QRCodeAnalyzer(
        private val onQRCodeDetected: (String) -> Unit
    ) : ImageAnalysis.Analyzer {

        override fun analyze(image: ImageProxy) {
            val mediaImage = image.image
            if (mediaImage != null) {
                val imageInput = com.google.mlkit.vision.common.InputImage.fromMediaImage(
                    mediaImage,
                    image.imageInfo.rotationDegrees
                )

                scanner.process(imageInput)
                    .addOnSuccessListener { barcodes ->
                        for (barcode in barcodes) {
                            barcode.rawValue?.let { value ->
                                onQRCodeDetected(value)
                                return@addOnSuccessListener
                            }
                        }
                    }
                    .addOnFailureListener { e ->
                        Timber.e(e, "Failed to process barcode")
                    }
                    .addOnCompleteListener {
                        image.close()
                    }
            } else {
                image.close()
            }
        }
    }
}