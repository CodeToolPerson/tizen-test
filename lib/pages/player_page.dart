import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:get/get.dart';

class PlayerPage extends StatefulWidget {
  final String title;
  final String url;
  final dynamic channel;

  const PlayerPage({super.key, required this.title, required this.url, this.channel});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  BetterPlayerController? _betterPlayerController;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isInitialized = false;
        _errorMessage = null;
      });

      if (widget.url.startsWith('rtp://')) {
        throw Exception('RTP 流媒体暂不支持，请使用 HTTP/HTTPS 流媒体源');
      }

      await _initializeBetterPlayer();

      setState(() {
        _isInitialized = true;
        _errorMessage = null;
      });

      print('播放器初始化成功: ${widget.title}');
    } catch (e) {
      print('播放器初始化失败: $e');
      setState(() {
        _errorMessage = e.toString();
        _isInitialized = false;
      });
    }
  }

  Future<void> _initializeBetterPlayer() async {
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'},
      useAsmsSubtitles: true,
      useAsmsTracks: true,
      useAsmsAudioTracks: true,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 25000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2500,
      ),
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        fullScreenByDefault: false,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: true,
          enableSkips: true,
          enableFullscreen: true,
          enableSubtitles: true,
          enableAudioTracks: true,
          enableQualities: true,
          enablePlayPause: true,
          enableProgressBar: true,
          enableMute: true,
          showControlsOnInitialize: true,
          controlsHideTime: Duration(seconds: 3),
          playerTheme: BetterPlayerTheme.material,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('正在加载...', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    '播放失败',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage ?? '未知错误',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _retryPlayback,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await _betterPlayerController!
        .setupDataSource(dataSource)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('播放器初始化超时');
          },
        );
  }

  void _retryPlayback() {
    _disposeControllers();
    _initializePlayer();
  }

  void _disposeControllers() {
    _betterPlayerController?.dispose();
    _betterPlayerController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _retryPlayback, tooltip: '重试'),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: _showStreamInfo, tooltip: '流信息'),
        ],
      ),
      body: Container(color: Colors.black, child: _buildPlayerContent()),
    );
  }

  Widget _buildPlayerContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              '播放失败',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _retryPlayback,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                ),
                OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _betterPlayerController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('正在初始化播放器...', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        BetterPlayer(controller: _betterPlayerController!),

        if (widget.channel != null) Positioned(left: 16, bottom: 120, right: 16, child: _buildChannelInfo()),
      ],
    );
  }

  Widget _buildChannelInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.channel.tvgName,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('${widget.channel.groupTitle} • ${widget.channel.definition ?? '未知'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showStreamInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('流信息'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('频道名称', widget.channel?.tvgName ?? '未知'),
              _infoRow('分组', widget.channel?.groupTitle ?? '未知'),
              _infoRow('清晰度', widget.channel?.definition ?? '未知'),
              _infoRow('支持回看', widget.channel?.hasCatchup == true ? '是' : '否'),
              const SizedBox(height: 16),
              const Text('播放地址:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                child: Text(widget.url, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
              if (widget.channel?.catchupSource != null) ...[
                const SizedBox(height: 16),
                const Text('回看地址:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                  child: Text(widget.channel!.catchupSource!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('关闭'))],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
