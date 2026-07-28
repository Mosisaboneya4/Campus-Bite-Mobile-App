import 'dart:convert';
import 'package:campusbite/services/hive_service.dart';
// Removed path_provider dependency; using system temp directory instead.
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// Service for backup and restore
class BackupService {
  /// Backup Hive data
  static Future<void> backupData() async {
    final hiveService = HiveService();
    
    final directory = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${directory.path}${Platform.pathSeparator}campusbite_backup_$timestamp.json';
    
    final data = await hiveService.exportData();
    final file = File(path);
    await file.writeAsString(jsonEncode(data));
    
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        subject: 'CampusBite Backup',
      ),
    );
  }

  /// Restore Hive data
  static Future<bool> restoreData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }
      
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final hiveService = HiveService();
      
      await hiveService.importData(data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
