package com.grabtube.android.presentation.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

// Default Theme Color Schemes
private val DarkColorScheme = darkColorScheme(
    primary = md_theme_dark_primary,
    onPrimary = md_theme_dark_onPrimary,
    primaryContainer = md_theme_dark_primaryContainer,
    onPrimaryContainer = md_theme_dark_onPrimaryContainer,
    secondary = md_theme_dark_secondary,
    onSecondary = md_theme_dark_onSecondary,
    secondaryContainer = md_theme_dark_secondaryContainer,
    onSecondaryContainer = md_theme_dark_onSecondaryContainer,
    tertiary = md_theme_dark_tertiary,
    onTertiary = md_theme_dark_onTertiary,
    tertiaryContainer = md_theme_dark_tertiaryContainer,
    onTertiaryContainer = md_theme_dark_onTertiaryContainer,
    error = md_theme_dark_error,
    errorContainer = md_theme_dark_errorContainer,
    onError = md_theme_dark_onError,
    onErrorContainer = md_theme_dark_onErrorContainer,
    background = md_theme_dark_background,
    onBackground = md_theme_dark_onBackground,
    surface = md_theme_dark_surface,
    onSurface = md_theme_dark_onSurface,
    surfaceVariant = md_theme_dark_surfaceVariant,
    onSurfaceVariant = md_theme_dark_onSurfaceVariant,
    outline = md_theme_dark_outline,
    inverseOnSurface = md_theme_dark_inverseOnSurface,
    inverseSurface = md_theme_dark_inverseSurface,
    inversePrimary = md_theme_dark_inversePrimary,
    surfaceTint = md_theme_dark_surfaceTint
)

private val LightColorScheme = lightColorScheme(
    primary = md_theme_light_primary,
    onPrimary = md_theme_light_onPrimary,
    primaryContainer = md_theme_light_primaryContainer,
    onPrimaryContainer = md_theme_light_onPrimaryContainer,
    secondary = md_theme_light_secondary,
    onSecondary = md_theme_light_onSecondary,
    secondaryContainer = md_theme_light_secondaryContainer,
    onSecondaryContainer = md_theme_light_onSecondaryContainer,
    tertiary = md_theme_light_tertiary,
    onTertiary = md_theme_light_onTertiary,
    tertiaryContainer = md_theme_light_tertiaryContainer,
    onTertiaryContainer = md_theme_light_onTertiaryContainer,
    error = md_theme_light_error,
    errorContainer = md_theme_light_errorContainer,
    onError = md_theme_light_onError,
    onErrorContainer = md_theme_light_onErrorContainer,
    background = md_theme_light_background,
    onBackground = md_theme_light_onBackground,
    surface = md_theme_light_surface,
    onSurface = md_theme_light_onSurface,
    surfaceVariant = md_theme_light_surfaceVariant,
    onSurfaceVariant = md_theme_light_onSurfaceVariant,
    outline = md_theme_light_outline,
    inverseOnSurface = md_theme_light_inverseOnSurface,
    inverseSurface = md_theme_light_inverseSurface,
    inversePrimary = md_theme_light_inversePrimary,
    surfaceTint = md_theme_light_surfaceTint
)

// Professional Theme Color Schemes
private val ProfessionalLightColorScheme = lightColorScheme(
    primary = professional_light_primary,
    onPrimary = professional_light_onPrimary,
    primaryContainer = professional_light_primaryContainer,
    onPrimaryContainer = professional_light_onPrimaryContainer,
    secondary = professional_light_secondary,
    onSecondary = professional_light_onSecondary,
    secondaryContainer = professional_light_secondaryContainer,
    onSecondaryContainer = professional_light_onSecondaryContainer,
    tertiary = professional_light_tertiary,
    onTertiary = professional_light_onTertiary,
    tertiaryContainer = professional_light_tertiaryContainer,
    onTertiaryContainer = professional_light_onTertiaryContainer,
    error = professional_light_error,
    errorContainer = professional_light_errorContainer,
    onError = professional_light_onError,
    onErrorContainer = professional_light_onErrorContainer,
    background = professional_light_background,
    onBackground = professional_light_onBackground,
    surface = professional_light_surface,
    onSurface = professional_light_onSurface,
    surfaceVariant = professional_light_surfaceVariant,
    onSurfaceVariant = professional_light_onSurfaceVariant,
    outline = professional_light_outline,
    inverseOnSurface = professional_light_inverseOnSurface,
    inverseSurface = professional_light_inverseSurface,
    inversePrimary = professional_light_inversePrimary,
    surfaceTint = professional_light_surfaceTint
)

