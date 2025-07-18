import 'package:flutter/material.dart';
import 'form_colors.dart';
import 'form_typography.dart';
import 'form_spacing.dart';

/// Modern form scaffold that provides consistent layout and spacing
/// Fixes overlapping elements and provides proper visual hierarchy
class ModernFormScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isLoading;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final String? saveButtonText;
  final String? cancelButtonText;
  final bool showDeleteButton;
  final bool showCancelButton;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final List<Widget>? appBarActions;

  const ModernFormScaffold({
    super.key,
    required this.title,
    required this.child,
    this.isLoading = false,
    this.onSave,
    this.onCancel,
    this.onDelete,
    this.saveButtonText,
    this.cancelButtonText,
    this.showDeleteButton = false,
    this.showCancelButton = true,
    this.backgroundColor,
    this.floatingActionButton,
    this.appBarActions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? FormColors.getBackground(context),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomActions(context),
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: FormTypography.getTitle(context),
      ),
      backgroundColor: FormColors.getSurface(context),
      foregroundColor: FormColors.getTextPrimary(context),
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      actions: [
        if (showDeleteButton && onDelete != null)
          IconButton(
            onPressed: isLoading ? null : onDelete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            color: FormColors.error,
          ),
        if (appBarActions != null) ...appBarActions!,
        FormSpacing.gapHorizontalSm,
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: FormSpacing.getResponsivePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                       MediaQuery.of(context).padding.top - 
                       MediaQuery.of(context).padding.bottom - 
                       kToolbarHeight - 
                       80, // Bottom action bar height
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormSpacing.gapMd,
                Expanded(child: child),
                FormSpacing.gapXl,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildBottomActions(BuildContext context) {
    if (onSave == null && onCancel == null) return null;

    return Container(
      decoration: BoxDecoration(
        color: FormColors.getSurface(context),
        boxShadow: [
          BoxShadow(
            color: FormColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: FormSpacing.md,
        right: FormSpacing.md,
        top: FormSpacing.md,
        bottom: FormSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          if (showCancelButton && onCancel != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, FormSpacing.buttonHeight),
                  side: BorderSide(
                    color: FormColors.getBorder(context),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: FormSpacing.borderRadiusMd,
                  ),
                ),
                child: Text(
                  cancelButtonText ?? 'Cancel',
                  style: FormTypography.buttonSecondary.copyWith(
                    color: FormColors.getTextSecondary(context),
                  ),
                ),
              ),
            ),
            FormSpacing.gapHorizontalMd,
          ],
          if (onSave != null)
            Expanded(
              flex: showCancelButton ? 1 : 2,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FormColors.primary,
                  foregroundColor: FormColors.textOnPrimary,
                  minimumSize: const Size(0, FormSpacing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: FormSpacing.borderRadiusMd,
                  ),
                  elevation: FormSpacing.elevationSm,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FormColors.textOnPrimary,
                          ),
                        ),
                      )
                    : Text(
                        saveButtonText ?? 'Save',
                        style: FormTypography.buttonPrimary,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Modern form section with proper spacing and visual hierarchy
class ModernFormSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final bool showDivider;

  const ModernFormSection({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    required this.children,
    this.padding,
    this.backgroundColor,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: FormSpacing.sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            _buildSectionHeader(context),
            FormSpacing.gapMd,
          ],
          Container(
            padding: padding ?? FormSpacing.paddingMd,
            decoration: BoxDecoration(
              color: backgroundColor ?? FormColors.getSurface(context),
              borderRadius: FormSpacing.borderRadiusLg,
              border: Border.all(
                color: FormColors.getBorder(context),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildChildrenWithSpacing(),
            ),
          ),
          if (showDivider) ...[
            FormSpacing.gapLg,
            Divider(
              color: FormColors.getBorder(context),
              thickness: 1,
              height: 1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: FormSpacing.iconSize,
            color: FormColors.primary,
          ),
          FormSpacing.gapHorizontalSm,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: FormTypography.getSectionHeader(context),
              ),
              if (subtitle != null) ...[
                FormSpacing.gapXs,
                Text(
                  subtitle!,
                  style: FormTypography.sectionSubheader.copyWith(
                    color: FormColors.getTextSecondary(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithSpacing() {
    if (children.isEmpty) return [];

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(FormSpacing.gapMd);
      }
    }
    return spacedChildren;
  }
}

/// Modern form field wrapper with consistent spacing and labels
class ModernFormField extends StatelessWidget {
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final Widget child;
  final EdgeInsets? padding;

  const ModernFormField({
    super.key,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            _buildLabel(context),
            FormSpacing.gapXs,
          ],
          child,
          if (helperText != null || errorText != null) ...[
            FormSpacing.gapXs,
            _buildHelperText(context),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label!,
        style: FormTypography.getFieldLabel(context),
        children: [
          if (isRequired)
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

    return Text(
      text,
      style: errorText != null
          ? FormTypography.errorText
          : FormTypography.helperText.copyWith(
              color: FormColors.getTextSecondary(context),
            ),
    );
  }
}

/// Loading overlay for forms
class FormLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const FormLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: FormColors.overlay,
            child: Center(
              child: Container(
                padding: FormSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: FormColors.getSurface(context),
                  borderRadius: FormSpacing.borderRadiusLg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (loadingText != null) ...[
                      FormSpacing.gapMd,
                      Text(
                        loadingText!,
                        style: FormTypography.getFieldInput(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}