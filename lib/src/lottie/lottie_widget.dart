import 'package:flutter/widgets.dart';

import 'lottie_composition.dart';

/// Plays a [LottieComposition] with the package's built-in renderer.
class AnyLottie extends StatefulWidget {
  /// Plays [composition].
  const AnyLottie({
    super.key,
    required this.composition,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.repeat = true,
    this.animate = true,
  });

  /// The animation to render. The widget does not take ownership: dispose it
  /// yourself once no widget uses it.
  final LottieComposition composition;

  /// Requested width; defaults to the composition size.
  final double? width;

  /// Requested height; defaults to the composition size.
  final double? height;

  /// How the composition is fitted into the available box.
  final BoxFit fit;

  /// Where the composition sits when [fit] leaves empty space.
  final Alignment alignment;

  /// Whether to loop.
  final bool repeat;

  /// Whether to play at all; `false` shows the first frame.
  final bool animate;

  @override
  State<AnyLottie> createState() => _AnyLottieState();
}

class _AnyLottieState extends State<AnyLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _configure();
  }

  @override
  void didUpdateWidget(AnyLottie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.composition != widget.composition ||
        oldWidget.repeat != widget.repeat ||
        oldWidget.animate != widget.animate) {
      _configure();
    }
  }

  void _configure() {
    _controller
      ..stop()
      ..duration = widget.composition.duration
      ..value = 0;
    if (!widget.animate) return;
    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = widget.composition.size;
    Widget child = CustomPaint(
      size: size,
      painter: _LottiePainter(
        widget.composition,
        _controller,
        widget.fit,
        widget.alignment,
      ),
    );
    if ((widget.width == null) != (widget.height == null) && size.height > 0) {
      child = AspectRatio(aspectRatio: size.width / size.height, child: child);
    }
    return SizedBox(width: widget.width, height: widget.height, child: child);
  }
}

class _LottiePainter extends CustomPainter {
  _LottiePainter(this.composition, this.progress, this.fit, this.alignment)
    : super(repaint: progress);

  final LottieComposition composition;
  final Animation<double> progress;
  final BoxFit fit;
  final Alignment alignment;

  @override
  void paint(Canvas canvas, Size size) {
    final double frame =
        composition.inPoint +
        progress.value * (composition.outPoint - composition.inPoint);
    composition.paint(canvas, size, frame, fit: fit, alignment: alignment);
  }

  @override
  bool shouldRepaint(_LottiePainter old) =>
      old.composition != composition ||
      old.fit != fit ||
      old.alignment != alignment ||
      old.progress != progress;
}
