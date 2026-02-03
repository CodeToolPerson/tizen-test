import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/channel_controller.dart';
import '../database/database.dart';
import '../widgets/channel/channel_item.dart';
import 'data_generator_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ChannelController channelController = Get.put(ChannelController());
  
  late TabController _tabController;
  
  // VOD 和 剧集数据
  List<VodItem> _vodItems = [];
  List<SeriesItem> _seriesItems = [];
  bool _isLoadingVod = false;
  bool _isLoadingSeries = false;
  
  // 统计数据
  int _vodCount = 0;
  int _seriesCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAllStats();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    switch (_tabController.index) {
      case 1:
        if (_vodItems.isEmpty && _vodCount > 0) _loadVodItems();
        break;
      case 2:
        if (_seriesItems.isEmpty && _seriesCount > 0) _loadSeriesItems();
        break;
    }
  }

  Future<void> _loadAllStats() async {
    final stats = await AppDatabase.getAllStatistics();
    setState(() {
      _vodCount = stats['vod'] ?? 0;
      _seriesCount = stats['series'] ?? 0;
    });
    // 预加载当前标签数据
    _onTabChanged();
  }

  Future<void> _loadVodItems() async {
    if (_isLoadingVod) return;
    setState(() => _isLoadingVod = true);
    try {
      final items = await AppDatabase.getAllVodItems();
      setState(() {
        _vodItems = items;
        _vodCount = items.length;
      });
    } catch (e) {
      Get.snackbar('错误', '加载电影失败: $e');
    } finally {
      setState(() => _isLoadingVod = false);
    }
  }

  Future<void> _loadSeriesItems() async {
    if (_isLoadingSeries) return;
    setState(() => _isLoadingSeries = true);
    try {
      final items = await AppDatabase.getAllSeriesItems();
      setState(() {
        _seriesItems = items;
        _seriesCount = items.length;
      });
    } catch (e) {
      Get.snackbar('错误', '加载剧集失败: $e');
    } finally {
      setState(() => _isLoadingSeries = false);
    }
  }

  Future<void> _refreshAll() async {
    await channelController.loadChannels();
    _vodItems = [];
    _seriesItems = [];
    await _loadAllStats();
  }

  void _openDataGenerator() {
    Get.to(() => const DataGeneratorPage())?.then((result) {
      if (result == true) {
        _refreshAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPTV 播放器'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Obx(() => Tab(text: '直播 (${channelController.totalChannels.value})')),
            Tab(text: '电影 ($_vodCount)'),
            Tab(text: '剧集 ($_seriesCount)'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: _openDataGenerator,
            tooltip: '数据生成器',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveTab(),
          _buildVodTab(),
          _buildSeriesTab(),
        ],
      ),
    );
  }

  // 直播频道标签页
  Widget _buildLiveTab() {
    return Obx(() {
      if (channelController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (channelController.channels.isEmpty) {
        return _buildEmptyState('暂无直播频道', Icons.live_tv);
      }

      return ListView.builder(
        itemCount: channelController.channels.length,
        itemBuilder: (context, index) {
          final channel = channelController.channels[index];
          return ChannelItem(channel: channel);
        },
      );
    });
  }

  // 电影标签页 - 网格布局
  Widget _buildVodTab() {
    if (_isLoadingVod) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vodItems.isEmpty) {
      // 如果有数据但还没加载，显示加载中
      if (_vodCount > 0) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildEmptyState('暂无电影数据', Icons.movie);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 每行5个
        childAspectRatio: 0.45, // 2:3海报 + 文字区域
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _vodItems.length,
      itemBuilder: (context, index) {
        final item = _vodItems[index];
        return _buildVodGridItem(item);
      },
    );
  }

  Widget _buildVodGridItem(VodItem item) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: () {
              Get.snackbar('提示', '播放: ${item.name}');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: hasFocus ? Border.all(color: Colors.yellow, width: 3) : null,
                boxShadow: hasFocus
                    ? [BoxShadow(color: Colors.yellow.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 封面图 - 2:3 比例
                  AspectRatio(
                    aspectRatio: 2 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildNetworkImage(
                        item.streamIcon,
                        double.infinity,
                        double.infinity,
                        Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 标题
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: hasFocus ? Colors.yellow : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 信息
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${item.categoryName} • ⭐${item.rating ?? 0}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 剧集标签页 - 网格布局
  Widget _buildSeriesTab() {
    if (_isLoadingSeries) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_seriesItems.isEmpty) {
      // 如果有数据但还没加载，显示加载中
      if (_seriesCount > 0) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildEmptyState('暂无剧集数据', Icons.tv);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 每行5个
        childAspectRatio: 0.45, // 2:3海报 + 文字区域
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _seriesItems.length,
      itemBuilder: (context, index) {
        final item = _seriesItems[index];
        return _buildSeriesGridItem(item);
      },
    );
  }

  Widget _buildSeriesGridItem(SeriesItem item) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: () {
              Get.snackbar('提示', '播放: ${item.title}');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: hasFocus ? Border.all(color: Colors.yellow, width: 3) : null,
                boxShadow: hasFocus
                    ? [BoxShadow(color: Colors.yellow.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 封面图 - 2:3 比例
                  AspectRatio(
                    aspectRatio: 2 / 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildNetworkImage(
                            item.cover,
                            double.infinity,
                            double.infinity,
                            Colors.orange,
                          ),
                        ),
                        // 集数标签
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'S${item.seasonNumber}E${item.episodeNumber}',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 标题
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      item.seriesName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: hasFocus ? Colors.yellow : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 信息
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${item.categoryName} • ${item.duration ?? 0}分钟',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openDataGenerator,
            icon: const Icon(Icons.add),
            label: const Text('生成测试数据'),
          ),
        ],
      ),
    );
  }

  /// 构建网络图片组件
  Widget _buildNetworkImage(String? url, double width, double height, Color fallbackColor) {
    if (url == null || url.isEmpty) {
      return _buildImagePlaceholder(width, height, fallbackColor);
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder(width, height, fallbackColor);
      },
    );
  }

  Widget _buildImagePlaceholder(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, color: color, size: 32),
    );
  }
}
