import 'package:flutter/material.dart';

/// Consistent spacing system for forms
/// Based on 8px grid system for perfect alignment and visual rhythm
class FormSpacing {
  // Base spacing unit (8px) - all spacing should be multiples of this
  static const double unit = 8.0;
  
  // Spacing scale - consistent increments
  static const double xs = unit * 0.5;  // 4px - minimal spacing
  static const double sm = unit * 1;    // 8px - tight spacing
  static const double md = unit * 2;    // 16px - standard spacing
  static const double lg = unit * 3;    // 24px - loose spacing
  static const double xl = unit * 4;    // 32px - section spacing
  static const double xxl = unit * 6;   // 48px - major section spacing
  static const double xxxl = unit * 8;  // 64px - page spacing
  
  // Form-specific spacing constants
  static const double fieldSpacing = md;        // 16px - between form fields
  static const double sectionSpacing = lg;     // 24px - between form sections
  static const double majorSectionSpacing = xl; // 32px - between major sections
  static const double contentPadding = md;     // 16px - content padding
  static const double screenPadding = md;      // 16px - screen edge padding
  static const double cardPadding = md;        // 16px - card internal padding
  
  // Component-specific spacing
  static const double buttonSpacing = md;      // 16px - between buttons
  static const double chipSpacing = sm;        // 8px - between chips
  static const double iconSpacing = sm;        // 8px - icon to text spacing
  static const double labelSpacing = xs;       // 4px - label to field spacing
  static const double helperSpacing = xs;      // 4px - field to helper text
  
  // Layout dimensions
  static const double buttonHeight = 56.0;     // Standard button height
  static const double buttonHeightSmall = 40.0; // Small button height
  static const double fieldHeight = 56.0;      // Standard field height
  static const double fieldHeightSmall = 40.0; // Small field height
  static const double chipHeight = 32.0;       // Standard chip height
  static const double iconSize = 24.0;         // Standard icon size
  static const double iconSizeSmall = 20.0;    // Small icon size
  static const double iconSizeLarge = 32.0;    // Large icon size
  
  // Border radius values
  static const double radiusXs = 4.0;          // Minimal radius
  static const double radiusSm = 8.0;          // Small radius
  static const double radiusMd = 12.0;         // Standard radius
  static const double radiusLg = 16.0;         // Large radius
  static const double radiusXl = 20.0;         // Extra large radius
  static const double radiusRound = 999.0;     // Fully rounded
  
  // Shadow and elevation
  static const double elevationNone = 0.0;
  static const double elevationSm = 1.0;
  static const double elevationMd = 2.0;
  static const double elevationLg = 4.0;
  static const double elevationXl = 8.0;
  
  // Animation durations (in milliseconds)
  static const int animationFast = 150;
  static const int animationNormal = 250;
  static const int animationSlow = 350;
  
  // Responsive breakpoints
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
  
  // Form layout constraints
  static const double maxFormWidth = 600.0;    // Maximum form width on large screens
  static const double minTouchTarget = 44.0;   // Minimum touch target size
  
  /// EdgeInsets shortcuts for common spacing patterns
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);
  
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);
  
  // Form-specific padding shortcuts
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
  
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );
  
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: screenPadding,
  );
  
  /// SizedBox shortcuts for common spacing
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl);
  
  static const SizedBox gapHorizontalXs = SizedBox(width: xs);
  static const SizedBox gapHorizontalSm = SizedBox(width: sm);
  static const SizedBox gapHorizontalMd = SizedBox(width: md);
  static const SizedBox gapHorizontalLg = SizedBox(width: lg);
  static const SizedBox gapHorizontalXl = SizedBox(width: xl);
  
  /// BorderRadius shortcuts
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  
  /// Responsive spacing helpers
  static double getResponsiveSpacing(BuildContext context, {
    double mobile = md,
    double tablet = lg,
    double desktop = xl,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= desktopBreakpoint) {
      return desktop;
    } else if (screenWidth >= tabletBreakpoint) {
      return tablet;
    } else {
      return mobile;
    }
  }
  
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets mobile = paddingMd,
    EdgeInsets tablet = paddingLg,
    EdgeInsets desktop = paddingXl,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= desktopBreakpoint) {
      return desktop;
    } else if (screenWidth >= tabletBreakpoint) {
      return tablet;
    } else {
      return mobile;
    }
  }
  
  /// Form layout helpers
  static double getFormWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > maxFormWidth + (screenPadding * 2)) {
      return maxFormWidth;
    }
    return screenWidth - (screenPadding * 2);
  }
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  /// Animation duration helpers
  static Duration get fastAnimation => const Duration(milliseconds: animationFast);
  static Duration get normalAnimation => const Duration(milliseconds: animationNormal);
  static Duration get slowAnimation => const Duration(milliseconds: animationSlow);
}