import 'package:flutter/widgets.dart';

/// A widget that creates a shimmer effect, often used as a loading placeholder.
class Shimmer extends StatefulWidget {
  /// Creates a shimmer effect widget.
  const Shimmer({super.key, this.height, this.width, this.borderRadius});

  /// The height of the shimmer effect.
  final double? height;

  /// The width of the shimmer effect.
  final double? width;

  /// The border radius of the shimmer effect.
  final BorderRadius? borderRadius;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  // grey[300], grey[100], grey[300]
  static const List<Color> _gradientColors = <Color>[
    Color(0xFFE0E0E0),
    Color(0xFFF5F5F5),
    Color(0xFFE0E0E0),
  ];

  // Colors.grey at 15% opacity.
  static const List<BoxShadow> _shadow = <BoxShadow>[
    BoxShadow(color: Color(0x269E9E9E), blurRadius: 5),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // The masked box never changes; build it once and reuse it every tick.
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: _gradientColors[0],
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          boxShadow: _shadow,
        ),
      ),
      builder: (_, Widget? child) {
        final double t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect rect) => LinearGradient(
            colors: _gradientColors,
            stops: <double>[
              (t - 0.2).clamp(0.0, 1.0),
              t,
              (t + 0.2).clamp(0.0, 1.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}
