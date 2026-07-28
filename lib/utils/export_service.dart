import 'package:campusbite/providers/contract_provider.dart';
import 'package:campusbite/models/contract.dart';
import 'package:campusbite/utils/formatters.dart';
import 'package:pdf/widgets.dart' as pw;
// Removed path_provider usage; using system temp directory instead.
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// Service for exporting data
class ExportService {
  /// Export meals to CSV
  static Future<void> exportToCSV(
    ContractProvider contractProvider,
    Contract contract,
    String currency,
  ) async {
    final meals = contractProvider.meals;

    List<List<dynamic>> rows = [
      ['Date', 'Time', 'Meal Type', 'Amount ($currency)', 'Reason'],
    ];

    for (var meal in meals) {
      rows.add([
        Formatters.formatDate(meal.date),
        Formatters.formatTime(meal.date),
        meal.mealTypeString,
        meal.amount.toString(),
        meal.reason ?? '',
      ]);
    }

    String csv = rows.map((row) => row.join(',')).join('\n');

    final directory = Directory.systemTemp;
    final path = '${directory.path}${Platform.pathSeparator}meal_history.csv';
    final file = File(path);
    await file.writeAsString(csv);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        subject: 'Meal History CSV',
      ),
    );
  }

  /// Export meals to PDF
  static Future<void> exportToPDF(
    ContractProvider contractProvider,
    Contract contract,
    String currency,
  ) async {
    final meals = contractProvider.meals;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Meal History',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Student: ${contract.studentName}'),
              pw.Text('Contract: ${Formatters.formatDate(contract.startDate)} - ${Formatters.formatDate(contract.endDate)}'),
              pw.SizedBox(height: 16),
              pw.Table(
                defaultColumnWidth: const pw.FixedColumnWidth(100),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(child: pw.Text('Date'), padding: const pw.EdgeInsets.all(4)),
                      pw.Padding(child: pw.Text('Time'), padding: const pw.EdgeInsets.all(4)),
                      pw.Padding(child: pw.Text('Meal Type'), padding: const pw.EdgeInsets.all(4)),
                      pw.Padding(child: pw.Text('Amount ($currency)'), padding: const pw.EdgeInsets.all(4)),
                      pw.Padding(child: pw.Text('Reason'), padding: const pw.EdgeInsets.all(4)),
                    ],
                  ),
                  ...meals.map((meal) => pw.TableRow(
                    children: [
                      pw.Padding(child: pw.Text(Formatters.formatDate(meal.date)), padding: const pw.EdgeInsets.all(4)),
                      pw.Padding(child: pw.Text(Formatters.formatTime(meal.date)), padding: const pw.EdgeInsets.all(4)),
                      pw.Padding(child: pw.Text(meal.mealTypeString), padding: const pw.EdgeInsets.all(4)),
                      pw.Padding(child: pw.Text(meal.amount.toString()), padding: const pw.EdgeInsets.all(4)),
                      pw.Padding(child: pw.Text(meal.reason ?? ''), padding: const pw.EdgeInsets.all(4)),
                    ],
                  )),
                ],
              ),
            ],
          );
        },
      ),
    );

    final directory = Directory.systemTemp;
    final path = '${directory.path}${Platform.pathSeparator}meal_history.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        subject: 'Meal History PDF',
      ),
    );
  }
}
