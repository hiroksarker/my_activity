import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_activity/core/design_system/forms/form_spacing.dart';

void main() {
  group('FormSpacing', () {
    test('should provide consistent spacing scale', () {
      expect(FormSpacing.unit, 8.0);
      expect(FormSpacing.xs, 4.0);
      expect(FormSpacing.sm, 8.0);
      expect(FormSpacing.md, 16.0);
      expect(FormSpacing.lg, 24.0);
      expect(FormSpacing.xl, 32.0);
      expect(FormSpacing.xxl, 48.0);
      expect(FormSpacing.xxxl, 64.0);
    });
    
    test('should provide form-specific spacing', () {
      expect(FormSpacing.fieldSpacing, FormSpacing.md);
      expect(FormSpacing.sectionSpacing, FormSpacing.lg);
      expect(FormSpacing.majorSectionSpacing, FormSpacing.xl);
      expect(FormSpacing.contentPadding, FormSpacing.md);
      expect(FormSpacing.screenPadding, FormSpacing.md);
    });
    
    test('should provide component dimensions', () {
      expect(FormSpacing.buttonHeight, 56.0);
      expect(FormSpacing.buttonHeightSmall, 40.0);
      expect(FormSpacing.fieldHeight, 56.0);
      expect(FormSpacing.fieldHeightSmall, 40.0);
      expect(FormSpacing.chipHeight, 32.0);
      expect(FormSpacing.iconSize, 24.0);
      expect(FormSpacing.minTouchTarget, 44.0);
    });
    
    test('should provide border radius values', () {
      expect(FormSpacing.radiusXs, 4.0);
      expect(FormSpacing.radiusSm, 8.0);
      expect(FormSpacing.radiusMd, 12.0);
      expect(FormSpacing.radiusLg, 16.0);
      expect(FormSpacing.radiusXl, 20.0);
      expect(FormSpacing.radiusRound, 999.0);
    });
    
    test('should provide elevation values', () {
      expect(FormSpacing.elevationNone, 0.0);
      expect(FormSpacing.elevationSm, 1.0);
      expect(FormSpacing.elevationMd, 2.0);
      expect(FormSpacing.elevationLg, 4.0);
      expect(FormSpacing.elevationXl, 8.0);
    });
    
    test('should provide animation durations', () {
      expect(FormSpacing.animationFast, 150);
      expect(FormSpacing.animationNormal, 250);
      expect(FormSpacing.animationSlow, 350);
    });
    
    test('should provide responsive breakpoints', () {
      expect(FormSpacing.mobileBreakpoint, 768.0);
      expect(FormSpacing.tabletBreakpoint, 1024.0);
      expect(FormSpacing.desktopBreakpoint, 1440.0);
      expect(FormSpacing.maxFormWidth, 600.0);
    });
    
    test('should provide EdgeInsets shortcuts', () {
      expect(FormSpacing.paddingXs, const EdgeInsets.all(FormSpacing.xs));
      expect(FormSpacing.paddingSm, const EdgeInsets.all(FormSpacing.sm));
      expect(FormSpacing.paddingMd, const EdgeInsets.all(FormSpacing.md));
      
      expect(FormSpacing.paddingHorizontalMd, 
             const EdgeInsets.symmetric(horizontal: FormSpacing.md));
      expect(FormSpacing.paddingVerticalMd, 
             const EdgeInsets.symmetric(vertical: FormSpacing.md));
    });
    
    test('should provide SizedBox shortcuts', () {
      expect(FormSpacing.gapXs.height, FormSpacing.xs);
      expect(FormSpacing.gapSm.height, FormSpacing.sm);
      expect(FormSpacing.gapMd.height, FormSpacing.md);
      
      expect(FormSpacing.gapHorizontalMd.width, FormSpacing.md);
    });
    
    test('should provide BorderRadius shortcuts', () {
      expect(FormSpacing.borderRadiusXs, 
             const BorderRadius.all(Radius.circular(FormSpacing.radiusXs)));
      expect(FormSpacing.borderRadiusMd, 
             const BorderRadius.all(Radius.circular(FormSpacing.radiusMd)));
    });
    
    testWidgets('should detect mobile screen size', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(FormSpacing.isMobile(context), true);
              expect(FormSpacing.isTablet(context), false);
              expect(FormSpacing.isDesktop(context), false);
              return const SizedBox();
            },
          ),
        ),
      );
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('should detect tablet screen size', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(900, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(FormSpacing.isMobile(context), false);
              expect(FormSpacing.isTablet(context), true);
              expect(FormSpacing.isDesktop(context), false);
              return const SizedBox();
            },
          ),
        ),
      );
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('should detect desktop screen size', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1600, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(FormSpacing.isMobile(context), false);
              expect(FormSpacing.isTablet(context), false);
              expect(FormSpacing.isDesktop(context), true);
              return const SizedBox();
            },
          ),
        ),
      );
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('should provide responsive spacing', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final spacing = FormSpacing.getResponsiveSpacing(
                context,
                mobile: 16.0,
                tablet: 24.0,
                desktop: 32.0,
              );
              expect(spacing, 16.0); // Should return mobile value
              return const SizedBox();
            },
          ),
        ),
      );
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    testWidgets('should calculate form width correctly', (tester) async {
      // Test narrow screen
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final formWidth = FormSpacing.getFormWidth(context);
              expect(formWidth, 400 - (FormSpacing.screenPadding * 2));
              return const SizedBox();
            },
          ),
        ),
      );
      
      // Test wide screen
      tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final formWidth = FormSpacing.getFormWidth(context);
              expect(formWidth, FormSpacing.maxFormWidth);
              return const SizedBox();
            },
          ),
        ),
      );
      
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });
    
    test('should provide animation duration helpers', () {
      expect(FormSpacing.fastAnimation, 
             const Duration(milliseconds: FormSpacing.animationFast));
      expect(FormSpacing.normalAnimation, 
             const Duration(milliseconds: FormSpacing.animationNormal));
      expect(FormSpacing.slowAnimation, 
             const Duration(milliseconds: FormSpacing.animationSlow));
    });
  });
}