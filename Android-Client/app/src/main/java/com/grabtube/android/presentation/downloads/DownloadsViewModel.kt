package com.grabtube.android.presentation.downloads

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grabtube.android.domain.model.Download
import com.grabtube.android.domain.model.DownloadRequest
import com.grabtube.android.domain.usecase.AddDownloadUseCase
import com.grabtube.android.domain.usecase.CancelDownloadUseCase
import com.grabtube.android.domain.usecase.GetDownloadsUseCase
import com.grabtube.android.domain.repository.DownloadRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

@HiltViewModel
class DownloadsViewModel @Inject constructor(
    private val addDownloadUseCase: AddDownloadUseCase,
    private val cancelDownloadUseCase: CancelDownloadUseCase,
    private val getDownloadsUseCase: GetDownloadsUseCase,
    private val downloadRepository: DownloadRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(DownloadsUiState())
    val uiState: StateFlow<DownloadsUiState> = _uiState.asStateFlow()

    val downloads: StateFlow<List<Download>> = getDownloadsUseCase()
        .map { downloads ->
            downloads.sortedByDescending { it.addedAt }
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    fun onEvent(event: DownloadsEvent) {
        when (event) {
            is DownloadsEvent.AddDownload -> addDownload(event.url, event.quality, event.format, event.folder)
            is DownloadsEvent.CancelDownload -> cancelDownload(event.downloadId)
            is DownloadsEvent.DeleteDownload -> deleteDownload(event.downloadId)
            is DownloadsEvent.RetryDownload -> retryDownload(event.downloadId)
            is DownloadsEvent.StartDownload -> startDownload(event.downloadId)
            is DownloadsEvent.ClearCompleted -> clearCompleted()
            is DownloadsEvent.ClearAll -> clearAll()
            is DownloadsEvent.DismissError -> dismissError()
            is DownloadsEvent.ShowAddDialog -> showAddDialog()
            is DownloadsEvent.HideAddDialog -> hideAddDialog()
        }
    }

    private fun addDownload(url: String, quality: String, format: String, folder: String?) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }

            val request = DownloadRequest(
                url = url.trim(),
                quality = quality,
                format = format,
                folder = folder,
                autoStart = true
            )

            addDownloadUseCase(request).fold(
                onSuccess = { download ->
                    Timber.d("Download added: ${download.id}")
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            showAddDialog = false
                        )
                    }
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to add download")
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            error = error.message ?: "Failed to add download"
                        )
                    }
                }
            )
        }
    }

    private fun cancelDownload(downloadId: String) {
        viewModelScope.launch {
            cancelDownloadUseCase(downloadId).fold(
                onSuccess = {
                    Timber.d("Download canceled: $downloadId")
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to cancel download")
                    _uiState.update {
                        it.copy(error = error.message ?: "Failed to cancel download")
                    }
                }
            )
        }
    }

    private fun deleteDownload(downloadId: String) {
        viewModelScope.launch {
            downloadRepository.deleteDownload(downloadId).fold(
                onSuccess = {
                    Timber.d("Download deleted: $downloadId")
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to delete download")
                    _uiState.update {
                        it.copy(error = error.message ?: "Failed to delete download")
                    }
                }
            )
        }
    }

    private fun retryDownload(downloadId: String) {
        viewModelScope.launch {
            downloadRepository.retryDownload(downloadId).fold(
                onSuccess = {
                    Timber.d("Download retrying: $downloadId")
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to retry download")
                    _uiState.update {
                        it.copy(error = error.message ?: "Failed to retry download")
                    }
                }
            )
        }
    }

    private fun startDownload(downloadId: String) {
        viewModelScope.launch {
            downloadRepository.startDownload(downloadId).fold(
                onSuccess = {
                    Timber.d("Download started: $downloadId")
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to start download")
                    _uiState.update {
                        it.copy(error = error.message ?: "Failed to start download")
                    }
                }
            )
        }
    }

    private fun clearCompleted() {
        viewModelScope.launch {
            downloadRepository.clearCompleted().fold(
                onSuccess = {
                    Timber.d("Completed downloads cleared")
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to clear completed")
                    _uiState.update {
                        it.copy(error = error.message ?: "Failed to clear completed downloads")
                    }
                }
            )
        }
    }

    private fun clearAll() {
        viewModelScope.launch {
            downloadRepository.clearAll().fold(
                onSuccess = {
                    Timber.d("All downloads cleared")
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to clear all")
                    _uiState.update {
                        it.copy(error = error.message ?: "Failed to clear all downloads")
                    }
                }
            )
        }
    }

    private fun dismissError() {
        _uiState.update { it.copy(error = null) }
    }

    private fun showAddDialog() {
        _uiState.update { it.copy(showAddDialog = true) }
    }

    private fun hideAddDialog() {
        _uiState.update { it.copy(showAddDialog = false) }
    }
}

data class DownloadsUiState(
    val isLoading: Boolean = false,
    val error: String? = null,
    val showAddDialog: Boolean = false
)

sealed class DownloadsEvent {
    data class AddDownload(
        val url: String,
        val quality: String = "best",
        val format: String = "any",
        val folder: String? = null
    ) : DownloadsEvent()

    data class CancelDownload(val downloadId: String) : DownloadsEvent()
    data class DeleteDownload(val downloadId: String) : DownloadsEvent()
    data class RetryDownload(val downloadId: String) : DownloadsEvent()
    data class StartDownload(val downloadId: String) : DownloadsEvent()
    object ClearCompleted : DownloadsEvent()
    object ClearAll : DownloadsEvent()
    object DismissError : DownloadsEvent()
    object ShowAddDialog : DownloadsEvent()
    object HideAddDialog : DownloadsEvent()
}
