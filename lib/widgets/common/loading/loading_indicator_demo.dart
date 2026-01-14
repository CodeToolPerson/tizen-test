import 'package:flutter/material.dart';
import 'custom_loading_indicator.dart';

class LoadingIndicatorDemo extends StatefulWidget {
  const LoadingIndicatorDemo({super.key});

  @override
  State<LoadingIndicatorDemo> createState() => _LoadingIndicatorDemoState();
}

class _LoadingIndicatorDemoState extends State<LoadingIndicatorDemo> {
  bool _isAnimating = true;

  void _toggleAnimation() {
    setState(() {
      _isAnimating = !_isAnimating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 自定义加载指示器
                CustomLoadingIndicator(
                  size: 120.0,
                  color: Colors.white,
                  isAnimating: _isAnimating,
                ),
                const SizedBox(height: 40),
                // 控制按钮
                ElevatedButton(
                  onPressed: _toggleAnimation,
                  child: Text(_isAnimating ? '停止动画' : '开始动画'),
                ),
                const SizedBox(height: 20),
                // 显示当前状态
                Text(
                  '动画状态: ${_isAnimating ? "播放中" : "已停止"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}