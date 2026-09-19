import 'package:flutter/widgets.dart';

import 'svg_document.dart';

/// Renders an SVG string with the package's built-in renderer.
///
/// See [SvgDocument] for the supported feature set.
class AnySvg extends StatefulWidget {
  /// Renders [source], an SVG document as text.
  const AnySvg.string(
    this.source, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.colorFilter,
    this.currentColor = const Color(0xFF000000),
    this.errorBuilder,
  });

  /// The SVG markup.
  final String source;

  /// Requested width; defaults to the document's own size.
  final double? width;

  /// Requested height; defaults to the document's own size.
  final double? height;

  /// How the drawing is fitted into the available box.
  final BoxFit fit;

  /// Where the drawing sits when [fit] leaves empty space.
  final Alignment alignment;

  /// Optional filter applied to the whole drawing (e.g. a tint).
  final ColorFilter? colorFilter;

  /// Value used for `currentColor` in the document.
  final Color currentColor;

  /// Built instead of the drawing when [source] cannot be parsed.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  State<AnySvg> createState() => _AnySvgState();
}

class _AnySvgState extends State<AnySvg> {
  SvgDocument? _document;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(AnySvg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source ||
        oldWidget.currentColor != widget.currentColor) {
      _document?.dispose();
      _document = null;
      _error = null;
      _parse();
    }
  }

  void _parse() {
    try {
      _document = SvgDocument.parse(
        widget.source,
        currentColor: widget.currentColor,
      );
    } catch (e) {
      _error = e;
    }
  }

  @override
  void dispose() {
    _document?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SvgDocument? doc = _document;
    if (doc == null) {
      final Widget Function(BuildContext, Object)? builder =
          widget.errorBuilder;
      return builder == null
          ? const SizedBox.shrink()
          : builder(context, _error ?? 'invalid SVG');
    }
    Widget child = CustomPaint(
      size: doc.size,
      painter: _SvgPainter(
        doc,
        widget.fit,
        widget.alignment,
        widget.colorFilter,
      ),
    );
    if ((widget.width == null) != (widget.height == null) &&
        doc.size.height > 0) {
      child = AspectRatio(
        aspectRatio: doc.size.width / doc.size.height,
        child: child,
      );
    }
    return SizedBox(width: widget.width, height: widget.height, child: child);
  }
}

class _SvgPainter extends CustomPainter {
  const _SvgPainter(this.document, this.fit, this.alignment, this.colorFilter);

  final SvgDocument document;
  final BoxFit fit;
  final Alignment alignment;
  final ColorFilter? colorFilter;

  @override
  void paint(Canvas canvas, Size size) => document.paint(
    canvas,
    size,
    fit: fit,
    alignment: alignment,
    colorFilter: colorFilter,
  );

  @override
  bool shouldRepaint(_SvgPainter old) =>
      old.document != document ||
      old.fit != fit ||
      old.alignment != alignment ||
      old.colorFilter != colorFilter;
}
