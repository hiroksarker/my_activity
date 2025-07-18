import 'package:flutter/material.dart';
import 'form_colors.dart';
import 'form_typography.dart';
import 'form_spacing.dart';

/// Form theme configuration that extends the main AppTheme
/// Provides consistent theming for all form components
class FormTheme {
  /// Input decoration theme optimized for forms
  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: FormColors.surface,
      
      // Border styles
      border: OutlineInputBorder(
        borderRadius: FormSpacing.borderRadiusMd,
        borderSide: const BorderSide(
          color: FormColors.border,
          width: 1.0,
        ),
      ),
      
      enabledBorder: OutlineInputBorder(
        borderRadius: FormSpacing.borderRadiusMd,
        borderSide: const BorderSide(
          color: FormColors.border,
          width: 1.0,
        ),
      ),
      
      focusedBorder: OutlineInputBorder(
        borderRadius: FormSpacing.borderRadiusMd,
        borderSide: const BorderSide(
          color: FormColors.borderFocused,
          width: 2.0,
        ),
      ),
      
      errorBorder: OutlineInputBorder(
        borderRadius: FormSpacing.borderRadiusMd,
        borderSide: const BorderSide(
          color: FormColors.borderError,
          width: 1.0,
        ),
      ),
      
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: FormSpacing.borderRadiusMd,
        borderSide: const BorderSide(
          color: FormColors.borderError,
          width: 2.0,
        ),
      ),
      
      disabledBorder: OutlineInputBorder(
        borderRadius: FormSpacing.borderRadiusMd,
        borderSide: const BorderSide(
          color: FormColors.borderDisabled,
          width: 1.0,
        ),
      ),
      
      // Content styling
      contentPadding: FormSpacing.fieldPadding,
      
      // Text styles
      hintStyle: FormTypography.fieldPlaceholder,
      labelStyle: FormTypography.fieldLabel,
      floatingLabelStyle: FormTypography.fieldLabel.copyWith(
        color: FormColors.primary,
        fontSize: 14,
      ),
      
      // Helper and error text
      helperStyle: FormTypography.helperText,
      errorStyle: FormTypography.errorText,
      
      // Icon styling
      prefixIconColor: FormColors.primary,
      suffixIconColor: FormColors.textSecondary,
      
      // Constraints
      constraints: const BoxConstraints(
        minHeight: FormSpacing.fieldHeight,
      ),
    );
  }
  
  /// Elevated button theme for form actions
  static ElevatedButtonThemeData get elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FormColors.primary,
        foregroundColor: FormColors.textOnPrimary,
        
        // Sizing
        minimumSize: const Size(0, FormSpacing.buttonHeight),
        padding: FormSpacing.buttonPadding,
        
        // Shape
        shape: RoundedRectangleBorder(
          borderRadius: FormSpacing.borderRadiusMd,
        ),
        
        // Elevation
        elevation: FormSpacing.elevationSm,
        
        // Text style
        textStyle: FormTypography.buttonPrimary,
        
        // State colors
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return FormColors.interactiveDisabled;
            }
            if (states.contains(MaterialState.pressed)) {
              return FormColors.interactivePressed;
            }
            if (states.contains(MaterialState.hovered)) {
              return FormColors.interactiveHover;
            }
            return FormColors.interactive;
          },
        ),
      ),
    );
  }
  
  /// Outlined button theme for secondary actions
  static OutlinedButtonThemeData get outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FormColors.primary,
        
        // Sizing
        minimumSize: const Size(0, FormSpacing.buttonHeight),
        padding: FormSpacing.buttonPadding,
        
        // Shape
        shape: RoundedRectangleBorder(
          borderRadius: FormSpacing.borderRadiusMd,
        ),
        
        // Border
        side: const BorderSide(
          color: FormColors.primary,
          width: 1.5,
        ),
        
        // Text style
        textStyle: FormTypography.buttonSecondary,
      ).copyWith(
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return FormColors.interactiveDisabled;
            }
            if (states.contains(MaterialState.pressed)) {
              return FormColors.interactivePressed;
            }
            return FormColors.primary;
          },
        ),
        side: MaterialStateProperty.resolveWith<BorderSide>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return const BorderSide(
                color: FormColors.interactiveDisabled,
                width: 1.5,
              );
            }
            return const BorderSide(
              color: FormColors.primary,
              width: 1.5,
            );
          },
        ),
      ),
    );
  }
  
  /// Text button theme for tertiary actions
  static TextButtonThemeData get textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: FormColors.primary,
        
        // Sizing
        minimumSize: const Size(0, FormSpacing.buttonHeightSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: FormSpacing.md,
          vertical: FormSpacing.sm,
        ),
        
        // Shape
        shape: RoundedRectangleBorder(
          borderRadius: FormSpacing.borderRadiusSm,
        ),
        
        // Text style
        textStyle: FormTypography.buttonText,
      ),
    );
  }
  
  /// Chip theme for selection components
  static ChipThemeData get chipTheme {
    return ChipThemeData(
      backgroundColor: FormColors.surfaceVariant,
      selectedColor: FormColors.primary,
      disabledColor: FormColors.borderDisabled,
      
      // Text styles
      labelStyle: FormTypography.chipUnselected,
      secondaryLabelStyle: FormTypography.chipSelected,
      
      // Sizing
      padding: const EdgeInsets.symmetric(
        horizontal: FormSpacing.md,
        vertical: FormSpacing.sm,
      ),
      
      // Shape
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FormSpacing.chipHeight / 2),
      ),
      
      // Elevation
      elevation: 0,
      pressElevation: FormSpacing.elevationSm,
      
      // Colors
      checkmarkColor: FormColors.textOnPrimary,
      deleteIconColor: FormColors.textSecondary,
      
      // Brightness
      brightness: Brightness.light,
    );
  }
  
  /// Card theme for form sections
  static CardThemeData get cardTheme {
    return CardThemeData(
      color: FormColors.surface,
      elevation: FormSpacing.elevationSm,
      shadowColor: FormColors.shadow,
      
      shape: RoundedRectangleBorder(
        borderRadius: FormSpacing.borderRadiusLg,
      ),
      
      margin: const EdgeInsets.symmetric(
        horizontal: FormSpacing.xs,
        vertical: FormSpacing.xs,
      ),
    );
  }
  
  /// Dialog theme for form modals
  static DialogThemeData get dialogTheme {
    return DialogThemeData(
      backgroundColor: FormColors.surface,
      elevation: FormSpacing.elevationXl,
      shadowColor: FormColors.shadowMedium,
      
      shape: RoundedRectangleBorder(
        borderRadius: FormSpacing.borderRadiusLg,
      ),
      
      titleTextStyle: FormTypography.subtitle,
      contentTextStyle: FormTypography.fieldInput,
      
      insetPadding: FormSpacing.paddingMd,
    );
  }
  
  /// Bottom sheet theme for mobile selections
  static BottomSheetThemeData get bottomSheetTheme {
    return BottomSheetThemeData(
      backgroundColor: FormColors.surface,
      elevation: FormSpacing.elevationXl,
      
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(FormSpacing.radiusLg),
        ),
      ),
      
      constraints: const BoxConstraints(
        maxWidth: FormSpacing.maxFormWidth,
      ),
    );
  }
  
  /// Snack bar theme for form feedback
  static SnackBarThemeData get snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: FormColors.textPrimary,
      contentTextStyle: FormTypography.fieldInput.copyWith(
        color: FormColors.textOnPrimary,
      ),
      
      shape: RoundedRectangleBorder(
        borderRadius: FormSpacing.borderRadiusMd,
      ),
      
      behavior: SnackBarBehavior.floating,
      elevation: FormSpacing.elevationLg,
    );
  }
  
  /// Create a complete theme data with form theming
  static ThemeData createFormTheme({
    required ThemeData baseTheme,
    bool isDark = false,
  }) {
    return baseTheme.copyWith(
      inputDecorationTheme: inputDecorationTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      textButtonTheme: textButtonTheme,
      chipTheme: chipTheme,
      cardTheme: cardTheme,
      dialogTheme: dialogTheme,
      bottomSheetTheme: bottomSheetTheme,
      snackBarTheme: snackBarTheme,
    );
  }
  
  /// Dark theme variants
  static InputDecorationTheme get darkInputDecorationTheme {
    return inputDecorationTheme.copyWith(
      fillColor: FormColors.darkSurface,
      
      border: OutlineInputBorder(
        borderRadius: FormSpacing.borderRadiusMd,
        borderSide: const BorderSide(
          color: FormColors.darkBorder,
          width: 1.0,
        ),
      ),
      
      enabledBorder: OutlineInputBorder(
        borderRadius: FormSpacing.borderRadiusMd,
        borderSide: const BorderSide(
          color: FormColors.darkBorder,
          width: 1.0,
        ),
      ),
      
      hintStyle: FormTypography.fieldPlaceholder.copyWith(
        color: FormColors.darkTextSecondary,
      ),
      
      labelStyle: FormTypography.fieldLabel.copyWith(
        color: FormColors.darkTextSecondary,
      ),
    );
  }
  
  /// Get appropriate theme based on brightness
  static InputDecorationTheme getInputDecorationTheme(Brightness brightness) {
    return brightness == Brightness.dark 
        ? darkInputDecorationTheme 
        : inputDecorationTheme;
  }
}