private val ProfessionalDarkColorScheme = darkColorScheme(
    primary = professional_dark_primary,
    onPrimary = professional_dark_onPrimary,
    primaryContainer = professional_dark_primaryContainer,
    onPrimaryContainer = professional_dark_onPrimaryContainer,
    secondary = professional_dark_secondary,
    onSecondary = professional_dark_onSecondary,
    secondaryContainer = professional_dark_secondaryContainer,
    onSecondaryContainer = professional_dark_onSecondaryContainer,
    tertiary = professional_dark_tertiary,
    onTertiary = professional_dark_onTertiary,
    tertiaryContainer = professional_dark_tertiaryContainer,
    onTertiaryContainer = professional_dark_onTertiaryContainer,
    error = professional_dark_error,
    errorContainer = professional_dark_errorContainer,
    onError = professional_dark_onError,
    onErrorContainer = professional_dark_onErrorContainer,
    background = professional_dark_background,
    onBackground = professional_dark_onBackground,
    surface = professional_dark_surface,
    onSurface = professional_dark_onSurface,
    surfaceVariant = professional_dark_surfaceVariant,
    onSurfaceVariant = professional_dark_onSurfaceVariant,
    outline = professional_dark_outline,
    inverseOnSurface = professional_dark_inverseOnSurface,
    inverseSurface = professional_dark_inverseSurface,
    inversePrimary = professional_dark_inversePrimary,
    surfaceTint = professional_dark_surfaceTint
)

// Premium Theme Color Schemes
private val PremiumLightColorScheme = lightColorScheme(
    primary = premium_light_primary,
    onPrimary = premium_light_onPrimary,
    primaryContainer = premium_light_primaryContainer,
    onPrimaryContainer = premium_light_onPrimaryContainer,
    secondary = premium_light_secondary,
    onSecondary = premium_light_onSecondary,
    secondaryContainer = premium_light_secondaryContainer,
    onSecondaryContainer = premium_light_onSecondaryContainer,
    tertiary = premium_light_tertiary,
    onTertiary = premium_light_onTertiary,
    tertiaryContainer = premium_light_tertiaryContainer,
    onTertiaryContainer = premium_light_onTertiaryContainer,
    error = premium_light_error,
    errorContainer = premium_light_errorContainer,
    onError = premium_light_onError,
    onErrorContainer = premium_light_onErrorContainer,
    background = premium_light_background,
    onBackground = premium_light_onBackground,
    surface = premium_light_surface,
    onSurface = premium_light_onSurface,
    surfaceVariant = premium_light_surfaceVariant,
    onSurfaceVariant = premium_light_onSurfaceVariant,
    outline = premium_light_outline,
    inverseOnSurface = premium_light_inverseOnSurface,
    inverseSurface = premium_light_inverseSurface,
    inversePrimary = premium_light_inversePrimary,
    surfaceTint = premium_light_surfaceTint
)

private val PremiumDarkColorScheme = darkColorScheme(
    primary = premium_dark_primary,
    onPrimary = premium_dark_onPrimary,
    primaryContainer = premium_dark_primaryContainer,
    onPrimaryContainer = premium_dark_onPrimaryContainer,
    secondary = premium_dark_secondary,
    onSecondary = premium_dark_onSecondary,
    secondaryContainer = premium_dark_secondaryContainer,
    onSecondaryContainer = premium_dark_onSecondaryContainer,
    tertiary = premium_dark_tertiary,
    onTertiary = premium_dark_onTertiary,
    tertiaryContainer = premium_dark_tertiaryContainer,
    onTertiaryContainer = premium_dark_onTertiaryContainer,
    error = premium_dark_error,
    errorContainer = premium_dark_errorContainer,
    onError = premium_dark_onError,
    onErrorContainer = premium_dark_onErrorContainer,
    background = premium_dark_background,
    onBackground = premium_dark_onBackground,
    surface = premium_dark_surface,
    onSurface = premium_dark_onSurface,
    surfaceVariant = premium_dark_surfaceVariant,
    onSurfaceVariant = premium_dark_onSurfaceVariant,
    outline = premium_dark_outline,
    inverseOnSurface = premium_dark_inverseOnSurface,
    inverseSurface = premium_dark_inverseSurface,
    inversePrimary = premium_dark_inversePrimary,
    surfaceTint = premium_dark_surfaceTint
)

