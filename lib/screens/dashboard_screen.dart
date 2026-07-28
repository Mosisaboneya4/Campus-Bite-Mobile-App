import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/providers/settings_provider.dart';
import 'package:campusbite/widgets/balance_card.dart';
import 'package:campusbite/widgets/stat_card.dart';
import 'package:campusbite/screens/create_contract_screen.dart';
import 'package:campusbite/screens/record_meal_screen.dart';
import 'package:campusbite/screens/meal_history_screen.dart';
import 'package:campusbite/screens/statistics_screen.dart';
import 'package:campusbite/screens/calendar_screen.dart';
import 'package:campusbite/screens/settings_screen.dart';
import 'package:campusbite/utils/formatters.dart';

/// Dashboard screen showing balance overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLowBalance();
    });
  }

  void _checkLowBalance() {
    final contractProvider = context.read<ContractProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    if (contractProvider.currentContract != null &&
        settingsProvider.notificationsEnabled) {
      if (contractProvider.isBalanceZero) {
        _showContractFinishedDialog();
      } else if (contractProvider.remainingBalance <=
          settingsProvider.lowBalanceThreshold) {
        _showLowBalanceWarning();
      }
    }
  }

  void _showLowBalanceWarning() {
    final contractProvider = context.read<ContractProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange,
        content: Text(
          'Low Balance\nOnly ${Formatters.formatCurrency(contractProvider.remainingBalance, currency: settingsProvider.currency)} remaining.',
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showContractFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contract Finished'),
        content: const Text('Please renew your monthly payment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contractProvider = context.watch<ContractProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    // Show create contract screen if no contract exists
    if (contractProvider.currentContract == null) {
      return const CreateContractScreen();
    }

    final contract = contractProvider.currentContract!;
    final currency = settingsProvider.currency;
    final progress = contractProvider.remainingBalance / contract.initialDeposit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await contractProvider.initialize();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          contract.studentName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contract.studentName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Contract: ${Formatters.formatMonthYear(contract.startDate)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Balance cards
              BalanceCard(
                title: 'Remaining Balance',
                amount: contractProvider.remainingBalance,
                currency: currency,
                icon: Icons.account_balance_wallet,
                iconColor: Colors.green,
                showProgress: true,
                progressValue: progress,
              ),
              const SizedBox(height: 12),

              BalanceCard(
                title: 'Initial Deposit',
                amount: contract.initialDeposit,
                currency: currency,
                icon: Icons.savings,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 12),

              BalanceCard(
                title: 'Total Spent',
                amount: contractProvider.totalSpent,
                currency: currency,
                icon: Icons.payments,
                iconColor: Colors.red,
              ),
              const SizedBox(height: 24),

              // Statistics cards
              Text(
                'Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    label: 'Meals This Month',
                    value: contractProvider.totalMeals.toString(),
                    icon: Icons.restaurant,
                    color: Colors.orange,
                  ),
                  StatCard(
                    label: 'Today\'s Spending',
                    value: Formatters.formatCurrency(
                      contractProvider.todaySpending,
                      currency: currency,
                    ),
                    icon: Icons.today,
                    color: Colors.purple,
                  ),
                  StatCard(
                    label: 'Lunch Count',
                    value: contractProvider.lunchCount.toString(),
                    icon: Icons.lunch_dining,
                    color: Colors.amber,
                  ),
                  StatCard(
                    label: 'Dinner Count',
                    value: contractProvider.dinnerCount.toString(),
                    icon: Icons.dinner_dining,
                    color: Colors.indigo,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecordMealScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Record Meal'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MealHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('History'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StatisticsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('View Statistics'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
