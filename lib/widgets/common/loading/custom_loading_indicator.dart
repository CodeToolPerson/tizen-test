import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final bool isAnimating;

  const CustomLoadingIndicator({super.key, this.size = 120.0, this.color = Colors.white, this.isAnimating = true});

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  bool _isStopped = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // 动画速度
      vsync: this,
    );

    _animations = [Tween<double>(begin: 0.0, end: 8.0).animate(CurvedAnimation(parent: _controller, curve: Curves.linear))];

    if (widget.isAnimating) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _isStopped = false;
    _controller.repeat();
  }

  void _stopAnimation() {
    double currentValue = _animations[0].value;
    double remainingValue = 8.0 - (currentValue % 8.0);
    if (remainingValue == 0) remainingValue = 8.0;
    int remainingMs = (remainingValue / 8.0 * 1200).round();

    Future.delayed(Duration(milliseconds: remainingMs), () {
      if (mounted) {
        _controller.stop();
        setState(() {
          _isStopped = true;
        });
      }
    });
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
        child: AnimatedBuilder(
          animation: _animations[0],
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                if (_isStopped) {
                  final scale = 0.8;
                  final opacity = 1.0;
                  return Container(
                    width: widget.size / 4,
                    height: widget.size / 4,
                    alignment: Alignment.center,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: widget.size / 8,
                        height: widget.size / 8,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }
                final progress = _animations[0].value;
                final activeIndex = progress.floor() % 4;
                final distance = (index - activeIndex).abs();
                final isActive = distance <= 1.0;
                final intensity = isActive ? (1.0 - distance * 0.5) : 0.2;
                final scale = 0.7 + (intensity * 0.5);
                final opacity = 0.4 + (intensity * 0.6);
                return Container(
                  width: widget.size / 4,
                  height: widget.size / 4,
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.size / 8,
                      height: widget.size / 8,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: opacity),
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [BoxShadow(color: widget.color.withValues(alpha: 0.6), blurRadius: intensity * 8, spreadRadius: intensity * 2)]
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
