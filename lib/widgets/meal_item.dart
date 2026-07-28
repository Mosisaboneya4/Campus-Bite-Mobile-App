import 'package:flutter/material.dart';
import 'package:campusbite/models/meal.dart';
import 'package:campusbite/utils/formatters.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Meal item widget for history list
class MealItem extends StatelessWidget {
  final Meal meal;
  final String currency;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const MealItem({
    super.key,
    required this.meal,
    required this.currency,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: _getMealIcon(meal.mealType),
          title: Text(
            meal.mealTypeString,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Formatters.formatDateTime(meal.date),
                style: theme.textTheme.bodySmall,
              ),
              if (meal.reason != null && meal.reason!.isNotEmpty)
                Text(
                  meal.reason!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          trailing: Text(
            '-${Formatters.formatCurrency(meal.amount, currency: currency)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getMealIcon(MealType type) {
    switch (type) {
      case MealType.lunch:
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.lunch_dining, color: Colors.white),
        );
      case MealType.dinner:
        return const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.dinner_dining, color: Colors.white),
        );
      case MealType.custom:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.restaurant, color: Colors.white),
        );
    }
  }
}
