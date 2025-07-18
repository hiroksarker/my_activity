import 'package:flutter/material.dart';
import 'form_colors.dart';
import 'form_typography.dart';
import 'form_spacing.dart';

/// Modern dropdown with consistent styling and proper spacing
class ModernDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final bool enabled;
  final bool required;
  final String? errorText;
  final String? helperText;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const ModernDropdown({
    super.key,
    this.value,
    required this.items,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.helperText,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          _buildLabel(context),
          FormSpacing.gapXs,
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled ? FormColors.getSurface(context) : FormColors.surfaceVariant,
            borderRadius: FormSpacing.borderRadiusMd,
            border: Border.all(
              color: hasError 
                  ? FormColors.borderError 
                  : FormColors.getBorder(context),
              width: 1.0,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: enabled ? onChanged : null,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: prefixIcon != null
                  ? Container(
                      margin: const EdgeInsets.only(
                        left: FormSpacing.md,
                        right: FormSpacing.sm,
                      ),
                      child: Icon(
                        prefixIcon,
                        size: FormSpacing.iconSize,
                        color: hasError 
                            ? FormColors.error 
                            : FormColors.primary,
                      ),
                    )
                  : null,
              prefixIconConstraints: prefixIcon != null
                  ? const BoxConstraints(
                      minWidth: FormSpacing.iconSize + FormSpacing.md + FormSpacing.sm,
                      minHeight: FormSpacing.iconSize,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: prefixIcon != null ? FormSpacing.sm : FormSpacing.md,
                vertical: FormSpacing.md,
              ),
              hintStyle: FormTypography.fieldPlaceholder.copyWith(
                color: FormColors.getTextSecondary(context).withOpacity(0.7),
              ),
              errorText: null, // We handle this separately
            ),
            style: FormTypography.getFieldInput(context),
            dropdownColor: FormColors.getSurface(context),
            icon: Icon(
              Icons.arrow_drop_down,
              color: enabled 
                  ? FormColors.getTextSecondary(context) 
                  : FormColors.getTextSecondary(context).withOpacity(0.5),
            ),
          ),
        ),
        if (helperText != null || errorText != null) ...[
          FormSpacing.gapXs,
          _buildHelperText(context),
        ],
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label!,
        style: FormTypography.getFieldLabel(context),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: FormTypography.getFieldLabel(context).copyWith(
                color: FormColors.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelperText(BuildContext context) {
    final text = errorText ?? helperText;
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        left: prefixIcon != null ? FormSpacing.xl : FormSpacing.md,
      ),
      child: Text(
        text,
        style: errorText != null
            ? FormTypography.errorText
            : FormTypography.helperText.copyWith(
                color: FormColors.getTextSecondary(context),
              ),
      ),
    );
  }
}

/// Modern chip selector for multiple choice options
class ModernChipSelector<T> extends StatelessWidget {
  final T? selectedValue;
  final List<ChipOption<T>> options;
  final String? label;
  final bool required;
  final void Function(T?)? onSelectionChanged;
  final bool multiSelect;
  final List<T>? selectedValues;
  final void Function(List<T>)? onMultiSelectionChanged;

  const ModernChipSelector({
    super.key,
    this.selectedValue,
    required this.options,
    this.label,
    this.required = false,
    this.onSelectionChanged,
    this.multiSelect = false,
    this.selectedValues,
    this.onMultiSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          _buildLabel(context),
          FormSpacing.gapSm,
        ],
        Wrap(
          spacing: FormSpacing.sm,
          runSpacing: FormSpacing.sm,
          children: options.map((option) {
            final isSelected = multiSelect
                ? selectedValues?.contains(option.value) ?? false
                : selectedValue == option.value;

            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      size: FormSpacing.iconSizeSmall,
                      color: isSelected 
                          ? FormColors.textOnPrimary 
                          : option.color ?? FormColors.primary,
                    ),
                    FormSpacing.gapHorizontalXs,
                  ],
                  Text(option.label),
                ],
              ),
              selected: isSelected,
              selectedColor: option.color ?? FormColors.primary,
              backgroundColor: (option.color ?? FormColors.primary).withOpacity(0.1),
              onSelected: (selected) {
                if (multiSelect) {
                  final currentValues = List<T>.from(selectedValues ?? []);
                  if (selected) {
                    currentValues.add(option.value);
                  } else {
                    currentValues.remove(option.value);
                  }
                  onMultiSelectionChanged?.call(currentValues);
                } else {
                  onSelectionChanged?.call(selected ? option.value : null);
                }
              },
              labelStyle: TextStyle(
                color: isSelected 
                    ? FormColors.textOnPrimary 
                    : FormColors.getTextPrimary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: FormSpacing.md,
                vertical: FormSpacing.sm,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label!,
        style: FormTypography.getFieldLabel(context),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: FormTypography.getFieldLabel(context).copyWith(
                color: FormColors.error,
              ),
            ),
        ],
      ),
    );
  }
}

/// Option for chip selector
class ChipOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? color;

  const ChipOption({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });
}