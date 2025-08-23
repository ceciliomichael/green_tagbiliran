import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class LoadingIndicator extends StatefulWidget {
  final Color? color;
  final double size;

  const LoadingIndicator({super.key, this.color, this.size = 32.0});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller1, curve: Curves.easeInOut));

    _animation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller2, curve: Curves.easeInOut));

    _animation3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller3, curve: Curves.easeInOut));

    _startAnimations();
  }

  void _startAnimations() {
    _controller1.repeat();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller2.repeat();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller3.repeat();
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.pureWhite;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) {
              return Container(
                width: widget.size * (0.8 + 0.2 * _animation1.value),
                height: widget.size * (0.8 + 0.2 * _animation1.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1 * (1 - _animation1.value)),
                  border: Border.all(
                    color: color.withValues(
                      alpha: 0.3 * (1 - _animation1.value),
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),

          // Middle circle
          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Container(
                width: widget.size * (0.6 + 0.2 * _animation2.value),
                height: widget.size * (0.6 + 0.2 * _animation2.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(
                    alpha: 0.15 * (1 - _animation2.value),
                  ),
                  border: Border.all(
                    color: color.withValues(
                      alpha: 0.4 * (1 - _animation2.value),
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),

          // Inner circle
          AnimatedBuilder(
            animation: _animation3,
            builder: (context, child) {
              return Container(
                width: widget.size * (0.4 + 0.2 * _animation3.value),
                height: widget.size * (0.4 + 0.2 * _animation3.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2 * (1 - _animation3.value)),
                  border: Border.all(
                    color: color.withValues(
                      alpha: 0.5 * (1 - _animation3.value),
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),

          // Central dot
          Container(
            width: widget.size * 0.2,
            height: widget.size * 0.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
