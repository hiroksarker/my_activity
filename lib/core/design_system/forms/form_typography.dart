import 'package:flutter/material.dart';
import 'form_colors.dart';

/// Typography system specifically designed for forms
/// Provides consistent text styles with proper hierarchy and accessibility
class FormTypography {
  // Form titles and headers
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: FormColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: FormColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  // Section headers within forms
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: FormColors.primary,
    height: 1.3,
    letterSpacing: 0,
  );
  
  static const TextStyle sectionSubheader = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: FormColors.textSecondary,
    height: 1.4,
    letterSpacing: 0,
  );
  
  // Field labels and inputs
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: FormColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.15,
  );
  
  static const TextStyle fieldLabelRequired = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: FormColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.15,
  );
  
  static const TextStyle fieldInput = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: FormColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.15,
  );
  
  static const TextStyle fieldInputLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: FormColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.15,
  );
  
  static const TextStyle fieldPlaceholder = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: FormColors.textTertiary,
    height: 1.5,
    letterSpacing: 0.15,
  );
  
  // Helper and validation text
  static const TextStyle helperText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: FormColors.textTertiary,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: FormColors.error,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  static const TextStyle successText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: FormColors.success,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  static const TextStyle warningText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: FormColors.warning,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  // Button text styles
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: FormColors.textOnPrimary,
    height: 1.25,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: FormColors.primary,
    height: 1.25,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: FormColors.primary,
    height: 1.25,
    letterSpacing: 0.25,
  );
  
  // Chip and tag text
  static const TextStyle chipSelected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: FormColors.textOnPrimary,
    height: 1.25,
    letterSpacing: 0.25,
  );
  
  static const TextStyle chipUnselected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: FormColors.textPrimary,
    height: 1.25,
    letterSpacing: 0.25,
  );
  
  // List and dropdown text
  static const TextStyle listItem = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: FormColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.15,
  );
  
  static const TextStyle listItemSelected = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: FormColors.primary,
    height: 1.4,
    letterSpacing: 0.15,
  );
  
  static const TextStyle dropdownItem = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: FormColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.15,
  );
  
  // Caption and metadata text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: FormColors.textTertiary,
    height: 1.4,
    letterSpacing: 0.4,
  );
  
  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: FormColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.4,
  );
  
  // Dark theme variants
  static TextStyle titleDark = title.copyWith(color: FormColors.darkTextPrimary);
  static TextStyle sectionHeaderDark = sectionHeader.copyWith(color: FormColors.primaryLight);
  static TextStyle fieldLabelDark = fieldLabel.copyWith(color: FormColors.darkTextSecondary);
  static TextStyle fieldInputDark = fieldInput.copyWith(color: FormColors.darkTextPrimary);
  
  /// Get text style based on current theme
  static TextStyle getTitle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? titleDark : title;
  }
  
  static TextStyle getSectionHeader(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? sectionHeaderDark : sectionHeader;
  }
  
  static TextStyle getFieldLabel(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? fieldLabelDark : fieldLabel;
  }
  
  static TextStyle getFieldInput(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? fieldInputDark : fieldInput;
  }
  
  /// Create text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Create text style with custom size
  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }
  
  /// Create text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight fontWeight) {
    return style.copyWith(fontWeight: fontWeight);
  }
  
  /// Accessibility helpers
  static TextStyle getAccessibleStyle(TextStyle baseStyle, {
    required bool isLargeText,
    required bool isHighContrast,
  }) {
    TextStyle style = baseStyle;
    
    if (isLargeText) {
      style = style.copyWith(fontSize: (style.fontSize ?? 16) * 1.2);
    }
    
    if (isHighContrast) {
      // Increase contrast for accessibility
      if (style.color == FormColors.textSecondary) {
        style = style.copyWith(color: FormColors.textPrimary);
      } else if (style.color == FormColors.textTertiary) {
        style = style.copyWith(color: FormColors.textSecondary);
      }
    }
    
    return style;
  }
}