import 'package:flutter/material.dart';

/// Form-specific color palette that extends the main AppTheme
/// Provides consistent, accessible colors for all form components
class FormColors {
  // Primary colors - consistent with AppTheme
  static const Color primary = Color(0xFF0066CC);      // Blue 600
  static const Color primaryLight = Color(0xFF3385FF);  // Blue 500
  static const Color primaryDark = Color(0xFF004499);   // Blue 700
  
  // Surface colors - optimized for form backgrounds
  static const Color surface = Color(0xFFFFFFFF);       // White
  static const Color surfaceVariant = Color(0xFFF8FAFC); // Slate 50
  static const Color background = Color(0xFFF1F5F9);    // Slate 100
  static const Color surfaceElevated = Color(0xFFFFFFFF); // White with elevation
  
  // Text colors - high contrast for accessibility
  static const Color textPrimary = Color(0xFF1E293B);   // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8);  // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White
  static const Color textDisabled = Color(0xFFCBD5E1);  // Slate 300
  
  // State colors - clear visual feedback
  static const Color success = Color(0xFF059669);       // Emerald 600
  static const Color successLight = Color(0xFFD1FAE5);  // Emerald 100
  static const Color error = Color(0xFFDC2626);         // Red 600
  static const Color errorLight = Color(0xFFFEE2E2);    // Red 100
  static const Color warning = Color(0xFFD97706);       // Amber 600
  static const Color warningLight = Color(0xFFFEF3C7);  // Amber 100
  static const Color info = Color(0xFF2563EB);          // Blue 600
  static const Color infoLight = Color(0xFFDBEAFE);     // Blue 100
  
  // Border colors - subtle but clear boundaries
  static const Color border = Color(0xFFE2E8F0);        // Slate 200
  static const Color borderFocused = Color(0xFF0066CC); // Primary blue
  static const Color borderError = Color(0xFFDC2626);   // Red 600
  static const Color borderSuccess = Color(0xFF059669); // Emerald 600
  static const Color borderDisabled = Color(0xFFF1F5F9); // Slate 100
  
  // Interactive colors - for buttons and actions
  static const Color interactive = Color(0xFF0066CC);   // Primary blue
  static const Color interactiveHover = Color(0xFF004499); // Primary dark
  static const Color interactivePressed = Color(0xFF003366); // Darker blue
  static const Color interactiveDisabled = Color(0xFF94A3B8); // Slate 400
  
  // Shadow colors - subtle depth
  static const Color shadow = Color(0x0A000000);        // 4% black
  static const Color shadowMedium = Color(0x14000000);  // 8% black
  static const Color shadowStrong = Color(0x1F000000);  // 12% black
  
  // Overlay colors - for modals and loading states
  static const Color overlay = Color(0x80000000);       // 50% black
  static const Color overlayLight = Color(0x40000000);  // 25% black
  
  // Category colors - for visual categorization
  static const Color categoryBlue = Color(0xFF0066CC);
  static const Color categoryGreen = Color(0xFF059669);
  static const Color categoryOrange = Color(0xFFD97706);
  static const Color categoryPurple = Color(0xFF7C3AED);
  static const Color categoryRed = Color(0xFFDC2626);
  static const Color categoryTeal = Color(0xFF0891B2);
  static const Color categoryPink = Color(0xFFDB2777);
  static const Color categoryIndigo = Color(0xFF4F46E5);
  
  // Dark theme colors
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkBorder = Color(0xFF475569);
  
  /// Get color based on current theme brightness
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextPrimary 
        : textPrimary;
  }
  
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextSecondary 
        : textSecondary;
  }
  
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSurface 
        : surface;
  }
  
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBackground 
        : background;
  }
  
  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBorder 
        : border;
  }
  
  /// Accessibility-compliant color combinations
  static const Map<String, List<Color>> accessibleCombinations = {
    'primaryOnSurface': [primary, surface],
    'textOnSurface': [textPrimary, surface],
    'errorOnSurface': [error, surface],
    'successOnSurface': [success, surface],
    'warningOnSurface': [warning, surface],
  };
  
  /// Get category color by index
  static Color getCategoryColor(int index) {
    const colors = [
      categoryBlue,
      categoryGreen,
      categoryOrange,
      categoryPurple,
      categoryRed,
      categoryTeal,
      categoryPink,
      categoryIndigo,
    ];
    return colors[index % colors.length];
  }
  
  /// Get light version of a color for backgrounds
  static Color getLightVersion(Color color) {
    if (color == success) return successLight;
    if (color == error) return errorLight;
    if (color == warning) return warningLight;
    if (color == info) return infoLight;
    return color.withOpacity(0.1);
  }
}