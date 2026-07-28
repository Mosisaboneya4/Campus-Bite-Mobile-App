import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/providers/settings_provider.dart';
import 'package:campusbite/models/meal.dart';
import 'package:campusbite/screens/manual_entry_screen.dart';
import 'package:uuid/uuid.dart';

/// Screen for recording meals
class RecordMealScreen extends StatelessWidget {
  const RecordMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contractProvider = context.watch<ContractProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    if (contractProvider.currentContract == null) {
      return const Scaffold(
        body: Center(
          child: Text('No contract found. Please create a contract first.'),
        ),
      );
    }

    final contract = contractProvider.currentContract!;
    final currency = settingsProvider.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Remaining Balance',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${contractProvider.remainingBalance.toStringAsFixed(0)} $currency',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: contractProvider.isLowBalance
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick meal buttons
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MealButton(
                    icon: Icons.lunch_dining,
                    label: 'Lunch',
                    amount: contract.lunchPrice,
                    currency: currency,
                    color: Colors.orange,
                    onTap: () => _recordMeal(
                      context,
                      contractProvider,
                      MealType.lunch,
                      contract.lunchPrice,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MealButton(
                    icon: Icons.dinner_dining,
                    label: 'Dinner',
                    amount: contract.dinnerPrice,
                    currency: currency,
                    color: Colors.purple,
                    onTap: () => _recordMeal(
                      context,
                      contractProvider,
                      MealType.dinner,
                      contract.dinnerPrice,
                    ),
                  ),
                ],
              ),
            ),

            // Manual entry button
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManualEntryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Manual Entry'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _recordMeal(
    BuildContext context,
    ContractProvider contractProvider,
    MealType mealType,
    double amount,
  ) {
    if (!contractProvider.canAddMeal(amount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final meal = Meal(
      id: const Uuid().v4(),
      mealType: mealType,
      amount: amount,
      date: DateTime.now(),
    );

    contractProvider.addMeal(meal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${mealType.toString().split('.').last} recorded successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _MealButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final String currency;
  final Color color;
  final VoidCallback onTap;

  const _MealButton({
    required this.icon,
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '-$amount $currency',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_circle, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
