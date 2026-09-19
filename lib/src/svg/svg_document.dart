/// A compact SVG renderer covering the static subset used by icons and
/// illustrations: paths and basic shapes, groups, `use`/`symbol`, transforms,
/// solid and gradient fills, strokes with dashes, opacity, `clip-path`,
/// presentation attributes, inline `style` and simple `<style>` rules.
///
/// Not supported: text, filters, masks, patterns, markers, embedded images,
/// CSS combinators and animation. Those elements are skipped silently.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../xml.dart';
import 'svg_values.dart';

/// A parsed, pre-rendered SVG document.
class SvgDocument {
  SvgDocument._(this._picture, this.viewBox, this.intrinsicSize, this.stretch);

  final ui.Picture _picture;

  /// The user-space rectangle mapped onto the widget.
  final Rect viewBox;

  /// The `width`/`height` attributes when both are absolute lengths.
  final Size? intrinsicSize;

  /// True when `preserveAspectRatio="none"`: always fill the box.
  final bool stretch;

  /// Preferred size: [intrinsicSize] if known, else the [viewBox] size.
  Size get size => intrinsicSize ?? viewBox.size;

  /// Parses [source]. Throws [FormatException] or [XmlParseException] when the
  /// document cannot be rendered at all.
  ///
  /// [currentColor] resolves `currentColor` paint values.
  factory SvgDocument.parse(
    String source, {
    Color currentColor = const Color(0xFF000000),
  }) {
    final XmlElement root = parseXml(source);
    if (root.name != 'svg') {
      throw FormatException('root element is <${root.name}>, expected <svg>');
    }
    return _SvgBuilder(root, currentColor).build();
  }

  /// Draws the document into [size] on [canvas].
  void paint(
    Canvas canvas,
    Size size, {
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    ColorFilter? colorFilter,
  }) {
    if (size.isEmpty || viewBox.isEmpty) return;
    final FittedSizes sizes = applyBoxFit(
      stretch ? BoxFit.fill : fit,
      viewBox.size,
      size,
    );
    final Rect dest = alignment.inscribe(sizes.destination, Offset.zero & size);
    canvas.save();
    if (colorFilter != null) {
      canvas.saveLayer(dest, Paint()..colorFilter = colorFilter);
    }
    canvas.clipRect(dest);
    canvas.translate(dest.left, dest.top);
    canvas.scale(dest.width / viewBox.width, dest.height / viewBox.height);
    canvas.translate(-viewBox.left, -viewBox.top);
    canvas.drawPicture(_picture);
    if (colorFilter != null) canvas.restore();
    canvas.restore();
  }

  /// Releases the recorded picture.
  void dispose() => _picture.dispose();
}

// ---------------------------------------------------------------------------
// Styles
// ---------------------------------------------------------------------------

class _Style {
  const _Style({
    required this.fill,
    required this.fillOpacity,
    required this.fillRule,
    required this.stroke,
    required this.strokeOpacity,
    required this.strokeWidth,
    required this.strokeCap,
    required this.strokeJoin,
    required this.miterLimit,
    required this.dashes,
    required this.dashOffset,
    required this.currentColor,
    required this.visible,
  });

  factory _Style.initial(Color currentColor) => _Style(
    fill: SvgPaint.color(const Color(0xFF000000)),
    fillOpacity: 1,
    fillRule: PathFillType.nonZero,
    stroke: const SvgPaint.none(),
    strokeOpacity: 1,
    strokeWidth: 1,
    strokeCap: StrokeCap.butt,
    strokeJoin: StrokeJoin.miter,
    miterLimit: 4,
    dashes: null,
    dashOffset: 0,
    currentColor: currentColor,
    visible: true,
  );

  final SvgPaint fill;
  final double fillOpacity;
  final PathFillType fillRule;
  final SvgPaint stroke;
  final double strokeOpacity;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final double miterLimit;
  final List<double>? dashes;
  final double dashOffset;
  final Color currentColor;
  final bool visible;

