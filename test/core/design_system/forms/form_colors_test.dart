import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_activity/core/design_system/forms/form_colors.dart';

void main() {
  group('FormColors', () {
    testWidgets('should provide consistent primary colors', (tester) async {
      expect(FormColors.primary, const Color(0xFF0066CC));
      expect(FormColors.primaryLight, const Color(0xFF3385FF));
      expect(FormColors.primaryDark, const Color(0xFF004499));
    });
    
    testWidgets('should provide accessible text colors', (tester) async {
      expect(FormColors.textPrimary, const Color(0xFF1E293B));
      expect(FormColors.textSecondary, const Color(0xFF64748B));
      expect(FormColors.textTertiary, const Color(0xFF94A3B8));
      expect(FormColors.textOnPrimary, const Color(0xFFFFFFFF));
    });
    
    testWidgets('should provide distinct state colors', (tester) async {
      expect(FormColors.success, const Color(0xFF059669));
      expect(FormColors.error, const Color(0xFFDC2626));
      expect(FormColors.warning, const Color(0xFFD97706));
      expect(FormColors.info, const Color(0xFF2563EB));
    });
    
    testWidgets('should provide proper border colors', (tester) async {
      expect(FormColors.border, const Color(0xFFE2E8F0));
      expect(FormColors.borderFocused, const Color(0xFF0066CC));
      expect(FormColors.borderError, const Color(0xFFDC2626));
      expect(FormColors.borderSuccess, const Color(0xFF059669));
    });
    
    testWidgets('should return correct colors for light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              expect(FormColors.getTextPrimary(context), FormColors.textPrimary);
              expect(FormColors.getSurface(context), FormColors.surface);
              expect(FormColors.getBackground(context), FormColors.background);
              expect(FormColors.getBorder(context), FormColors.border);
              return const SizedBox();
            },
          ),
        ),
      );
    });
    
    testWidgets('should return correct colors for dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              expect(FormColors.getTextPrimary(context), FormColors.darkTextPrimary);
              expect(FormColors.getSurface(context), FormColors.darkSurface);
              expect(FormColors.getBackground(context), FormColors.darkBackground);
              expect(FormColors.getBorder(context), FormColors.darkBorder);
              return const SizedBox();
            },
          ),
        ),
      );
    });
    
    test('should provide category colors', () {
      expect(FormColors.getCategoryColor(0), FormColors.categoryBlue);
      expect(FormColors.getCategoryColor(1), FormColors.categoryGreen);
      expect(FormColors.getCategoryColor(8), FormColors.categoryBlue); // Wraps around
    });
    
    test('should provide light versions of colors', () {
      expect(FormColors.getLightVersion(FormColors.success), FormColors.successLight);
      expect(FormColors.getLightVersion(FormColors.error), FormColors.errorLight);
      expect(FormColors.getLightVersion(FormColors.warning), FormColors.warningLight);
      expect(FormColors.getLightVersion(FormColors.info), FormColors.infoLight);
    });
    
    test('should have accessible color combinations', () {
      expect(FormColors.accessibleCombinations.isNotEmpty, true);
      expect(FormColors.accessibleCombinations.containsKey('primaryOnSurface'), true);
      expect(FormColors.accessibleCombinations.containsKey('textOnSurface'), true);
      expect(FormColors.accessibleCombinations.containsKey('errorOnSurface'), true);
    });
  });
}