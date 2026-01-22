import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sembast/sembast_io.dart';

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
      id: map['id'] as int?,
      channelNumber: map['channelNumber'] as int,
      tvgId: map['tvgId'] as String,
      tvgName: map['tvgName'] as String,
      tvgLogo: map['tvgLogo'] as String?,
      groupTitle: map['groupTitle'] as String,
      streamUrl: map['streamUrl'] as String,
      definition: map['definition'] as String?,
      catchupSource: map['catchupSource'] as String?,
      hasCatchup: (map['hasCatchup'] as int?) == 1,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
    );
  }

  // Convert to Map (for sembast storage, exclude id as it's managed by the store)
  Map<String, dynamic> toMap() {
    return {
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

  // Create a Channel object from a sembast record (includes the key as id)
  factory Channel.fromRecord(RecordSnapshot<int, Map<String, dynamic>> record) {
    final map = Map<String, dynamic>.from(record.value);
    map['id'] = record.key; // Add the record key as id
    return Channel.fromMap(map);
  }
}

// Database management class
class AppDatabase {
  static Database? _database;
  static const String storeName = 'channels';
  static final store = intMapStoreFactory.store(storeName);

  // Singleton pattern
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  static Future<Database> _initDatabase() async {
    late String path;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      path = p.join(appDir.path, 'channels.db');
    } catch (e) {
      final tempDir = Directory.systemTemp;
      path = p.join(tempDir.path, 'tizentest_channels.db');
    }

    final dir = Directory(p.dirname(path));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final databaseFactory = databaseFactoryIo;
    return await databaseFactory.openDatabase(path);
  }

  // Insert Channel
  static Future<int> insertChannel(Channel channel) async {
    final db = await database;
    return await store.add(db, channel.toMap());
  }

  // Batch insert channels
  static Future<void> insertChannels(List<Channel> channels) async {
    final db = await database;
    await store.addAll(db, channels.map((channel) => channel.toMap()).toList());
  }

  // Get all channels
  static Future<List<Channel>> getAllChannels() async {
    final db = await database;
    final records = await store.find(db);

    return records.map((record) => Channel.fromRecord(record)).toList();
  }

  // Search Channel
  static Future<List<Channel>> searchChannels(String query) async {
    final db = await database;
    final finder = Finder(filter: Filter.or([Filter.matches('tvgName', query), Filter.matches('groupTitle', query)]));

    final records = await store.find(db, finder: finder);
    return records.map((record) => Channel.fromRecord(record)).toList();
  }

  // Get Group List
  static Future<List<String>> getAllGroups() async {
    final db = await database;
    final records = await store.find(db);
    final groups = records.map((record) => record.value['groupTitle'] as String).toSet().toList()..sort();

    return groups;
  }

  // Get group statistics
  static Future<Map<String, int>> getGroupStatistics() async {
    final db = await database;
    final records = await store.find(db);
    final stats = <String, int>{};

    for (final record in records) {
      final groupTitle = record.value['groupTitle'] as String;
      stats[groupTitle] = (stats[groupTitle] ?? 0) + 1;
    }

    return stats;
  }

  // Get the total number of channels
  static Future<int> getTotalChannelCount() async {
    final db = await database;
    return await store.count(db);
  }

  // Clear all channels
  static Future<void> deleteAllChannels() async {
    final db = await database;
    await store.delete(db);
  }

  // Close the database
  static Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
