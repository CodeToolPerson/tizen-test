import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tizentest/pages/player_page.dart';

class ChannelItem extends StatefulWidget {
  final dynamic channel;

  const ChannelItem({super.key, required this.channel});

  @override
  State<ChannelItem> createState() => _ChannelItemState();
}

class _ChannelItemState extends State<ChannelItem> {
  bool _imageLoadFailed = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: widget.channel.tvgLogo != null && widget.channel.tvgLogo!.isNotEmpty && !_imageLoadFailed
              ? ClipOval(
                  child: Image.network(
                    widget.channel.tvgLogo!,
                    fit: BoxFit.cover,
                    headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'},
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _imageLoadFailed = true;
                          });
                        }
                      });
                      return Container(); // This won't be displayed because we will rebuild.
                    },
                  ),
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Text(
                    widget.channel.channelNumber.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
        ),
        title: Text(widget.channel.tvgName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${widget.channel.groupTitle} • ${widget.channel.definition ?? '未知'}'),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.blue),
          onPressed: () => _playChannel(context),
          tooltip: '播放频道',
        ),
        onTap: () => _playChannel(context),
      ),
    );
  }

  void _playChannel(BuildContext context) {
    print('尝试播放频道: ${widget.channel.tvgName}');
    print('播放地址: ${widget.channel.streamUrl}');

    final url = Uri.tryParse(widget.channel.streamUrl);
    if (url == null || (!url.scheme.startsWith('http') && !url.scheme.startsWith('rt'))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('播放地址格式不正确')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('正在启动播放器: ${widget.channel.tvgName}'), duration: const Duration(seconds: 2)));

    Get.to(() => PlayerPage(title: widget.channel.tvgName, url: widget.channel.streamUrl, channel: widget.channel));
  }
}