// High Contrast Theme Color Schemes
private val HighContrastLightColorScheme = lightColorScheme(
    primary = highcontrast_light_primary,
    onPrimary = highcontrast_light_onPrimary,
    primaryContainer = highcontrast_light_primaryContainer,
    onPrimaryContainer = highcontrast_light_onPrimaryContainer,
    secondary = highcontrast_light_secondary,
    onSecondary = highcontrast_light_onSecondary,
    secondaryContainer = highcontrast_light_secondaryContainer,
    onSecondaryContainer = highcontrast_light_onSecondaryContainer,
    tertiary = highcontrast_light_tertiary,
    onTertiary = highcontrast_light_onTertiary,
    tertiaryContainer = highcontrast_light_tertiaryContainer,
    onTertiaryContainer = highcontrast_light_onTertiaryContainer,
    error = highcontrast_light_error,
    errorContainer = highcontrast_light_errorContainer,
    onError = highcontrast_light_onError,
    onErrorContainer = highcontrast_light_onErrorContainer,
    background = highcontrast_light_background,
    onBackground = highcontrast_light_onBackground,
    surface = highcontrast_light_surface,
    onSurface = highcontrast_light_onSurface,
    surfaceVariant = highcontrast_light_surfaceVariant,
    onSurfaceVariant = highcontrast_light_onSurfaceVariant,
    outline = highcontrast_light_outline,
    inverseOnSurface = highcontrast_light_inverseOnSurface,
    inverseSurface = highcontrast_light_inverseSurface,
    inversePrimary = highcontrast_light_inversePrimary,
    surfaceTint = highcontrast_light_surfaceTint
)

private val HighContrastDarkColorScheme = darkColorScheme(
    primary = highcontrast_dark_primary,
    onPrimary = highcontrast_dark_onPrimary,
    primaryContainer = highcontrast_dark_primaryContainer,
    onPrimaryContainer = highcontrast_dark_onPrimaryContainer,
    secondary = highcontrast_dark_secondary,
    onSecondary = highcontrast_dark_onSecondary,
    secondaryContainer = highcontrast_dark_secondaryContainer,
    onSecondaryContainer = highcontrast_dark_onSecondaryContainer,
    tertiary = highcontrast_dark_tertiary,
    onTertiary = highcontrast_dark_onTertiary,
    tertiaryContainer = highcontrast_dark_tertiaryContainer,
    onTertiaryContainer = highcontrast_dark_onTertiaryContainer,
    error = highcontrast_dark_error,
    errorContainer = highcontrast_dark_errorContainer,
    onError = highcontrast_dark_onError,
    onErrorContainer = highcontrast_dark_onErrorContainer,
    background = highcontrast_dark_background,
    onBackground = highcontrast_dark_onBackground,
    surface = highcontrast_dark_surface,
    onSurface = highcontrast_dark_onSurface,
    surfaceVariant = highcontrast_dark_surfaceVariant,
    onSurfaceVariant = highcontrast_dark_onSurfaceVariant,
    outline = highcontrast_dark_outline,
    inverseOnSurface = highcontrast_dark_inverseOnSurface,
    inverseSurface = highcontrast_dark_inverseSurface,
    inversePrimary = highcontrast_dark_inversePrimary,
    surfaceTint = highcontrast_dark_surfaceTint
)

// Theme enumeration
enum class AppTheme {
    DEFAULT,
    PROFESSIONAL,
    PREMIUM,
    HIGH_CONTRAST
}

@Composable
fun GrabTubeTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    appTheme: AppTheme = AppTheme.DEFAULT,
    content: @Composable () -> Unit
) {
    val colorScheme = when (appTheme) {
        AppTheme.DEFAULT -> {
            when {
                dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
                    val context = LocalContext.current
                    if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
                }
                darkTheme -> DarkColorScheme
                else -> LightColorScheme
            }
        }
        AppTheme.PROFESSIONAL -> {
            if (darkTheme) ProfessionalDarkColorScheme else ProfessionalLightColorScheme
        }
        AppTheme.PREMIUM -> {
            if (darkTheme) PremiumDarkColorScheme else PremiumLightColorScheme
        }
        AppTheme.HIGH_CONTRAST -> {
            if (darkTheme) HighContrastDarkColorScheme else HighContrastLightColorScheme
        }
    }

    val typography = when (appTheme) {
        AppTheme.PROFESSIONAL -> ProfessionalTypography
        else -> Typography
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = typography,
        content = content
    )
}
