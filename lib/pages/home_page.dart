import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/channel_controller.dart';
import '../widgets/channel/channel_item.dart';

class HomePage extends StatelessWidget {
  final ChannelController controller = Get.put(ChannelController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPTV 频道列表'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => controller.loadChannels()),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'load_m3u_text':
                  _showM3UInputDialog(context);
                  break;
                case 'clear':
                  _showClearConfirmDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'load_m3u_text', child: Text('从M3U文本加载')),
              const PopupMenuItem(value: 'clear', child: Text('清空所有数据')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.channels.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tv, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('暂无频道数据', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showM3UInputDialog(context),
                        icon: const Icon(Icons.content_paste),
                        label: const Text('导入M3U数据'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.channels.length,
                itemBuilder: (context, index) {
                  final channel = controller.channels[index];
                  return ChannelItem(channel: channel);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildStatItem('总频道数', controller.totalChannels.value, Colors.blue)]),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  void _showM3UInputDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入M3U内容'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: TextField(
            controller: textController,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(hintText: '请粘贴M3U格式的直播源内容...', border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final m3uContent = textController.text.trim();
              if (m3uContent.isNotEmpty) {
                controller.loadFromM3UString(m3uContent);
                Navigator.of(context).pop();
              }
            },
            child: const Text('加载'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有频道数据吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              controller.clearAllChannels();
              Navigator.of(context).pop();
            },
            child: const Text('清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
