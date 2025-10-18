package com.grabtube.android.data.remote.dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AddDownloadResponseDto(
    @SerialName("status")
    val status: String,
    @SerialName("id")
    val id: String? = null,
    @SerialName("error")
    val error: String? = null
)
