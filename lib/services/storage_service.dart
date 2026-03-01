import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Central JSON file storage service.
/// All data is persisted as JSON files in the app's documents directory.
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  /// Returns the app's local documents directory path.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${directory.path}/catering_data');
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
    }
    return dataDir.path;
  }

  /// Returns a [File] reference for the given [filename].
  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  // ─── Read ───────────────────────────────────────────────────────────────────

  /// Reads a JSON file and returns a decoded [List].
  Future<List<dynamic>> readList(String filename) async {
    try {
      final file = await _localFile(filename);
      if (!file.existsSync()) return [];
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) return [];
      return jsonDecode(contents) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  /// Reads a JSON file and returns a decoded [Map].
  Future<Map<String, dynamic>> readMap(String filename) async {
    try {
      final file = await _localFile(filename);
      if (!file.existsSync()) return {};
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) return {};
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ─── Write ──────────────────────────────────────────────────────────────────

  /// Writes a [List] as JSON to [filename].
  Future<void> writeList(String filename, List<dynamic> data) async {
    final file = await _localFile(filename);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  /// Writes a [Map] as JSON to [filename].
  Future<void> writeMap(String filename, Map<String, dynamic> data) async {
    final file = await _localFile(filename);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  // ─── Utilities ───────────────────────────────────────────────────────────────

  /// Deletes the JSON file (useful for testing / reset).
  Future<void> deleteFile(String filename) async {
    final file = await _localFile(filename);
    if (file.existsSync()) await file.delete();
  }

  /// Returns the full path of the storage directory.
  Future<String> getStoragePath() async => _localPath;
}

// ─── File Name Constants ──────────────────────────────────────────────────────
class StorageFiles {
  static const String users = 'users.json';
  static const String clients = 'clients.json';
  static const String orders = 'orders.json';
  static const String purchases = 'purchases.json';
  static const String employees = 'employees.json';
  static const String inventory = 'inventory.json';
  static const String session = 'session.json';
}
