import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../database/database.dart';
import '../database/channel_dao.dart';
import '../utils/m3u_parser.dart';

class ChannelController extends GetxController {
  final ChannelDao _channelDao = ChannelDao();

  final RxList<Channel> channels = <Channel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalChannels = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // Initialize data: Check if the database is empty; if it is, load the default M3U channel data from assets.
  Future<void> _initializeData() async {
    try {
      final channelCount = await _channelDao.getTotalChannelCount();

      if (channelCount == 0) {
        await _loadDefaultM3UFromAssets();
      } else {
        await loadChannels();
      }

      await _loadStats();

      // Monitor data changes and update statistics
      ever(channels, (_) => _loadStats());
    } catch (e) {
      await loadChannels();
      await _loadStats();
    }
  }

  // Load default M3U data from assets
  Future<void> _loadDefaultM3UFromAssets() async {
    try {
      final m3uContent = await rootBundle.loadString('assets/default_channels.m3u');
      if (m3uContent.isNotEmpty) {
        final channelData = M3UParser.parseM3UString(m3uContent);
        if (channelData.isNotEmpty) {
          await _channelDao.insertChannels(channelData);
          await loadChannels();
        } else {
          throw Exception('No valid channels found in default M3U');
        }
      } else {
        throw Exception('Default M3U file is empty');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void onClose() {
    AppDatabase.close();
    super.onClose();
  }

  // Load all channels
  Future<void> loadChannels() async {
    try {
      isLoading.value = true;
      final allChannels = await _channelDao.getAllChannels();
      channels.assignAll(allChannels);
    } catch (e) {
      Get.snackbar('错误', '加载频道失败: $e', duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  // Load data from M3U string
  Future<void> loadFromM3UString(String m3uContent) async {
    try {
      isLoading.value = true;

      final channelData = M3UParser.parseM3UString(m3uContent);

      if (channelData.isEmpty) {
        Get.snackbar('提示', '未找到有效的频道数据');
        return;
      }

      await _channelDao.deleteAllChannels();

      await _channelDao.insertChannels(channelData);

      await loadChannels();

      Get.snackbar('成功', '已加载 ${channelData.length} 个频道');
    } catch (e) {
      Get.snackbar('错误', '加载M3U数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load statistics
  Future<void> _loadStats() async {
    try {
      totalChannels.value = await _channelDao.getTotalChannelCount();
    } catch (e) {
      print('加载统计信息失败: $e');
    }
  }

  // Clear all data
  Future<void> clearAllChannels() async {
    try {
      await _channelDao.deleteAllChannels();
      await loadChannels();
      Get.snackbar('成功', '已清空所有频道数据');
    } catch (e) {
      Get.snackbar('错误', '清空数据失败: $e');
    }
  }

  // Get Channel Information
  Channel? getChannelById(int id) {
    return channels.firstWhereOrNull((channel) => channel.id == id);
  }
}
