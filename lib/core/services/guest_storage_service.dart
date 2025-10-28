import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Service to persist guest UID locally using SQLite
/// This ensures guest users maintain their identity across app reinstalls
class GuestStorageService {
  static final GuestStorageService _instance = GuestStorageService._internal();
  factory GuestStorageService() => _instance;
  GuestStorageService._internal();

  static const String _databaseName = 'guest_storage.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'guest_data';

  Database? _database;

  /// Get the database instance, creating it if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Create the database schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guest_uid TEXT NOT NULL,
        device_id TEXT,
        created_at TEXT NOT NULL,
        last_used_at TEXT NOT NULL
      )
    ''');
  }

  /// Get saved guest UID if exists
  Future<String?> getSavedGuestUid() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        _tableName,
        orderBy: 'last_used_at DESC',
        limit: 1,
      );

      if (results.isNotEmpty) {
        // Update last used timestamp
        final guestUid = results.first['guest_uid'] as String;
        await _updateLastUsed(results.first['id'] as int);
        return guestUid;
      }

      return null;
    } catch (e) {
      // Return null if any error occurs (first run, corrupted db, etc.)
      return null;
    }
  }

  /// Save a new guest UID
  Future<void> saveGuestUid(String guestUid, {String? deviceId}) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      // Delete any existing guest data first (only keep one guest per device)
      await db.delete(_tableName);

      // Insert the new guest UID
      await db.insert(_tableName, {
        'guest_uid': guestUid,
        'device_id': deviceId,
        'created_at': now,
        'last_used_at': now,
      });
    } catch (e) {
      // Silently fail - guest can still work without persistence
    }
  }

  /// Update last used timestamp
  Future<void> _updateLastUsed(int id) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        {'last_used_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear saved guest data (for logout/reset)
  Future<void> clearGuestData() async {
    try {
      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      // Silently fail
    }
  }

  /// Check if a guest UID exists in local storage
  Future<bool> hasStoredGuestUid() async {
    final uid = await getSavedGuestUid();
    return uid != null;
  }
}
