import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_activity/core/design_system/forms/form_typography.dart';
import 'package:my_activity/core/design_system/forms/form_colors.dart';

void main() {
  group('FormTypography', () {
    test('should provide consistent title styles', () {
      expect(FormTypography.title.fontSize, 24);
      expect(FormTypography.title.fontWeight, FontWeight.w600);
      expect(FormTypography.title.color, FormColors.textPrimary);
      
      expect(FormTypography.subtitle.fontSize, 20);
      expect(FormTypography.subtitle.fontWeight, FontWeight.w600);
    });
    
    test('should provide section header styles', () {
      expect(FormTypography.sectionHeader.fontSize, 18);
      expect(FormTypography.sectionHeader.fontWeight, FontWeight.w600);
      expect(FormTypography.sectionHeader.color, FormColors.primary);
      
      expect(FormTypography.sectionSubheader.fontSize, 16);
      expect(FormTypography.sectionSubheader.color, FormColors.textSecondary);
    });
    
    test('should provide field styles', () {
      expect(FormTypography.fieldLabel.fontSize, 16);
      expect(FormTypography.fieldLabel.fontWeight, FontWeight.w500);
      expect(FormTypography.fieldLabel.color, FormColors.textSecondary);
      
      expect(FormTypography.fieldInput.fontSize, 16);
      expect(FormTypography.fieldInput.fontWeight, FontWeight.w400);
      expect(FormTypography.fieldInput.color, FormColors.textPrimary);
      
      expect(FormTypography.fieldPlaceholder.color, FormColors.textTertiary);
    });
    
    test('should provide validation text styles', () {
      expect(FormTypography.errorText.fontSize, 14);
      expect(FormTypography.errorText.fontWeight, FontWeight.w500);
      expect(FormTypography.errorText.color, FormColors.error);
      
      expect(FormTypography.successText.color, FormColors.success);
      expect(FormTypography.warningText.color, FormColors.warning);
      expect(FormTypography.helperText.color, FormColors.textTertiary);
    });
    
    test('should provide button text styles', () {
      expect(FormTypography.buttonPrimary.fontSize, 16);
      expect(FormTypography.buttonPrimary.fontWeight, FontWeight.w600);
      expect(FormTypography.buttonPrimary.color, FormColors.textOnPrimary);
      
      expect(FormTypography.buttonSecondary.color, FormColors.primary);
      expect(FormTypography.buttonText.fontSize, 14);
    });
    
    test('should provide chip text styles', () {
      expect(FormTypography.chipSelected.fontWeight, FontWeight.w600);
      expect(FormTypography.chipSelected.color, FormColors.textOnPrimary);
      
      expect(FormTypography.chipUnselected.fontWeight, FontWeight.w500);
      expect(FormTypography.chipUnselected.color, FormColors.textPrimary);
    });
    
    testWidgets('should return correct styles for light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final titleStyle = FormTypography.getTitle(context);
              final sectionStyle = FormTypography.getSectionHeader(context);
              final labelStyle = FormTypography.getFieldLabel(context);
              final inputStyle = FormTypography.getFieldInput(context);
              
              expect(titleStyle.color, FormColors.textPrimary);
              expect(sectionStyle.color, FormColors.primary);
              expect(labelStyle.color, FormColors.textSecondary);
              expect(inputStyle.color, FormColors.textPrimary);
              
              return const SizedBox();
            },
          ),
        ),
      );
    });
    
    testWidgets('should return correct styles for dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              final titleStyle = FormTypography.getTitle(context);
              final sectionStyle = FormTypography.getSectionHeader(context);
              final labelStyle = FormTypography.getFieldLabel(context);
              final inputStyle = FormTypography.getFieldInput(context);
              
              expect(titleStyle.color, FormColors.darkTextPrimary);
              expect(sectionStyle.color, FormColors.primaryLight);
              expect(labelStyle.color, FormColors.darkTextSecondary);
              expect(inputStyle.color, FormColors.darkTextPrimary);
              
              return const SizedBox();
            },
          ),
        ),
      );
    });
    
    test('should create styles with custom properties', () {
      const baseStyle = FormTypography.fieldInput;
      const customColor = Colors.red;
      const customSize = 20.0;
      const customWeight = FontWeight.bold;
      
      final colorStyle = FormTypography.withColor(baseStyle, customColor);
      expect(colorStyle.color, customColor);
      expect(colorStyle.fontSize, baseStyle.fontSize);
      
      final sizeStyle = FormTypography.withSize(baseStyle, customSize);
      expect(sizeStyle.fontSize, customSize);
      expect(sizeStyle.color, baseStyle.color);
      
      final weightStyle = FormTypography.withWeight(baseStyle, customWeight);
      expect(weightStyle.fontWeight, customWeight);
      expect(weightStyle.fontSize, baseStyle.fontSize);
    });
    
    test('should create accessible styles', () {
      const baseStyle = FormTypography.fieldInput;
      
      final largeStyle = FormTypography.getAccessibleStyle(
        baseStyle,
        isLargeText: true,
        isHighContrast: false,
      );
      expect(largeStyle.fontSize, (baseStyle.fontSize! * 1.2));
      
      final contrastStyle = FormTypography.getAccessibleStyle(
        FormTypography.fieldLabel,
        isLargeText: false,
        isHighContrast: true,
      );
      // Should upgrade secondary text to primary for better contrast
      expect(contrastStyle.color, FormColors.textPrimary);
    });
  });
}