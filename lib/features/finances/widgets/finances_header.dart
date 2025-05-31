import 'package:flutter/material.dart';

class FinancesHeader extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const FinancesHeader({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Finances', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: selectedPeriod,
          items: ['This Week', 'This Month', 'This Year', 'All Time']
              .map((period) => DropdownMenuItem(value: period, child: Text(period)))
              .toList(),
          onChanged: onPeriodChanged,
        ),
      ],
    );
  }
}
