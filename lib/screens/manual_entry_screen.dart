import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/providers/settings_provider.dart';
import 'package:campusbite/models/meal.dart';
import 'package:campusbite/utils/validators.dart';
import 'package:uuid/uuid.dart';

/// Screen for manual meal entry
class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _recordMeal() {
    if (_formKey.currentState!.validate()) {
      final contractProvider = context.read<ContractProvider>();
      final amount = double.parse(_amountController.text);

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
        mealType: MealType.custom,
        amount: amount,
        date: DateTime.now(),
        reason: _reasonController.text.trim(),
      );

      contractProvider.addMeal(meal);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom meal recorded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final currency = settingsProvider.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry'),
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
                        'Custom Meal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _recordMeal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Record Meal',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
