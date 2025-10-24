package com.grabtube.android.data.local.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.grabtube.android.data.local.dao.DownloadDao
import com.grabtube.android.data.local.dao.ScheduleDao
import com.grabtube.android.data.local.entity.DownloadEntity
import com.grabtube.android.data.local.entity.ScheduleEntity
import com.grabtube.android.data.local.entity.ScheduledDownloadEntity

@Database(
    entities = [DownloadEntity::class, ScheduleEntity::class, ScheduledDownloadEntity::class],
    version = 3,
    exportSchema = true
)
abstract class GrabTubeDatabase : RoomDatabase() {
    abstract fun downloadDao(): DownloadDao
    abstract fun scheduleDao(): ScheduleDao

    companion object {
        const val DATABASE_NAME = "grabtube_database"

        val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Add isFavorite column with default value false
                database.execSQL("ALTER TABLE downloads ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0")
            }
        }

        val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Create schedules table
                database.execSQL("""
                    CREATE TABLE schedules (
                        id TEXT PRIMARY KEY NOT NULL,
                        name TEXT NOT NULL,
                        description TEXT NOT NULL,
                        type TEXT NOT NULL,
                        startDate INTEGER,
                        startTime INTEGER,
                        recurrencePattern TEXT,
                        weekDays TEXT,
                        dayOfMonth INTEGER,
                        interval INTEGER,
                        timeUnit TEXT,
                        endDate INTEGER,
                        maxExecutions INTEGER,
                        isActive INTEGER NOT NULL,
                        createdAt INTEGER NOT NULL,
                        lastExecutedAt INTEGER,
                        nextExecutionAt INTEGER,
                        executionCount INTEGER NOT NULL,
                        metadata TEXT
                    )
                """)

                // Create scheduled_downloads table
                database.execSQL("""
                    CREATE TABLE scheduled_downloads (
                        id TEXT PRIMARY KEY NOT NULL,
                        scheduleId TEXT NOT NULL,
                        downloadId TEXT NOT NULL,
                        scheduledAt INTEGER NOT NULL,
                        executedAt INTEGER,
                        isExecuted INTEGER NOT NULL,
                        isSuccessful INTEGER NOT NULL,
                        errorMessage TEXT,
                        result TEXT
                    )
                """)
            }
        }
    }
}
