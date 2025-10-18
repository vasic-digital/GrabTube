package com.grabtube.android.di

import com.grabtube.android.data.repository.DownloadRepositoryImpl
import com.grabtube.android.data.repository.ServerRepositoryImpl
import com.grabtube.android.domain.repository.DownloadRepository
import com.grabtube.android.domain.repository.ServerRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindDownloadRepository(
        downloadRepositoryImpl: DownloadRepositoryImpl
    ): DownloadRepository

    @Binds
    @Singleton
    abstract fun bindServerRepository(
        serverRepositoryImpl: ServerRepositoryImpl
    ): ServerRepository
}
