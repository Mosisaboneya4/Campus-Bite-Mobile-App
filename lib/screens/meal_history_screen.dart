import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/providers/settings_provider.dart';
import 'package:campusbite/models/meal.dart';
import 'package:campusbite/widgets/meal_item.dart';
import 'package:campusbite/screens/edit_meal_screen.dart';
import 'package:campusbite/utils/formatters.dart';
import 'package:campusbite/utils/export_service.dart';

/// Screen for viewing meal history
class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  String _searchQuery = '';
  DateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contractProvider = context.watch<ContractProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final currency = settingsProvider.currency;

    List<Meal> filteredMeals = contractProvider.meals;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredMeals = filteredMeals.where((meal) {
        return meal.mealTypeString.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (meal.reason != null && meal.reason!.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply month filter
    if (_selectedMonth != null) {
      filteredMeals = filteredMeals.where((meal) {
        return meal.date.year == _selectedMonth!.year &&
            meal.date.month == _selectedMonth!.month;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (value == 'filter_month') {
                _selectMonth();
              } else if (value == 'clear_filter') {
                setState(() {
                  _selectedMonth = null;
                });
              } else if (value == 'export_csv') {
                try {
                  await ExportService.exportToCSV(
                    contractProvider,
                    contractProvider.currentContract!,
                    currency,
                  );
                } catch (e) {
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter_month',
                child: Text('Filter by Month'),
              ),
              if (_selectedMonth != null)
                const PopupMenuItem(
                  value: 'clear_filter',
                  child: Text('Clear Filter'),
                ),
              const PopupMenuItem(
                value: 'export_csv',
                child: Text('Export CSV'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search meals...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Month filter indicator
          if (_selectedMonth != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                label: Text(Formatters.formatMonthYear(_selectedMonth!)),
                onDeleted: () {
                  setState(() {
                    _selectedMonth = null;
                  });
                },
                deleteIcon: const Icon(Icons.close),
              ),
            ),

          // Meal list
          Expanded(
            child: filteredMeals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No meals found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await contractProvider.initialize();
                    },
                    child: ListView.builder(
                      itemCount: filteredMeals.length,
                      itemBuilder: (context, index) {
                        final meal = filteredMeals[index];
                        return MealItem(
                          meal: meal,
                          currency: currency,
                          onEdit: () => _editMeal(meal),
                          onDelete: () => _deleteMeal(meal, contractProvider),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  Future<void> _editMeal(Meal meal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMealScreen(meal: meal),
      ),
    );
    if (result == true) {
      // Meal was updated, provider will notify listeners
    }
  }

  Future<void> _deleteMeal(Meal meal, ContractProvider contractProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete this ${meal.mealTypeString}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await contractProvider.deleteMeal(meal.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.mealTypeString} deleted. Balance restored.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
