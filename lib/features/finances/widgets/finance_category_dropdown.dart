import 'package:flutter/material.dart';
import '../models/finance_category.dart';

class FinanceCategoryDropdown extends StatelessWidget {
  final FinanceCategoryType type;
  final String? selectedCategoryId;
  final ValueChanged<String> onChanged;
  final bool isExpanded;

  const FinanceCategoryDropdown({
    super.key,
    required this.type,
    required this.selectedCategoryId,
    required this.onChanged,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = FinanceCategory.getCategoriesForType(type);
    final selectedCategory = selectedCategoryId != null
        ? FinanceCategory.getCategoryById(selectedCategoryId!)
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategoryId,
          isExpanded: isExpanded,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: const Icon(Icons.arrow_drop_down),
          hint: Row(
            children: [
              Icon(
                type == FinanceCategoryType.income
                    ? Icons.add_circle_outline
                    : Icons.remove_circle_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Select ${type == FinanceCategoryType.income ? 'Income' : 'Expense'} Category',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    color: category.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          selectedItemBuilder: (context) {
            return categories.map((category) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      color: category.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
} 