  /// Applies inheritable declarations on top of this style.
  _Style apply(Map<String, String> d, double Function(String?) length) {
    List<double>? dashes = this.dashes;
    final String? dashValue = d['stroke-dasharray'];
    if (dashValue != null) {
      final String v = dashValue.trim();
      if (v == 'none' || v.isEmpty) {
        dashes = null;
      } else {
        try {
          final List<double> list = parseNumberList(v);
          dashes = list.isEmpty || list.every((e) => e <= 0) ? null : list;
        } on FormatException {
          dashes = null;
        }
      }
    }
    return _Style(
      fill: parseSvgPaint(d['fill']) ?? fill,
      fillOpacity: parseSvgOpacity(d['fill-opacity']) ?? fillOpacity,
      fillRule: switch (d['fill-rule']) {
        'evenodd' => PathFillType.evenOdd,
        'nonzero' => PathFillType.nonZero,
        _ => fillRule,
      },
      stroke: parseSvgPaint(d['stroke']) ?? stroke,
      strokeOpacity: parseSvgOpacity(d['stroke-opacity']) ?? strokeOpacity,
      strokeWidth: d.containsKey('stroke-width')
          ? length(d['stroke-width'])
          : strokeWidth,
      strokeCap: switch (d['stroke-linecap']) {
        'round' => StrokeCap.round,
        'square' => StrokeCap.square,
        'butt' => StrokeCap.butt,
        _ => strokeCap,
      },
      strokeJoin: switch (d['stroke-linejoin']) {
        'round' => StrokeJoin.round,
        'bevel' => StrokeJoin.bevel,
        'miter' => StrokeJoin.miter,
        _ => strokeJoin,
      },
      miterLimit: double.tryParse(d['stroke-miterlimit'] ?? '') ?? miterLimit,
      dashes: dashes,
      dashOffset: d.containsKey('stroke-dashoffset')
          ? length(d['stroke-dashoffset'])
          : dashOffset,
      currentColor: d['color'] == null
          ? currentColor
          : (parseSvgColor(d['color']!) ?? currentColor),
      visible: switch (d['visibility']) {
        'hidden' || 'collapse' => false,
        'visible' => true,
        _ => visible,
      },
    );
  }
}

class _CssRule {
  _CssRule(this.tag, this.id, this.classes, this.declarations);
  final String? tag;
  final String? id;
  final List<String> classes;
  final Map<String, String> declarations;

  int get specificity =>
      (id == null ? 0 : 100) +
      classes.length * 10 +
      (tag == null || tag == '*' ? 0 : 1);

  bool matches(XmlElement el) {
    if (tag != null && tag != '*' && tag != el.name) return false;
    if (id != null && el.attributes['id'] != id) return false;
    if (classes.isNotEmpty) {
      final List<String> own = (el.attributes['class'] ?? '').split(
        RegExp(r'\s+'),
      );
      for (final String c in classes) {
        if (!own.contains(c)) return false;
      }
    }
    return true;
  }
}

const Set<String> _presentationAttributes = <String>{
  'fill',
  'fill-opacity',
  'fill-rule',
  'stroke',
  'stroke-opacity',
  'stroke-width',
  'stroke-linecap',
  'stroke-linejoin',
  'stroke-miterlimit',
  'stroke-dasharray',
  'stroke-dashoffset',
  'color',
  'opacity',
  'display',
  'visibility',
  'clip-path',
  'clip-rule',
  'stop-color',
  'stop-opacity',
};

/// Elements that never render on their own.
const Set<String> _nonRendering = <String>{
  'defs',
  'symbol',
  'clipPath',
  'mask',
  'linearGradient',
  'radialGradient',
  'pattern',
  'marker',
  'filter',
  'style',
  'title',
  'desc',
  'metadata',
  'script',
  'font',
  'view',
  'cursor',
};

// ---------------------------------------------------------------------------
// Builder
// ---------------------------------------------------------------------------

class _SvgBuilder {
  _SvgBuilder(this.root, this.currentColor) {
    for (final XmlElement el in root.descendants) {
      final String? id = el.attributes['id'];
      if (id != null && !_ids.containsKey(id)) _ids[id] = el;
      if (el.name == 'style') _parseCss(el.text);
    }
    _rules.sort((a, b) => a.specificity.compareTo(b.specificity));
    _viewport = _resolveViewport();
  }

  final XmlElement root;
  final Color currentColor;
  final Map<String, XmlElement> _ids = <String, XmlElement>{};
  final List<_CssRule> _rules = <_CssRule>[];
  late final Size _viewport;
  Rect? _contentBounds;
  int _useDepth = 0;

