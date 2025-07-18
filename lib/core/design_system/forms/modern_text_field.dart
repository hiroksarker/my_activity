import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'form_colors.dart';
import 'form_typography.dart';
import 'form_spacing.dart';

/// Modern text field with consistent styling and proper spacing
/// Fixes input field alignment and spacing issues
class ModernTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final Color? fillColor;
  final bool autofocus;

  const ModernTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.fillColor,
    this.autofocus = false,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = _getBorderColor(hasError);
    final fillColor = widget.fillColor ?? 
                     (widget.enabled 
                         ? FormColors.getSurface(context)
                         : FormColors.surfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(context),
          FormSpacing.gapXs,
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: FormSpacing.borderRadiusMd,
            boxShadow: _isFocused && widget.enabled
                ? [
                    BoxShadow(
                      color: FormColors.primary.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onSubmitted,
            autofocus: widget.autofocus,
            style: widget.textStyle ?? FormTypography.getFieldInput(context),
            decoration: InputDecoration(
              hintText: widget.hintText,
              helperText: null, // We handle this separately
              errorText: null, // We handle this separately
              filled: true,
              fillColor: fillColor,
              
              // Proper content padding with icon spacing
              contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? FormSpacing.sm : FormSpacing.md,
                vertical: FormSpacing.md,
              ),
              
              // Prefix icon with proper spacing
              prefixIcon: widget.prefixIcon != null
                  ? Container(
                      margin: const EdgeInsets.only(
                        left: FormSpacing.md,
                        right: FormSpacing.sm,
                      ),
                      child: Icon(
                        widget.prefixIcon,
                        size: FormSpacing.iconSize,
                        color: _getIconColor(hasError),
                      ),
                    )
                  : null,
              prefixIconConstraints: widget.prefixIcon != null
                  ? const BoxConstraints(
                      minWidth: FormSpacing.iconSize + FormSpacing.md + FormSpacing.sm,
                      minHeight: FormSpacing.iconSize,
                    )
                  : null,
              
              // Suffix icon with proper spacing
              suffixIcon: widget.suffixIcon != null
                  ? Container(
                      margin: const EdgeInsets.only(
                        left: FormSpacing.sm,
                        right: FormSpacing.md,
                      ),
                      child: widget.suffixIcon,
                    )
                  : null,
              suffixIconConstraints: widget.suffixIcon != null
                  ? const BoxConstraints(
                      minWidth: FormSpacing.iconSize + FormSpacing.md + FormSpacing.sm,
                      minHeight: FormSpacing.iconSize,
                    )
                  : null,
              
              // Border styling with proper colors
              border: OutlineInputBorder(
                borderRadius: FormSpacing.borderRadiusMd,
                borderSide: BorderSide(
                  color: borderColor,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: FormSpacing.borderRadiusMd,
                borderSide: BorderSide(
                  color: FormColors.getBorder(context),
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
                borderSide: BorderSide(
                  color: FormColors.getBorder(context).withOpacity(0.5),
                  width: 1.0,
                ),
              ),
              
              // Text styling
              hintStyle: FormTypography.fieldPlaceholder.copyWith(
                color: FormColors.getTextSecondary(context).withOpacity(0.7),
              ),
              
              // Remove default counter
              counterText: '',
            ),
          ),
        ),
        
        // Helper text and error text with proper spacing
        if (widget.helperText != null || widget.errorText != null) ...[
          FormSpacing.gapXs,
          _buildHelperText(context),
        ],
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: widget.label!,
        style: widget.labelStyle ?? FormTypography.getFieldLabel(context),
        children: [
          if (widget.required)
            TextSpan(
              text: ' *',
              style: (widget.labelStyle ?? FormTypography.getFieldLabel(context))
                  .copyWith(color: FormColors.error),
            ),
        ],
      ),
    );
  }

  Widget _buildHelperText(BuildContext context) {
    final text = widget.errorText ?? widget.helperText;
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        left: widget.prefixIcon != null ? FormSpacing.xl : FormSpacing.md,
      ),
      child: Text(
        text,
        style: widget.errorText != null
            ? FormTypography.errorText
            : FormTypography.helperText.copyWith(
                color: FormColors.getTextSecondary(context),
              ),
      ),
    );
  }

  Color _getBorderColor(bool hasError) {
    if (!widget.enabled) {
      return FormColors.getBorder(context).withOpacity(0.5);
    }
    if (hasError) {
      return FormColors.borderError;
    }
    if (_isFocused) {
      return FormColors.borderFocused;
    }
    return FormColors.getBorder(context);
  }

  Color _getIconColor(bool hasError) {
    if (!widget.enabled) {
      return FormColors.getTextSecondary(context).withOpacity(0.5);
    }
    if (hasError) {
      return FormColors.error;
    }
    if (_isFocused) {
      return FormColors.primary;
    }
    return FormColors.getTextSecondary(context);
  }
}

/// Modern text area for multi-line input
class ModernTextArea extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool required;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const ModernTextArea({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.required = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return ModernTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      enabled: enabled,
      required: required,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      contentPadding: const EdgeInsets.all(FormSpacing.md),
    );
  }
}

/// Modern search field with search icon and clear button
class ModernSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const ModernSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<ModernSearchField> createState() => _ModernSearchFieldState();
}

class _ModernSearchFieldState extends State<ModernSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return ModernTextField(
      controller: _controller,
      hintText: widget.hintText ?? 'Search...',
      prefixIcon: Icons.search,
      suffixIcon: _hasText
          ? IconButton(
              onPressed: _onClear,
              icon: const Icon(Icons.clear),
              iconSize: FormSpacing.iconSizeSmall,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: FormSpacing.iconSizeSmall,
                minHeight: FormSpacing.iconSizeSmall,
              ),
            )
          : null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
    );
  }
}