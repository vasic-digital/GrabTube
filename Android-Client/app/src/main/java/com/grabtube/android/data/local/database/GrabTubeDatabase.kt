package com.grabtube.android.data.local.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.grabtube.android.data.local.dao.DownloadDao
import com.grabtube.android.data.local.entity.DownloadEntity

@Database(
    entities = [DownloadEntity::class],
    version = 2,
    exportSchema = true
)
abstract class GrabTubeDatabase : RoomDatabase() {
    abstract fun downloadDao(): DownloadDao

    companion object {
        const val DATABASE_NAME = "grabtube_database"

        val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Add isFavorite column with default value false
                database.execSQL("ALTER TABLE downloads ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0")
            }
        }
    }
}
