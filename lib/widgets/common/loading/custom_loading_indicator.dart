import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final bool isAnimating;

  const CustomLoadingIndicator({
    super.key,
    this.size = 120.0,
    this.color = Colors.white,
    this.isAnimating = true,
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animations = List.generate(4, (index) {
      final delay = index * 0.2; // 调整延迟间隔
      final end = (delay + 0.5).clamp(0.0, 1.0); // 确保end不超过1.0
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, end, curve: Curves.easeInOut),
        ),
      );
    });

    if (widget.isAnimating) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _controller.repeat(reverse: true);
  }

  void _stopAnimation() {
    _controller.stop();
  }

  @override
  void didUpdateWidget(CustomLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAnimating != widget.isAnimating) {
      if (widget.isAnimating) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final scale = 0.5 + (_animations[index].value * 0.5);
                final opacity = 0.3 + (_animations[index].value * 0.7);

                return Container(
                  width: widget.size / 4, // 增大容器宽度，为缩放留出空间
                  height: widget.size / 4, // 增大容器高度，为缩放留出空间
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.size / 8,
                      height: widget.size / 8,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}