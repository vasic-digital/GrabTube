package com.grabtube.android.data.local.database

import androidx.room.Database
import androidx.room.RoomDatabase
import com.grabtube.android.data.local.dao.DownloadDao
import com.grabtube.android.data.local.entity.DownloadEntity

@Database(
    entities = [DownloadEntity::class],
    version = 1,
    exportSchema = true
)
abstract class GrabTubeDatabase : RoomDatabase() {
    abstract fun downloadDao(): DownloadDao

    companion object {
        const val DATABASE_NAME = "grabtube_database"
    }
}
