package com.grabtube.android.presentation.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grabtube.android.domain.model.ServerConfig
import com.grabtube.android.domain.repository.ServerRepository
import com.grabtube.android.domain.usecase.ConnectToServerUseCase
import com.grabtube.android.domain.usecase.UpdateServerUrlUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val serverRepository: ServerRepository,
    private val connectToServerUseCase: ConnectToServerUseCase,
    private val updateServerUrlUseCase: UpdateServerUrlUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    val serverConfig: StateFlow<ServerConfig> = serverRepository.observeServerConfig()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = ServerConfig(url = "")
        )

    init {
        connectToServer()
    }

    fun onEvent(event: SettingsEvent) {
        when (event) {
            is SettingsEvent.UpdateServerUrl -> updateServerUrl(event.url)
            is SettingsEvent.ConnectToServer -> connectToServer()
            is SettingsEvent.DisconnectFromServer -> disconnectFromServer()
            is SettingsEvent.DismissError -> dismissError()
        }
    }

    private fun updateServerUrl(url: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }

            updateServerUrlUseCase(url).fold(
                onSuccess = {
                    Timber.d("Server URL updated: $url")
                    _uiState.update { it.copy(isLoading = false) }
                    connectToServer()
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to update server URL")
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            error = error.message ?: "Failed to update server URL"
                        )
                    }
                }
            )
        }
    }

    private fun connectToServer() {
        viewModelScope.launch {
            _uiState.update { it.copy(isConnecting = true) }

            connectToServerUseCase().fold(
                onSuccess = {
                    Timber.d("Connected to server")
                    _uiState.update { it.copy(isConnecting = false) }
                },
                onFailure = { error ->
                    Timber.e(error, "Failed to connect to server")
                    _uiState.update {
                        it.copy(
                            isConnecting = false,
                            error = error.message ?: "Failed to connect to server"
                        )
                    }
                }
            )
        }
    }

    private fun disconnectFromServer() {
        viewModelScope.launch {
            serverRepository.disconnect()
            Timber.d("Disconnected from server")
        }
    }

    private fun dismissError() {
        _uiState.update { it.copy(error = null) }
    }
}

data class SettingsUiState(
    val isLoading: Boolean = false,
    val isConnecting: Boolean = false,
    val error: String? = null
)

sealed class SettingsEvent {
    data class UpdateServerUrl(val url: String) : SettingsEvent()
    object ConnectToServer : SettingsEvent()
    object DisconnectFromServer : SettingsEvent()
    object DismissError : SettingsEvent()
}
