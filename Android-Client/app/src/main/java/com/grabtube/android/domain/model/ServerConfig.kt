package com.grabtube.android.domain.model

/**
 * Domain model for server configuration
 */
data class ServerConfig(
    val url: String,
    val isConnected: Boolean = false,
    val version: String? = null,
    val allowedQualities: List<String> = emptyList(),
    val allowedFormats: List<String> = emptyList(),
    val customFolders: List<String> = emptyList()
)
