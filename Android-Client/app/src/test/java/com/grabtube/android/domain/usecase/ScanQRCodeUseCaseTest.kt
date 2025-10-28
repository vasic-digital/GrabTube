package com.grabtube.android.domain.usecase

import com.grabtube.android.domain.model.QRScanResult
import com.grabtube.android.domain.repository.QRScannerRepository
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import java.time.LocalDateTime

class ScanQRCodeUseCaseTest {

    private lateinit var useCase: ScanQRCodeUseCase
    private lateinit var mockRepository: QRScannerRepository

    @Before
    fun setUp() {
        mockRepository = mockk()
        useCase = ScanQRCodeUseCase(mockRepository)
    }

    @Test
    fun `invoke returns success when repository scan succeeds`() = runTest {
        // Arrange
        val expectedResult = QRScanResult(
            rawValue = "https://youtube.com/watch?v=test",
            extractedUrl = "https://youtube.com/watch?v=test",
            scannedAt = LocalDateTime.now(),
            isValidUrl = true
        )
        coEvery { mockRepository.hasCameraPermission() } returns true
        coEvery { mockRepository.scanQRCode() } returns Result.success(expectedResult)

        // Act
        val result = useCase()

        // Assert
        assertTrue(result.isSuccess)
        assertEquals(expectedResult, result.getOrNull())
        coVerify { mockRepository.hasCameraPermission() }
        coVerify { mockRepository.scanQRCode() }
        coVerify(exactly = 0) { mockRepository.requestCameraPermission() }
    }

    @Test
    fun `invoke requests permission when not granted and succeeds`() = runTest {
        // Arrange
        val expectedResult = QRScanResult(
            rawValue = "https://youtube.com/watch?v=test",
            extractedUrl = "https://youtube.com/watch?v=test",
            scannedAt = LocalDateTime.now(),
            isValidUrl = true
        )
        coEvery { mockRepository.hasCameraPermission() } returns false
        coEvery { mockRepository.requestCameraPermission() } returns Result.success(Unit)
        coEvery { mockRepository.scanQRCode() } returns Result.success(expectedResult)

        // Act
        val result = useCase()

        // Assert
        assertTrue(result.isSuccess)
        assertEquals(expectedResult, result.getOrNull())
        coVerify { mockRepository.hasCameraPermission() }
        coVerify { mockRepository.requestCameraPermission() }
        coVerify { mockRepository.scanQRCode() }
    }

    @Test
    fun `invoke returns failure when permission denied`() = runTest {
        // Arrange
        coEvery { mockRepository.hasCameraPermission() } returns false
        coEvery { mockRepository.requestCameraPermission() } returns Result.failure(Exception("Permission denied"))

        // Act
        val result = useCase()

        // Assert
        assertTrue(result.isFailure)
        coVerify { mockRepository.hasCameraPermission() }
        coVerify { mockRepository.requestCameraPermission() }
        coVerify(exactly = 0) { mockRepository.scanQRCode() }
    }

    @Test
    fun `invoke returns failure when scan fails`() = runTest {
        // Arrange
        val expectedError = Exception("Scan failed")
        coEvery { mockRepository.hasCameraPermission() } returns true
        coEvery { mockRepository.scanQRCode() } returns Result.failure(expectedError)

        // Act
        val result = useCase()

        // Assert
        assertTrue(result.isFailure)
        assertEquals(expectedError, result.exceptionOrNull())
        coVerify { mockRepository.hasCameraPermission() }
        coVerify { mockRepository.scanQRCode() }
    }
}