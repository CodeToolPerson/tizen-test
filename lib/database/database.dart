import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void initializeSqflite() {
  // For true desktop Linux, use the FFI version
  // For Tizen (recognized as Linux), use native sqflite (via the sqflite_tizen package)
  if (Platform.isWindows || Platform.isMacOS || (Platform.isLinux && !Platform.environment.containsKey('TIZEN_API_VERSION'))) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('Initialized sqflite FFI for desktop platform: ${Platform.operatingSystem}');
  } else {
    print('Using native sqflite for mobile/embedded platform: ${Platform.operatingSystem}');
  }
}

// Channel data model
class Channel {
  final int? id;
  final int channelNumber;
  final String tvgId;
  final String tvgName;
  final String? tvgLogo;
  final String groupTitle;
  final String streamUrl;
  final String? definition;
  final String? catchupSource;
  final bool hasCatchup;
  final DateTime? createdAt;

  Channel({
    this.id,
    required this.channelNumber,
    required this.tvgId,
    required this.tvgName,
    this.tvgLogo,
    required this.groupTitle,
    required this.streamUrl,
    this.definition,
    this.catchupSource,
    this.hasCatchup = false,
    this.createdAt,
  });

  // Create a Channel object from a Map
  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      id: map['id'],
      channelNumber: map['channelNumber'],
      tvgId: map['tvgId'],
      tvgName: map['tvgName'],
      tvgLogo: map['tvgLogo'],
      groupTitle: map['groupTitle'],
      streamUrl: map['streamUrl'],
      definition: map['definition'],
      catchupSource: map['catchupSource'],
      hasCatchup: map['hasCatchup'] == 1,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'channelNumber': channelNumber,
      'tvgId': tvgId,
      'tvgName': tvgName,
      'tvgLogo': tvgLogo,
      'groupTitle': groupTitle,
      'streamUrl': streamUrl,
      'definition': definition,
      'catchupSource': catchupSource,
      'hasCatchup': hasCatchup ? 1 : 0,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

// Database management class
class AppDatabase {
  static Database? _database;
  static const String tableName = 'channels';

  // Singleton pattern
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  static Future<Database> _initDatabase() async {
    initializeSqflite();

    late String path;

    try {
      final databasesPath = await getDatabasesPath();
      path = p.join(databasesPath, 'channels.db');
    } catch (e) {
      print('getDatabasesPath failed: $e');
      try {
        final appDir = await getApplicationDocumentsDirectory();
        path = p.join(appDir.path, 'channels.db');
      } catch (e2) {
        print('getApplicationDocumentsDirectory also failed: $e2');
        final tempDir = Directory.systemTemp;
        path = p.join(tempDir.path, 'tizentest_channels.db');
        print('Using temp directory: ${tempDir.path}');
      }
    }

    print('Database path: $path');

    final dir = Directory(p.dirname(path));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create table
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        channelNumber INTEGER NOT NULL,
        tvgId TEXT NOT NULL,
        tvgName TEXT NOT NULL,
        tvgLogo TEXT,
        groupTitle TEXT NOT NULL,
        streamUrl TEXT NOT NULL,
        definition TEXT,
        catchupSource TEXT,
        hasCatchup INTEGER DEFAULT 0,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // Insert Channel
  static Future<int> insertChannel(Channel channel) async {
    final db = await database;
    return await db.insert(tableName, channel.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Batch insert channels
  static Future<void> insertChannels(List<Channel> channels) async {
    final db = await database;
    final batch = db.batch();

    for (final channel in channels) {
      batch.insert(tableName, channel.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // Get all channels
  static Future<List<Channel>> getAllChannels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (i) {
      return Channel.fromMap(maps[i]);
    });
  }

  // Search Channel
  static Future<List<Channel>> searchChannels(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'tvgName LIKE ? OR groupTitle LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Channel.fromMap(maps[i]);
    });
  }

  // Get Group List
  static Future<List<String>> getAllGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT DISTINCT groupTitle FROM $tableName ORDER BY groupTitle');

    return maps.map((map) => map['groupTitle'] as String).toList();
  }

  // Get group statistics
  static Future<Map<String, int>> getGroupStatistics() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT groupTitle, COUNT(*) as count FROM $tableName GROUP BY groupTitle');

    final stats = <String, int>{};
    for (final map in maps) {
      stats[map['groupTitle'] as String] = map['count'] as int;
    }

    return stats;
  }

  // Get the total number of channels
  static Future<int> getTotalChannelCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
    return count ?? 0;
  }

  // Clear all channels
  static Future<void> deleteAllChannels() async {
    final db = await database;
    await db.delete(tableName);
  }

  // Close the database
  static Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
