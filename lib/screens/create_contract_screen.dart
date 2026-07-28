import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/constants/app_constants.dart';
import 'package:campusbite/utils/validators.dart';

/// Screen for creating a new contract
class CreateContractScreen extends StatefulWidget {
  const CreateContractScreen({super.key});

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();

  final _studentNameController = TextEditingController();
  final _depositController = TextEditingController(text: AppConstants.defaultDeposit.toString());
  final _lunchPriceController = TextEditingController(text: AppConstants.defaultLunchPrice.toString());
  final _dinnerPriceController = TextEditingController(text: AppConstants.defaultDinnerPrice.toString());

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _studentNameController.dispose();
    _depositController.dispose();
    _lunchPriceController.dispose();
    _dinnerPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _createContract() {
    if (_formKey.currentState!.validate()) {
      final contractProvider = context.read<ContractProvider>();

      contractProvider.createContract(
        studentName: _studentNameController.text.trim(),
        initialDeposit: double.parse(_depositController.text),
        lunchPrice: double.parse(_lunchPriceController.text),
        dinnerPrice: double.parse(_dinnerPriceController.text),
        startDate: _startDate,
        endDate: _endDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contract created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Contract'),
      ),
      body: SingleChildScrollView(
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
                        'Student Information',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _studentNameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Enter your name',
                        ),
                        validator: Validators.validateStudentName,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contract Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _depositController,
                        decoration: const InputDecoration(
                          labelText: 'Initial Deposit',
                          prefixIcon: Icon(Icons.account_balance_wallet),
                          hintText: 'Enter deposit amount',
                        ),
                        validator: Validators.validateDeposit,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lunchPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Lunch Price',
                          prefixIcon: Icon(Icons.lunch_dining),
                          hintText: 'Enter lunch price',
                        ),
                        validator: Validators.validateMealPrice,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dinnerPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Dinner Price',
                          prefixIcon: Icon(Icons.dinner_dining),
                          hintText: 'Enter dinner price',
                        ),
                        validator: Validators.validateMealPrice,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contract Period',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Start Date'),
                        subtitle: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _selectStartDate,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('End Date'),
                        subtitle: Text(
                          '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _selectEndDate,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${_endDate.difference(_startDate).inDays + 1} days',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _createContract,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Create Contract',
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
