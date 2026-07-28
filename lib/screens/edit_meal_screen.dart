import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/providers/settings_provider.dart';
import 'package:campusbite/models/meal.dart';
import 'package:campusbite/utils/validators.dart';

/// Screen for editing a meal
class EditMealScreen extends StatefulWidget {
  final Meal meal;

  const EditMealScreen({super.key, required this.meal});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _reasonController;
  late MealType _selectedMealType;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.meal.amount.toString());
    _reasonController = TextEditingController(text: widget.meal.reason ?? '');
    _selectedMealType = widget.meal.mealType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _updateMeal() {
    if (_formKey.currentState!.validate()) {
      final contractProvider = context.read<ContractProvider>();

      // Calculate the difference in amount
      final oldAmount = widget.meal.amount;
      final newAmount = double.parse(_amountController.text);
      final difference = newAmount - oldAmount;

      // Check if balance is sufficient for the increase
      if (difference > 0 && !contractProvider.canAddMeal(difference)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient balance for this change!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedMeal = widget.meal.copyWith(
        mealType: _selectedMealType,
        amount: newAmount,
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
      );

      contractProvider.updateMeal(updatedMeal);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final currency = settingsProvider.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMeal(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Meal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Meal type dropdown
                      DropdownButtonFormField<MealType>(
                        initialValue: _selectedMealType,
                        decoration: const InputDecoration(
                          labelText: 'Meal Type',
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: MealType.lunch,
                            child: Text('Lunch'),
                          ),
                          DropdownMenuItem(
                            value: MealType.dinner,
                            child: Text('Dinner'),
                          ),
                          DropdownMenuItem(
                            value: MealType.custom,
                            child: Text('Custom'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMealType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: const Icon(Icons.payments),
                          suffixText: currency,
                          hintText: 'Enter amount',
                        ),
                        validator: Validators.validateMealAmount,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason (Optional)',
                          prefixIcon: Icon(Icons.note),
                          hintText: 'e.g., Special meal, Snack',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _updateMeal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Update Meal',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteMeal(BuildContext context) async {
    final contractProvider = context.read<ContractProvider>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
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
      await contractProvider.deleteMeal(widget.meal.id);
      if (!mounted) return;
      navigator.pop(true);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Meal deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
