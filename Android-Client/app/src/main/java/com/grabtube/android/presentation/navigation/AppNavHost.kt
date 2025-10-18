package com.grabtube.android.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.grabtube.android.presentation.downloads.DownloadsScreen
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
                onNavigateToSettings = {
                    navController.navigate(Screen.Settings.route)
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
    }
}

sealed class Screen(val route: String) {
    object Downloads : Screen("downloads")
    object Settings : Screen("settings")
}
