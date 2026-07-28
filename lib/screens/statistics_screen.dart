import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/providers/settings_provider.dart';
import 'package:campusbite/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';

/// Screen for viewing statistics
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contractProvider = context.watch<ContractProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final currency = settingsProvider.currency;

    if (contractProvider.currentContract == null) {
      return const Scaffold(
        body: Center(
          child: Text('No contract found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Spent',
                    value: Formatters.formatCurrency(
                      contractProvider.totalSpent,
                      currency: currency,
                    ),
                    icon: Icons.payments,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Remaining',
                    value: Formatters.formatCurrency(
                      contractProvider.remainingBalance,
                      currency: currency,
                    ),
                    icon: Icons.account_balance_wallet,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meal counts
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Lunch',
                    value: contractProvider.lunchCount.toString(),
                    icon: Icons.lunch_dining,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Dinner',
                    value: contractProvider.dinnerCount.toString(),
                    icon: Icons.dinner_dining,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Custom',
                    value: contractProvider.customMealCount.toString(),
                    icon: Icons.restaurant,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Total Meals',
                    value: contractProvider.totalMeals.toString(),
                    icon: Icons.restaurant_menu,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pie chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Meal Distribution',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            if (contractProvider.lunchCount > 0)
                              PieChartSectionData(
                                value: contractProvider.lunchCount.toDouble(),
                                title: 'Lunch',
                                color: Colors.orange,
                                radius: 80,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (contractProvider.dinnerCount > 0)
                              PieChartSectionData(
                                value: contractProvider.dinnerCount.toDouble(),
                                title: 'Dinner',
                                color: Colors.purple,
                                radius: 80,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (contractProvider.customMealCount > 0)
                              PieChartSectionData(
                                value: contractProvider.customMealCount.toDouble(),
                                title: 'Custom',
                                color: Colors.blue,
                                radius: 80,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Statistics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatRow(
                      label: 'Average Daily Spending',
                      value: Formatters.formatCurrency(
                        contractProvider.averageDailySpending,
                        currency: currency,
                      ),
                    ),
                    const Divider(),
                    _StatRow(
                      label: 'Today\'s Spending',
                      value: Formatters.formatCurrency(
                        contractProvider.todaySpending,
                        currency: currency,
                      ),
                    ),
                    if (contractProvider.highestSpendingDay != null) ...[
                      const Divider(),
                      _StatRow(
                        label: 'Highest Spending Day',
                        value: Formatters.formatCurrency(
                          contractProvider.highestSpendingDay!.value,
                          currency: currency,
                        ),
                      ),
                      _StatRow(
                        label: '',
                        value: Formatters.formatDate(
                          contractProvider.highestSpendingDay!.key,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
