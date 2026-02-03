import 'dart:io';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'channel.dart';
import 'vod_item.dart';
import 'series_item.dart';

export 'channel.dart';
export 'vod_item.dart';
export 'series_item.dart';

// 数据库管理类
class AppDatabase {
  static Box<Channel>? _channelBox;
  static Box<VodItem>? _vodBox;
  static Box<SeriesItem>? _seriesBox;

  static const String channelBoxName = 'channels';
  static const String vodBoxName = 'vod_items';
  static const String seriesBoxName = 'series_items';

  // 初始化 Hive
  static Future<void> init() async {
    if (Hive.isBoxOpen(channelBoxName)) return;

    late String path;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      path = appDir.path;
    } catch (e) {
      final tempDir = Directory.systemTemp;
      path = tempDir.path;
    }

    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    Hive.init(path);

    // 注册适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChannelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(VodItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SeriesItemAdapter());
    }

    _channelBox = await Hive.openBox<Channel>(channelBoxName);
    _vodBox = await Hive.openBox<VodItem>(vodBoxName);
    _seriesBox = await Hive.openBox<SeriesItem>(seriesBoxName);
  }

  // ==================== Channel 操作 ====================

  static Future<Box<Channel>> get channelBox async {
    if (_channelBox == null || !_channelBox!.isOpen) {
      await init();
    }
    return _channelBox!;
  }

  static Future<int> insertChannel(Channel channel) async {
    final box = await channelBox;
    return await box.add(channel);
  }

  static Future<void> insertChannels(List<Channel> channels) async {
    final box = await channelBox;
    await box.addAll(channels);
  }

  static Future<List<Channel>> getAllChannels() async {
    final box = await channelBox;
    return box.values.toList();
  }

  static Future<List<Channel>> searchChannels(String query) async {
    final box = await channelBox;
    final lowerQuery = query.toLowerCase();
    return box.values.where((channel) {
      return channel.tvgName.toLowerCase().contains(lowerQuery) ||
          channel.groupTitle.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static Future<List<String>> getAllGroups() async {
    final box = await channelBox;
    final groups = box.values.map((c) => c.groupTitle).toSet().toList()..sort();
    return groups;
  }

  static Future<Map<String, int>> getGroupStatistics() async {
    final box = await channelBox;
    final stats = <String, int>{};

    for (final channel in box.values) {
      stats[channel.groupTitle] = (stats[channel.groupTitle] ?? 0) + 1;
    }

    return stats;
  }

  static Future<int> getTotalChannelCount() async {
    final box = await channelBox;
    return box.length;
  }

  static Future<void> deleteAllChannels() async {
    final box = await channelBox;
    await box.clear();
  }

  // ==================== VOD 操作 ====================

  static Future<Box<VodItem>> get vodBox async {
    if (_vodBox == null || !_vodBox!.isOpen) {
      await init();
    }
    return _vodBox!;
  }

  static Future<void> insertVodItems(List<VodItem> items) async {
    final box = await vodBox;
    await box.addAll(items);
  }

  static Future<List<VodItem>> getAllVodItems() async {
    final box = await vodBox;
    return box.values.toList();
  }

  static Future<List<VodItem>> searchVodItems(String query) async {
    final box = await vodBox;
    final lowerQuery = query.toLowerCase();
    return box.values.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.categoryName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static Future<int> getTotalVodCount() async {
    final box = await vodBox;
    return box.length;
  }

  static Future<void> deleteAllVodItems() async {
    final box = await vodBox;
    await box.clear();
  }

  // ==================== Series 操作 ====================

  static Future<Box<SeriesItem>> get seriesBox async {
    if (_seriesBox == null || !_seriesBox!.isOpen) {
      await init();
    }
    return _seriesBox!;
  }

  static Future<void> insertSeriesItems(List<SeriesItem> items) async {
    final box = await seriesBox;
    await box.addAll(items);
  }

  static Future<List<SeriesItem>> getAllSeriesItems() async {
    final box = await seriesBox;
    return box.values.toList();
  }

  static Future<int> getTotalSeriesCount() async {
    final box = await seriesBox;
    return box.length;
  }

  static Future<void> deleteAllSeriesItems() async {
    final box = await seriesBox;
    await box.clear();
  }

  // ==================== 统计和清理 ====================

  /// 获取所有数据统计
  static Future<Map<String, int>> getAllStatistics() async {
    return {
      'channels': await getTotalChannelCount(),
      'vod': await getTotalVodCount(),
      'series': await getTotalSeriesCount(),
    };
  }

  /// 清空所有数据
  static Future<void> deleteAllData() async {
    await deleteAllChannels();
    await deleteAllVodItems();
    await deleteAllSeriesItems();
  }

  // 关闭数据库
  static Future<void> close() async {
    if (_channelBox != null && _channelBox!.isOpen) {
      await _channelBox!.close();
      _channelBox = null;
    }
    if (_vodBox != null && _vodBox!.isOpen) {
      await _vodBox!.close();
      _vodBox = null;
    }
    if (_seriesBox != null && _seriesBox!.isOpen) {
      await _seriesBox!.close();
      _seriesBox = null;
    }
  }
}