  SvgDocument build() {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final _Style rootStyle = _Style.initial(currentColor)
        .apply(_declarations(root), _length);
    _renderChildren(root, rootStyle, canvas);
    final ui.Picture picture = recorder.endRecording();

    final double? width = _absoluteLength(root.attributes['width']);
    final double? height = _absoluteLength(root.attributes['height']);
    Rect? viewBox = _parseViewBox(root.attributes['viewBox']);
    Size? intrinsic;
    if (width != null && height != null && width > 0 && height > 0) {
      intrinsic = Size(width, height);
    }
    viewBox ??= intrinsic == null
        ? (_contentBounds ?? const Rect.fromLTWH(0, 0, 100, 100))
        : Offset.zero & intrinsic;
    final bool stretch = (root.attributes['preserveAspectRatio'] ?? '')
        .trim()
        .startsWith('none');
    return SvgDocument._(picture, viewBox, intrinsic, stretch);
  }

  Size _resolveViewport() {
    final Rect? vb = _parseViewBox(root.attributes['viewBox']);
    if (vb != null) return vb.size;
    final double w = _absoluteLength(root.attributes['width']) ?? 100;
    final double h = _absoluteLength(root.attributes['height']) ?? 100;
    return Size(w, h);
  }

  static Rect? _parseViewBox(String? value) {
    if (value == null) return null;
    try {
      final List<double> v = parseNumberList(value);
      if (v.length != 4 || v[2] <= 0 || v[3] <= 0) return null;
      return Rect.fromLTWH(v[0], v[1], v[2], v[3]);
    } on FormatException {
      return null;
    }
  }

  static double? _absoluteLength(String? value) => parseSvgLength(value);

  double _length(String? value, {double? reference}) =>
      parseSvgLength(value, reference: reference ?? _viewport.width) ?? 0;
  double _x(String? value) =>
      parseSvgLength(value, reference: _viewport.width) ?? 0;
  double _y(String? value) =>
      parseSvgLength(value, reference: _viewport.height) ?? 0;

  void _parseCss(String css) {
    final String cleaned = css.replaceAll(
      RegExp(r'/\*.*?\*/', dotAll: true),
      '',
    );
    for (final RegExpMatch m in RegExp(
      r'([^{}]+)\{([^}]*)\}',
    ).allMatches(cleaned)) {
      final Map<String, String> decl = _parseDeclarations(m[2]!);
      if (decl.isEmpty) continue;
      for (final String selector in m[1]!.split(',')) {
        final String s = selector.trim();
        if (s.isEmpty || s.contains(RegExp(r'[\s>+~\[:]'))) {
          continue; // simple selectors only
        }
        String? tag;
        String? id;
        final List<String> classes = <String>[];
        for (final RegExpMatch part in RegExp(
          r'([.#]?)([\w-]+|\*)',
        ).allMatches(s)) {
          switch (part[1]) {
            case '.':
              classes.add(part[2]!);
            case '#':
              id = part[2];
            default:
              tag = part[2];
          }
        }
        _rules.add(_CssRule(tag, id, classes, decl));
      }
    }
  }

  static Map<String, String> _parseDeclarations(String text) {
    final Map<String, String> out = <String, String>{};
    for (final String item in text.split(';')) {
      final int colon = item.indexOf(':');
      if (colon == -1) continue;
      final String key = item.substring(0, colon).trim();
      final String value = item
          .substring(colon + 1)
          .replaceAll('!important', '')
          .trim();
      if (key.isNotEmpty && value.isNotEmpty) out[key] = value;
    }
    return out;
  }

  /// Effective declarations for [el]: presentation attributes, then matching
  /// stylesheet rules by specificity, then the inline `style` attribute.
  Map<String, String> _declarations(XmlElement el) {
    final Map<String, String> out = <String, String>{};
    el.attributes.forEach((String k, String v) {
      if (_presentationAttributes.contains(k)) out[k] = v;
    });
    for (final _CssRule rule in _rules) {
      if (rule.matches(el)) out.addAll(rule.declarations);
    }
    final String? inline = el.attributes['style'];
    if (inline != null) out.addAll(_parseDeclarations(inline));
    return out;
  }

  void _renderChildren(XmlElement parent, _Style style, Canvas canvas) {
    for (final XmlElement child in parent.elements) {
      _renderElement(child, style, canvas);
    }
  }

