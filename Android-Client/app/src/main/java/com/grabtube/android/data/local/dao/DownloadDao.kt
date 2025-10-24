package com.grabtube.android.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.grabtube.android.data.local.entity.DownloadEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface DownloadDao {
    @Query("SELECT * FROM downloads ORDER BY addedAt DESC")
    fun observeAll(): Flow<List<DownloadEntity>>

    @Query("SELECT * FROM downloads WHERE id = :id")
    fun observeById(id: String): Flow<DownloadEntity?>

    @Query("SELECT * FROM downloads WHERE id = :id")
    suspend fun getById(id: String): DownloadEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(download: DownloadEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(downloads: List<DownloadEntity>)

    @Update
    suspend fun update(download: DownloadEntity)

    @Query("DELETE FROM downloads WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("DELETE FROM downloads WHERE status IN ('COMPLETED', 'FAILED', 'CANCELED')")
    suspend fun deleteCompleted()

    @Query("DELETE FROM downloads")
    suspend fun deleteAll()

    @Query("SELECT * FROM downloads WHERE status = 'COMPLETED' ORDER BY completedAt DESC LIMIT :limit OFFSET :offset")
    fun getHistory(limit: Int, offset: Int): Flow<List<DownloadEntity>>

    @Query("UPDATE downloads SET isFavorite = :isFavorite WHERE id = :id")
    suspend fun updateFavorite(id: String, isFavorite: Boolean)

    @Query("SELECT * FROM downloads WHERE isFavorite = 1 ORDER BY addedAt DESC")
    fun observeFavorites(): Flow<List<DownloadEntity>>

    @Query("""
        SELECT * FROM downloads
        WHERE (:query IS NULL OR title LIKE '%' || :query || '%' OR url LIKE '%' || :query || '%')
        AND (:favoritesOnly = 0 OR isFavorite = 1)
        AND (:status IS NULL OR status = :status)
        ORDER BY
            CASE WHEN :sortBy = 'title' THEN title END ASC,
            CASE WHEN :sortBy = 'date' THEN addedAt END DESC,
            CASE WHEN :sortBy = 'status' THEN status END ASC
        LIMIT :limit OFFSET :offset
    """)
    suspend fun searchDownloads(
        query: String?,
        favoritesOnly: Boolean,
        status: String?,
        sortBy: String,
        limit: Int,
        offset: Int
    ): List<DownloadEntity>

    @Query("""
        SELECT COUNT(*) FROM downloads
        WHERE (:query IS NULL OR title LIKE '%' || :query || '%' OR url LIKE '%' || :query || '%')
        AND (:favoritesOnly = 0 OR isFavorite = 1)
        AND (:status IS NULL OR status = :status)
    """)
    suspend fun countSearchResults(
        query: String?,
        favoritesOnly: Boolean,
        status: String?
    ): Int
}
