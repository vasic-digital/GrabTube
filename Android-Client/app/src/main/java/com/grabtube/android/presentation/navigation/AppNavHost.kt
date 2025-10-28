package com.grabtube.android.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.grabtube.android.presentation.downloads.DownloadsScreen
import com.grabtube.android.presentation.qr_scanner.QRScannerScreen
import com.grabtube.android.presentation.settings.SettingsScreen

@Composable
fun AppNavHost(
    navController: NavHostController = rememberNavController(),
    sharedUrl: String? = null
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Downloads.route
    ) {
        composable(Screen.Downloads.route) {
            DownloadsScreen(
                navController = navController,
                onNavigateToSettings = {
                    navController.navigate(Screen.Settings.route)
                },
                onNavigateToQRScanner = {
                    navController.navigate(Screen.QRScanner.route)
                },
                sharedUrl = sharedUrl
            )
        }

        composable(Screen.Settings.route) {
            SettingsScreen(
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        composable(Screen.QRScanner.route) {
            val scannedUrl = navController.previousBackStackEntry
                ?.savedStateHandle
                ?.get<String>("scannedUrl")

            QRScannerScreen(
                onNavigateBack = {
                    navController.popBackStack()
                },
                onUrlScanned = { url ->
                    // Set the scanned URL in the saved state handle for the downloads screen
                    navController.previousBackStackEntry?.savedStateHandle?.set("scannedUrl", url)
                    navController.popBackStack()
                }
            )
        }
    }
}

sealed class Screen(val route: String) {
    object Downloads : Screen("downloads")
    object Settings : Screen("settings")
    object QRScanner : Screen("qr_scanner")
}