  void _renderElement(XmlElement el, _Style parentStyle, Canvas canvas) {
    if (_nonRendering.contains(el.name)) return;
    final Map<String, String> decl = _declarations(el);
    if (decl['display'] == 'none') return;
    final _Style style = parentStyle.apply(decl, _length);
    final double opacity = parseSvgOpacity(decl['opacity']) ?? 1;
    if (opacity <= 0) return;

    canvas.save();
    final Matrix4 transform = parseSvgTransform(el.attributes['transform']);
    if (!transform.isIdentity()) canvas.transform(transform.storage);
    if (el.name == 'use' || el.name == 'svg') {
      final double x = _x(el.attributes['x']);
      final double y = _y(el.attributes['y']);
      if (x != 0 || y != 0) canvas.translate(x, y);
    }
    if (opacity < 1) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
    }

    Path? shape;
    switch (el.name) {
      case 'svg':
      case 'g':
      case 'a':
        break;
      case 'switch':
        break;
      case 'use':
        break;
      default:
        shape = _shapePath(el);
    }

    final String? clipRef = _urlRef(decl['clip-path']);
    if (clipRef != null) {
      final Path? clip = _clipPath(clipRef, style, shape?.getBounds());
      if (clip != null) canvas.clipPath(clip);
    }

    if (style.visible) {
      switch (el.name) {
        case 'svg':
        case 'g':
        case 'a':
          _renderChildren(el, style, canvas);
        case 'switch':
          final XmlElement? first = el.elements.firstOrNull;
          if (first != null) _renderElement(first, style, canvas);
        case 'use':
          _renderUse(el, style, canvas);
        default:
          if (shape != null) _drawShape(canvas, shape, style, decl);
      }
    }

