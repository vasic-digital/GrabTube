package com.grabtube.android.data.remote.api

import com.grabtube.android.data.remote.dto.AddDownloadRequestDto
import com.grabtube.android.data.remote.dto.AddDownloadResponseDto
import com.grabtube.android.data.remote.dto.DownloadDto
import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path

/**
 * Retrofit API interface for GrabTube server
 */
interface GrabTubeApi {
    /**
     * Get all downloads
     */
    @GET("downloads")
    suspend fun getDownloads(): List<DownloadDto>

    /**
     * Add a new download
     */
    @POST("add")
    suspend fun addDownload(@Body request: AddDownloadRequestDto): AddDownloadResponseDto

    /**
     * Start a pending download
     */
    @POST("download/{id}/start")
    suspend fun startDownload(@Path("id") id: String)

    /**
     * Delete a download
     */
    @DELETE("download/{id}")
    suspend fun deleteDownload(@Path("id") id: String)

    /**
     * Cancel a download
     */
    @POST("download/{id}/cancel")
    suspend fun cancelDownload(@Path("id") id: String)

    /**
     * Clear all completed downloads
     */
    @POST("downloads/clear/completed")
    suspend fun clearCompleted()

    /**
     * Clear all downloads
     */
    @POST("downloads/clear/all")
    suspend fun clearAll()

    /**
     * Get download history
     */
    @GET("history")
    suspend fun getHistory(): List<DownloadDto>
}
