package com.grabtube.android.presentation.qr_scanner

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grabtube.android.domain.model.QRScanResult
import com.grabtube.android.domain.usecase.ScanQRCodeUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

@HiltViewModel
class QRScannerViewModel @Inject constructor(
    private val scanQRCodeUseCase: ScanQRCodeUseCase
) : ViewModel() {

    private val _state = MutableStateFlow(QRScannerState())
    val state: StateFlow<QRScannerState> = _state.asStateFlow()

    fun startScanning() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true, error = null)

            scanQRCodeUseCase().fold(
                onSuccess = { result ->
                    _state.value = _state.value.copy(
                        isLoading = false,
                        scanResult = result,
                        error = null
                    )
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to scan QR code")
                    _state.value = _state.value.copy(
                        isLoading = false,
                        error = error.message ?: "Unknown error occurred"
                    )
                }
            )
        }
    }

    fun requestCameraPermission(context: Context) {
        // This would trigger permission request - in a real implementation,
        // this would be handled by the activity/fragment
        _state.value = _state.value.copy(showPermissionRequired = false)
        startScanning()
    }

    fun reset() {
        _state.value = QRScannerState()
    }
}

data class QRScannerState(
    val isLoading: Boolean = false,
    val scanResult: QRScanResult? = null,
    val error: String? = null,
    val showPermissionRequired: Boolean = false
)