    if (opacity < 1) canvas.restore();
    canvas.restore();
  }

  void _renderUse(XmlElement el, _Style style, Canvas canvas) {
    final XmlElement? target = _href(el);
    if (target == null || _useDepth > 16) return;
    _useDepth++;
    try {
      if (target.name == 'symbol' || target.name == 'svg') {
        final _Style inner = style.apply(_declarations(target), _length);
        _renderChildren(target, inner, canvas);
      } else {
        _renderElement(target, style, canvas);
      }
    } finally {
      _useDepth--;
    }
  }

  XmlElement? _href(XmlElement el) {
    final String? ref = el.attributes['href'] ?? el.attributes['xlink:href'];
    if (ref == null || !ref.startsWith('#')) return null;
    return _ids[ref.substring(1)];
  }

  static String? _urlRef(String? value) {
    if (value == null) return null;
    final RegExpMatch? m = RegExp(r'url\(\s*#([^)\s]+)\s*\)').firstMatch(value);
    return m?[1];
  }

  Path? _clipPath(String id, _Style style, Rect? bounds) {
    final XmlElement? clip = _ids[id];
    if (clip == null || clip.name != 'clipPath') return null;
    final Path result = Path();
    bool any = false;
    for (final XmlElement child in clip.elements) {
      Path? p;
      XmlElement source = child;
      if (child.name == 'use') {
        final XmlElement? target = _href(child);
        if (target == null) continue;
        source = target;
      }
      p = _shapePath(source);
      if (p == null) continue;
      final Map<String, String> d = _declarations(child);
      if (d['display'] == 'none') continue;
      p.fillType = d['clip-rule'] == 'evenodd'
          ? PathFillType.evenOdd
          : PathFillType.nonZero;
      final Matrix4 t = parseSvgTransform(child.attributes['transform']);
      result.addPath(
        p,
        Offset.zero,
        matrix4: t.isIdentity() ? null : t.storage,
      );
      any = true;
    }
    if (!any) return null;
    if (clip.attributes['clipPathUnits'] == 'objectBoundingBox' &&
        bounds != null) {
      final Matrix4 m = Matrix4.translationValues(bounds.left, bounds.top, 0)
        ..multiply(Matrix4.diagonal3Values(bounds.width, bounds.height, 1));
      return result.transform(m.storage);
    }
    final Matrix4 t = parseSvgTransform(clip.attributes['transform']);
    return t.isIdentity() ? result : result.transform(t.storage);
  }

  Path? _shapePath(XmlElement el) {
    final Map<String, String> a = el.attributes;
    switch (el.name) {
      case 'path':
        final String? d = a['d'];
        if (d == null || d.trim().isEmpty) return null;
        return parseSvgPath(d);
      case 'rect':
        final double w = _x(a['width']), h = _y(a['height']);
        if (w <= 0 || h <= 0) return null;
        final Rect r = Rect.fromLTWH(_x(a['x']), _y(a['y']), w, h);
        double? rx = parseSvgLength(a['rx'], reference: _viewport.width);
        double? ry = parseSvgLength(a['ry'], reference: _viewport.height);
        rx ??= ry;
        ry ??= rx;
        if (rx == null || ry == null || rx <= 0 || ry <= 0) {
          return Path()..addRect(r);
        }
        rx = math.min(rx, w / 2);
        ry = math.min(ry, h / 2);
        return Path()..addRRect(RRect.fromRectXY(r, rx, ry));
      case 'circle':
        final double r = _length(a['r']);
        if (r <= 0) return null;
        return Path()..addOval(
          Rect.fromCircle(center: Offset(_x(a['cx']), _y(a['cy'])), radius: r),
        );
      case 'ellipse':
        final double rx = _x(a['rx']), ry = _y(a['ry']);
        if (rx <= 0 || ry <= 0) return null;
        return Path()..addOval(
          Rect.fromCenter(
            center: Offset(_x(a['cx']), _y(a['cy'])),
            width: rx * 2,
            height: ry * 2,
          ),
        );
      case 'line':
        return Path()
          ..moveTo(_x(a['x1']), _y(a['y1']))
          ..lineTo(_x(a['x2']), _y(a['y2']));
      case 'polyline':
      case 'polygon':
        final List<double> pts = parseNumberList(a['points'] ?? '');
        if (pts.length < 4) return null;
        final Path p = Path()..moveTo(pts[0], pts[1]);
        for (int i = 2; i + 1 < pts.length; i += 2) {
          p.lineTo(pts[i], pts[i + 1]);
        }
        if (el.name == 'polygon') p.close();
        return p;
      default:
        return null;
    }
  }

  void _drawShape(
    Canvas canvas,
    Path path,
    _Style style,
    Map<String, String> decl,
  ) {
    final Rect bounds = path.getBounds();
    _trackBounds(canvas, bounds);
    path.fillType = style.fillRule;

    final Paint? fill = _paintFor(style.fill, style.fillOpacity, style, bounds);
    if (fill != null) {
      canvas.drawPath(path, fill..style = PaintingStyle.fill);
    }
    if (style.strokeWidth > 0) {
      final Paint? stroke = _paintFor(
        style.stroke,
        style.strokeOpacity,
        style,
        bounds,
      );
      if (stroke != null) {
        stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.strokeWidth
          ..strokeCap = style.strokeCap
          ..strokeJoin = style.strokeJoin
          ..strokeMiterLimit = style.miterLimit;
        final List<double>? dashes = style.dashes;
        canvas.drawPath(
          dashes == null ? path : dashPath(path, dashes, style.dashOffset),
          stroke,
        );
      }
    }
  }

  void _trackBounds(Canvas canvas, Rect bounds) {
    final Rect global = MatrixUtils.transformRect(
      Matrix4.fromFloat64List(canvas.getTransform()),
      bounds,
    );
    _contentBounds = _contentBounds == null
        ? global
        : _contentBounds!.expandToInclude(global);
  }

  Paint? _paintFor(SvgPaint paint, double opacity, _Style style, Rect bounds) {
    if (paint.isNone) return null;
    if (paint.reference != null) {
      final ui.Shader? shader = _gradient(paint.reference!, bounds, opacity);
      if (shader == null) return null;
      return Paint()
        ..shader = shader
        ..isAntiAlias = true;
    }
    final Color base = paint.isCurrentColor ? style.currentColor : paint.color!;
    return Paint()
      ..color = base.withValues(alpha: base.a * opacity)
      ..isAntiAlias = true;
  }

  ui.Shader? _gradient(String id, Rect bounds, double opacity) {
    final XmlElement? g = _ids[id];
    if (g == null ||
        (g.name != 'linearGradient' && g.name != 'radialGradient')) {
      return null;
    }

    // Attributes and stops may be inherited through href chains.
    final Map<String, String> attrs = <String, String>{};
    List<XmlElement> stops = <XmlElement>[];
    XmlElement? current = g;
    for (int depth = 0; current != null && depth < 8; depth++) {
      current.attributes.forEach(
        (String k, String v) => attrs.putIfAbsent(k, () => v),
      );
      if (stops.isEmpty) {
        stops = current.elements.where((e) => e.name == 'stop').toList();
      }
      current = _href(current);
    }
    if (stops.isEmpty) return null;

    final List<Color> colors = <Color>[];
    final List<double> offsets = <double>[];
    for (final XmlElement stop in stops) {
      final Map<String, String> d = _declarations(stop);
      final Color color =
          parseSvgColor(d['stop-color'] ?? 'black') ?? const Color(0xFF000000);
      final double stopOpacity = parseSvgOpacity(d['stop-opacity']) ?? 1;
      colors.add(color.withValues(alpha: color.a * stopOpacity * opacity));
      double offset = parseSvgOpacity(stop.attributes['offset']) ?? 0;
      if (offsets.isNotEmpty && offset < offsets.last) offset = offsets.last;
      offsets.add(offset);
    }
    if (colors.length == 1) {
      colors.add(colors.first);
      offsets.add(1);
    }

    final bool objectBounds =
        (attrs['gradientUnits'] ?? 'objectBoundingBox') == 'objectBoundingBox';
    if (objectBounds && (bounds.width == 0 || bounds.height == 0)) return null;
    final Matrix4 matrix = objectBounds
        ? (Matrix4.translationValues(bounds.left, bounds.top, 0)
            ..multiply(Matrix4.diagonal3Values(bounds.width, bounds.height, 1)))
        : Matrix4.identity();
    matrix.multiply(parseSvgTransform(attrs['gradientTransform']));
    final TileMode tile = switch (attrs['spreadMethod']) {
      'reflect' => TileMode.mirror,
      'repeat' => TileMode.repeated,
      _ => TileMode.clamp,
    };
    double coord(String name, String fallback, double reference) =>
        parseSvgLength(
          attrs[name] ?? fallback,
          reference: objectBounds ? 1 : reference,
        ) ??
        0;

    if (g.name == 'linearGradient') {
      final Offset from = Offset(
        coord('x1', '0%', _viewport.width),
        coord('y1', '0%', _viewport.height),
      );
      final Offset to = Offset(
        coord('x2', '100%', _viewport.width),
        coord('y2', '0%', _viewport.height),
      );
      return ui.Gradient.linear(
        from,
        to,
        colors,
        offsets,
        tile,
        matrix.storage,
      );
    }
    final Offset center = Offset(
      coord('cx', '50%', _viewport.width),
      coord('cy', '50%', _viewport.height),
    );
    final double r = coord('r', '50%', _viewport.width);
    if (r <= 0) return null;
    final Offset focal = Offset(
      attrs.containsKey('fx') ? coord('fx', '50%', _viewport.width) : center.dx,
      attrs.containsKey('fy')
          ? coord('fy', '50%', _viewport.height)
          : center.dy,
    );
    return ui.Gradient.radial(
      center,
      r,
      colors,
      offsets,
      tile,
      matrix.storage,
      focal == center ? null : focal,
      0,
    );
  }
}

/// Returns a copy of [source] broken into dashes following [pattern]
/// (on/off lengths) starting [offset] into the pattern.
Path dashPath(Path source, List<double> pattern, double offset) {
  final List<double> dashes = pattern.length.isOdd
      ? <double>[...pattern, ...pattern]
      : pattern;
  final double total = dashes.fold(0, (double a, double b) => a + b);
  if (total <= 0) return source;
  final Path out = Path();
  for (final ui.PathMetric metric in source.computeMetrics()) {
    int index = 0;
    double remaining = dashes[0];
    bool draw = true;
    double skip = offset % total;
    while (skip > 0) {
      if (skip >= remaining) {
        skip -= remaining;
        index = (index + 1) % dashes.length;
        remaining = dashes[index];
        draw = !draw;
      } else {
        remaining -= skip;
        skip = 0;
      }
    }
    double position = 0;
    while (position < metric.length) {
      final double end = math.min(position + remaining, metric.length);
      if (draw && end > position) {
        out.addPath(metric.extractPath(position, end), Offset.zero);
      }
      position = end;
      index = (index + 1) % dashes.length;
      remaining = dashes[index];
      draw = !draw;
    }
  }
  return out;
}
