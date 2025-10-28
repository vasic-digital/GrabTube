package com.grabtube.android.presentation.downloads

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import androidx.navigation.compose.currentBackStackEntryAsState
import com.grabtube.android.presentation.downloads.components.AddDownloadDialog
import com.grabtube.android.presentation.downloads.components.DownloadItem

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DownloadsScreen(
    navController: NavController,
    onNavigateToSettings: () -> Unit,
    onNavigateToQRScanner: () -> Unit,
    sharedUrl: String? = null,
    viewModel: DownloadsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val downloads by viewModel.downloads.collectAsStateWithLifecycle()
    val navBackStackEntry by navController.currentBackStackEntryAsState()

    // Handle shared URL and scanned URL
    LaunchedEffect(sharedUrl) {
        if (!sharedUrl.isNullOrBlank()) {
            viewModel.onEvent(DownloadsEvent.AddDownload(sharedUrl))
        }
    }

    // Handle scanned URL from QR scanner
    LaunchedEffect(navBackStackEntry) {
        val scannedUrl = navBackStackEntry?.savedStateHandle?.get<String>("scannedUrl")
        if (!scannedUrl.isNullOrBlank()) {
            viewModel.onEvent(DownloadsEvent.AddDownload(scannedUrl))
            navBackStackEntry?.savedStateHandle?.remove<String>("scannedUrl")
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("GrabTube") },
                actions = {
                    IconButton(onClick = onNavigateToQRScanner) {
                        Icon(Icons.Default.QrCodeScanner, contentDescription = "Scan QR Code")
                    }
                    IconButton(onClick = { viewModel.onEvent(DownloadsEvent.ClearCompleted) }) {
                        Icon(Icons.Default.Delete, contentDescription = "Clear Completed")
                    }
                    IconButton(onClick = onNavigateToSettings) {
                        Icon(Icons.Default.Settings, contentDescription = "Settings")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { viewModel.onEvent(DownloadsEvent.ShowAddDialog) }
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add Download")
            }
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            if (downloads.isEmpty()) {
                EmptyState(
                    modifier = Modifier.align(Alignment.Center),
                    onAddClick = { viewModel.onEvent(DownloadsEvent.ShowAddDialog) }
                )
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(
                        items = downloads,
                        key = { it.id }
                    ) { download ->
                        DownloadItem(
                            download = download,
                            onCancel = { viewModel.onEvent(DownloadsEvent.CancelDownload(download.id)) },
                            onRetry = { viewModel.onEvent(DownloadsEvent.RetryDownload(download.id)) },
                            onDelete = { viewModel.onEvent(DownloadsEvent.DeleteDownload(download.id)) },
                            onStart = { viewModel.onEvent(DownloadsEvent.StartDownload(download.id)) }
                        )
                    }
                }
            }

            if (uiState.isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.align(Alignment.Center)
                )
            }
        }
    }

    if (uiState.showAddDialog) {
        AddDownloadDialog(
            initialUrl = sharedUrl ?: "",
            onDismiss = { viewModel.onEvent(DownloadsEvent.HideAddDialog) },
            onConfirm = { url, quality, format, folder ->
                viewModel.onEvent(DownloadsEvent.AddDownload(url, quality, format, folder))
            }
        )
    }

    uiState.error?.let { error ->
        LaunchedEffect(error) {
            // Show snackbar or error dialog
            viewModel.onEvent(DownloadsEvent.DismissError)
        }
    }
}

@Composable
private fun EmptyState(
    modifier: Modifier = Modifier,
    onAddClick: () -> Unit
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Icon(
            imageVector = Icons.Default.Download,
            contentDescription = null,
            modifier = Modifier.size(120.dp),
            tint = MaterialTheme.colorScheme.primary.copy(alpha = 0.6f)
        )
        Text(
            text = "No downloads yet",
            style = MaterialTheme.typography.headlineSmall,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
        )
        Text(
            text = "Tap the + button to add a download",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
        )
        FilledTonalButton(onClick = onAddClick) {
            Icon(Icons.Default.Add, contentDescription = null)
            Spacer(Modifier.width(8.dp))
            Text("Add Download")
        }
    }
}
