import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../database/database.dart';
import '../utils/data_generator.dart';

class DataGeneratorPage extends StatefulWidget {
  const DataGeneratorPage({super.key});

  @override
  State<DataGeneratorPage> createState() => _DataGeneratorPageState();
}

class _DataGeneratorPageState extends State<DataGeneratorPage> {
  // 默认模拟 Xtream Code 数据量
  int _liveCount = 35000;
  int _vodCount = 150000;
  int _seriesCount = 40000;

  bool _isGenerating = false;
  String _currentStage = '';
  int _currentProgress = 0;
  int _totalProgress = 0;
  String _statusMessage = '';

  final Stopwatch _stopwatch = Stopwatch();

  // 当前数据统计
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await AppDatabase.getAllStatistics();
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _generateData() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
      _statusMessage = '准备生成数据...';
    });

    _stopwatch.reset();
    _stopwatch.start();

    try {
      // 清空现有数据
      setState(() => _statusMessage = '清空现有数据...');
      await AppDatabase.deleteAllData();

      // 生成直播频道
      setState(() => _statusMessage = '生成直播频道数据...');
      final channels = await DataGenerator.generateLiveChannels(
        _liveCount,
        onProgress: (stage, current, total) {
          setState(() {
            _currentStage = stage;
            _currentProgress = current;
            _totalProgress = total;
          });
        },
      );

      // 批量写入直播频道
      setState(() => _statusMessage = '写入直播频道数据...');
      await _batchInsert(channels, AppDatabase.insertChannels, 5000, '写入直播');

      // 生成 VOD 电影
      setState(() => _statusMessage = '生成电影数据...');
      final vodItems = await DataGenerator.generateVodItems(
        _vodCount,
        onProgress: (stage, current, total) {
          setState(() {
            _currentStage = stage;
            _currentProgress = current;
            _totalProgress = total;
          });
        },
      );

      // 批量写入 VOD
      setState(() => _statusMessage = '写入电影数据...');
      await _batchInsert(vodItems, AppDatabase.insertVodItems, 5000, '写入电影');

      // 生成剧集
      setState(() => _statusMessage = '生成剧集数据...');
      final seriesItems = await DataGenerator.generateSeriesItems(
        _seriesCount,
        onProgress: (stage, current, total) {
          setState(() {
            _currentStage = stage;
            _currentProgress = current;
            _totalProgress = total;
          });
        },
      );

      // 批量写入剧集
      setState(() => _statusMessage = '写入剧集数据...');
      await _batchInsert(seriesItems, AppDatabase.insertSeriesItems, 5000, '写入剧集');

      _stopwatch.stop();

      await _loadStats();

      setState(() {
        _isGenerating = false;
        _statusMessage = '数据生成完成！耗时: ${_formatDuration(_stopwatch.elapsed)}';
      });

      Get.snackbar(
        '完成',
        '数据生成成功，耗时 ${_formatDuration(_stopwatch.elapsed)}',
        duration: const Duration(seconds: 3),
      );

      // 延迟后跳转到首页
      await Future.delayed(const Duration(seconds: 1));
      Get.back(result: true); // 返回首页并通知刷新
    } catch (e) {
      _stopwatch.stop();
      setState(() {
        _isGenerating = false;
        _statusMessage = '生成失败: $e';
      });
      Get.snackbar('错误', '数据生成失败: $e');
    }
  }

  Future<void> _batchInsert<T>(
    List<T> items,
    Future<void> Function(List<T>) insertFn,
    int batchSize,
    String label,
  ) async {
    for (int i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize > items.length) ? items.length : i + batchSize;
      final batch = items.sublist(i, end);
      await insertFn(batch);

      setState(() {
        _currentStage = label;
        _currentProgress = end;
        _totalProgress = items.length;
      });

      await Future.delayed(Duration.zero);
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _statusMessage = '正在清空数据...');
      await AppDatabase.deleteAllData();
      await _loadStats();
      setState(() => _statusMessage = '数据已清空');
      Get.snackbar('完成', '所有数据已清空');
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes >= 1) {
      return '${duration.inMinutes}分${duration.inSeconds % 60}秒';
    }
    return '${duration.inSeconds}秒';
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据生成器'),
        actions: [
          _buildTVButton(
            icon: Icons.refresh,
            onPressed: _loadStats,
            tooltip: '刷新统计',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 当前数据统计
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('当前数据统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('直播', _stats['channels'] ?? 0, Colors.blue),
                        _buildStatItem('电影', _stats['vod'] ?? 0, Colors.green),
                        _buildStatItem('剧集', _stats['series'] ?? 0, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 数据量设置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('模拟 Xtream Code 数据量', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildCountSelector('直播频道', _liveCount, 1000, 50000, 1000, (v) => setState(() => _liveCount = v)),
                    const SizedBox(height: 12),
                    _buildCountSelector('电影 VOD', _vodCount, 10000, 200000, 10000, (v) => setState(() => _vodCount = v)),
                    const SizedBox(height: 12),
                    _buildCountSelector('剧集', _seriesCount, 5000, 100000, 5000, (v) => setState(() => _seriesCount = v)),
                    const SizedBox(height: 16),
                    Text(
                      '总计: ${_formatNumber(_liveCount + _vodCount + _seriesCount)} 条记录',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 进度显示
            if (_isGenerating || _statusMessage.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_statusMessage),
                      if (_isGenerating && _totalProgress > 0) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: _currentProgress / _totalProgress),
                        const SizedBox(height: 4),
                        Text('$_currentStage: $_currentProgress / $_totalProgress'),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.play_arrow,
                    label: '生成数据',
                    color: Colors.green,
                    onPressed: _isGenerating ? null : _generateData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete,
                    label: '清空数据',
                    color: Colors.red,
                    onPressed: _isGenerating ? null : _clearAllData,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 说明
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('说明', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• 直播频道：模拟 IPTV 直播源'),
                    Text('• 电影 VOD：模拟点播电影'),
                    Text('• 剧集：模拟电视剧/综艺节目的每一集'),
                    SizedBox(height: 8),
                    Text('提示：大量数据写入可能需要较长时间'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          _formatNumber(value),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  /// TV 友好的 AppBar 按钮
  Widget _buildTVButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: hasFocus ? Border.all(color: Colors.yellow, width: 3) : null,
              borderRadius: BorderRadius.circular(8),
              color: hasFocus ? Colors.yellow.withValues(alpha: 0.3) : null,
            ),
            child: IconButton(
              icon: Icon(icon),
              onPressed: onPressed,
              tooltip: tooltip,
            ),
          );
        },
      ),
    );
  }

  /// TV 友好的操作按钮（焦点时高亮明显）
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: hasFocus ? Border.all(color: Colors.yellow, width: 4) : null,
              boxShadow: hasFocus
                  ? [BoxShadow(color: Colors.yellow.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)]
                  : null,
            ),
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label, style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasFocus ? color.withValues(alpha: 0.9) : color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          );
        },
      ),
    );
  }

  /// TV 友好的数量选择器
  Widget _buildCountSelector(
    String label,
    int value,
    int min,
    int max,
    int step,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        _buildCountButton(
          icon: Icons.remove_circle,
          onPressed: _isGenerating || value <= min
              ? null
              : () => onChanged((value - step).clamp(min, max)),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            _formatNumber(value),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 12),
        _buildCountButton(
          icon: Icons.add_circle,
          onPressed: _isGenerating || value >= max
              ? null
              : () => onChanged((value + step).clamp(min, max)),
        ),
        const SizedBox(width: 24),
        // 快捷预设按钮
        _buildPresetButton('最小', min, value, onChanged),
        const SizedBox(width: 8),
        _buildPresetButton('中等', (min + max) ~/ 2, value, onChanged),
        const SizedBox(width: 8),
        _buildPresetButton('最大', max, value, onChanged),
      ],
    );
  }

  /// TV 友好的 +/- 按钮
  Widget _buildCountButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: hasFocus ? Border.all(color: Colors.yellow, width: 3) : null,
              boxShadow: hasFocus
                  ? [BoxShadow(color: Colors.yellow.withValues(alpha: 0.5), blurRadius: 8)]
                  : null,
            ),
            child: IconButton(
              icon: Icon(icon, size: 32, color: hasFocus ? Colors.blue : null),
              onPressed: onPressed,
            ),
          );
        },
      ),
    );
  }

  /// TV 友好的预设按钮
  Widget _buildPresetButton(String label, int presetValue, int currentValue, ValueChanged<int> onChanged) {
    final isSelected = currentValue == presetValue;
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: hasFocus ? Border.all(color: Colors.yellow, width: 3) : null,
              boxShadow: hasFocus
                  ? [BoxShadow(color: Colors.yellow.withValues(alpha: 0.5), blurRadius: 8)]
                  : null,
            ),
            child: OutlinedButton(
              onPressed: _isGenerating ? null : () => onChanged(presetValue),
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : (hasFocus ? Colors.blue.withValues(alpha: 0.2) : null),
                foregroundColor: isSelected ? Colors.white : (hasFocus ? Colors.blue : null),
                side: BorderSide(color: isSelected || hasFocus ? Colors.blue : Colors.grey, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}
