import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/providers/settings_provider.dart';
import 'package:campusbite/utils/formatters.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:campusbite/models/meal.dart' show MealType;

/// Screen for viewing meal calendar
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

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

    // Get meals for the selected day
    final selectedDayMeals = contractProvider.getMealsForDate(_selectedDay!);
    final totalSpent = selectedDayMeals.fold<double>(0, (sum, meal) => sum + meal.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Calendar'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: contractProvider.currentContract!.startDate,
              lastDay: contractProvider.currentContract!.endDate,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                final meals = contractProvider.getMealsForDate(day);
                return meals.isNotEmpty ? meals : [];
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Selected day info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.formatFullDate(_selectedDay!),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DayStat(
                          label: 'Lunch',
                          value: selectedDayMeals
                              .where((m) => m.mealType == MealType.lunch)
                              .length
                              .toString(),
                          icon: Icons.lunch_dining,
                          color: Colors.orange,
                        ),
                        _DayStat(
                          label: 'Dinner',
                          value: selectedDayMeals
                              .where((m) => m.mealType == MealType.dinner)
                              .length
                              .toString(),
                          icon: Icons.dinner_dining,
                          color: Colors.purple,
                        ),
                        _DayStat(
                          label: 'Custom',
                          value: selectedDayMeals
                              .where((m) => m.mealType == MealType.custom)
                              .length
                              .toString(),
                          icon: Icons.restaurant,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Spent',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          Formatters.formatCurrency(totalSpent, currency: currency),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Meal list for selected day
          Expanded(
            child: selectedDayMeals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_meals,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No meals on this day',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedDayMeals.length,
                    itemBuilder: (context, index) {
                      final meal = selectedDayMeals[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: _getMealIcon(meal.mealType),
                          title: Text(meal.mealTypeString),
                          subtitle: Text(Formatters.formatTime(meal.date)),
                          trailing: Text(
                            Formatters.formatCurrency(meal.amount, currency: currency),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Icon _getMealIcon(MealType type) {
    switch (type) {
      case MealType.lunch:
        return const Icon(Icons.lunch_dining, color: Colors.orange);
      case MealType.dinner:
        return const Icon(Icons.dinner_dining, color: Colors.purple);
      case MealType.custom:
        return const Icon(Icons.restaurant, color: Colors.blue);
    }
  }
}

class _DayStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DayStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
