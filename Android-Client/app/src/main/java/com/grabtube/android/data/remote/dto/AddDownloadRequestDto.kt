package com.grabtube.android.data.remote.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AddDownloadRequestDto(
    @SerialName("url")
    val url: String,
    @SerialName("quality")
    val quality: String = "best",
    @SerialName("format")
    val format: String = "any",
    @SerialName("folder")
    val folder: String? = null,
    @SerialName("auto_start")
    val autoStart: Boolean = true
)
