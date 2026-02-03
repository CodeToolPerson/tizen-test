import 'dart:math';
import '../database/channel.dart';
import '../database/vod_item.dart';
import '../database/series_item.dart';

// 生成器回调，用于报告进度
typedef ProgressCallback = void Function(String stage, int current, int total);

/// 模拟 Xtream Code 数据生成器
class DataGenerator {
  static final _random = Random();

  // 直播频道分类
  static const _liveCategories = [
    '体育频道',
    '新闻频道',
    '电影频道',
    '综艺频道',
    '少儿频道',
    '纪录片',
    '音乐频道',
    '国际频道',
    '地方频道',
    '高清频道',
    '4K频道',
    '付费频道',
  ];

  // 电影分类
  static const _vodCategories = [
    '动作片',
    '喜剧片',
    '爱情片',
    '科幻片',
    '恐怖片',
    '战争片',
    '动画片',
    '纪录片',
    '悬疑片',
    '剧情片',
    '冒险片',
    '奇幻片',
    '犯罪片',
    '历史片',
    '传记片',
  ];

  // 剧集分类
  static const _seriesCategories = [
    '国产剧',
    '美剧',
    '韩剧',
    '日剧',
    '港台剧',
    '泰剧',
    '英剧',
    '综艺节目',
    '动漫',
    '纪录片',
  ];

  // 剧名列表
  static const _seriesNames = [
    '权力的游戏',
    '绝命毒师',
    '老友记',
    '甄嬛传',
    '琅琊榜',
    '三体',
    '狂飙',
    '人世间',
    '鱿鱼游戏',
    '爱的迫降',
    '请回答1988',
    '半泽直树',
    '东京爱情故事',
    '黑镜',
    '神探夏洛克',
    '王冠',
    '纸牌屋',
    '西部世界',
    '怪奇物语',
    '曼达洛人',
  ];

  /// 生成直播频道数据
  static Future<List<Channel>> generateLiveChannels(
    int count, {
    ProgressCallback? onProgress,
  }) async {
    final channels = <Channel>[];
    final batchSize = 1000;

    for (int i = 0; i < count; i++) {
      final categoryIndex = i % _liveCategories.length;
      final category = _liveCategories[categoryIndex];
      final channelNum = i + 1;

      channels.add(Channel()
        ..channelNumber = channelNum
        ..tvgId = 'live_$channelNum'
        ..tvgName = '${category}_频道$channelNum'
        ..tvgLogo = 'https://picsum.photos/seed/live$channelNum/100/100'
        ..groupTitle = category
        ..streamUrl = 'http://stream.example.com/live/$channelNum/index.m3u8'
        ..definition = _randomDefinition()
        ..catchupSource = _random.nextBool() ? 'http://catchup.example.com/live/$channelNum' : null
        ..hasCatchup = _random.nextBool()
        ..createdAt = DateTime.now());

      if ((i + 1) % batchSize == 0 || i == count - 1) {
        onProgress?.call('直播频道', i + 1, count);
        await Future.delayed(Duration.zero);
      }
    }

    return channels;
  }

  /// 生成 VOD 电影数据
  static Future<List<VodItem>> generateVodItems(
    int count, {
    ProgressCallback? onProgress,
  }) async {
    final items = <VodItem>[];
    final batchSize = 1000;

    for (int i = 0; i < count; i++) {
      final categoryIndex = i % _vodCategories.length;
      final category = _vodCategories[categoryIndex];
      final movieId = i + 1;
      final year = 1980 + _random.nextInt(45);

      items.add(VodItem()
        ..streamId = movieId
        ..name = '${_randomMoviePrefix()}$movieId ($year)'
        ..streamIcon = 'https://picsum.photos/seed/vod$movieId/200/300'
        ..categoryId = 'vod_cat_$categoryIndex'
        ..categoryName = category
        ..containerExtension = _randomExtension()
        ..plot = '这是电影$movieId的剧情简介，讲述了一个精彩的故事...'
        ..cast = '演员A, 演员B, 演员C'
        ..director = '导演$movieId'
        ..genre = category
        ..releaseDate = '$year-${_random.nextInt(12) + 1}-${_random.nextInt(28) + 1}'
        ..rating = (_random.nextDouble() * 4 + 6).roundToDouble()
        ..duration = 80 + _random.nextInt(80)
        ..streamUrl = 'http://vod.example.com/movie/$movieId/stream.${_randomExtension()}'
        ..addedAt = DateTime.now().subtract(Duration(days: _random.nextInt(365))));

      if ((i + 1) % batchSize == 0 || i == count - 1) {
        onProgress?.call('电影', i + 1, count);
        await Future.delayed(Duration.zero);
      }
    }

    return items;
  }

  /// 生成剧集数据（每条记录代表一集）
  static Future<List<SeriesItem>> generateSeriesItems(
    int count, {
    ProgressCallback? onProgress,
  }) async {
    final items = <SeriesItem>[];
    final batchSize = 1000;

    for (int i = 0; i < count; i++) {
      final categoryIndex = i % _seriesCategories.length;
      final category = _seriesCategories[categoryIndex];
      final seriesNameIndex = i % _seriesNames.length;
      final seriesName = '${_seriesNames[seriesNameIndex]}${i ~/ _seriesNames.length + 1}';
      final seasonNumber = (i % 10) + 1;
      final episodeNumber = (i % 24) + 1;
      final episodeId = i + 1;

      items.add(SeriesItem()
        ..episodeId = episodeId
        ..seriesName = seriesName
        ..seasonNumber = seasonNumber
        ..episodeNumber = episodeNumber
        ..title = '$seriesName S${seasonNumber.toString().padLeft(2, '0')}E${episodeNumber.toString().padLeft(2, '0')}'
        ..cover = 'https://picsum.photos/seed/ep$episodeId/200/300'
        ..categoryId = 'series_cat_$categoryIndex'
        ..categoryName = category
        ..plot = '$seriesName 第$seasonNumber季第$episodeNumber集剧情简介...'
        ..rating = (_random.nextDouble() * 3 + 7).roundToDouble()
        ..duration = 20 + _random.nextInt(40)
        ..streamUrl = 'http://vod.example.com/series/$episodeId/stream.mp4'
        ..containerExtension = 'mp4'
        ..addedAt = DateTime.now().subtract(Duration(days: _random.nextInt(365))));

      if ((i + 1) % batchSize == 0 || i == count - 1) {
        onProgress?.call('剧集', i + 1, count);
        await Future.delayed(Duration.zero);
      }
    }

    return items;
  }

  static String _randomDefinition() {
    final defs = ['SD', 'HD', 'FHD', '4K', '8K'];
    return defs[_random.nextInt(defs.length)];
  }

  static String _randomExtension() {
    final exts = ['mp4', 'mkv', 'avi', 'ts'];
    return exts[_random.nextInt(exts.length)];
  }

  static String _randomMoviePrefix() {
    final prefixes = ['精彩电影', '热门影片', '经典大片', '新上映', '高分佳作'];
    return prefixes[_random.nextInt(prefixes.length)];
  }
}
