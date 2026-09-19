/// A compact Lottie (Bodymovin) player covering the common export subset:
/// shape, solid, image, null and pre-composition layers; parenting; keyframed
/// transforms with bezier easing; paths, rectangles, ellipses and polystars;
/// solid and gradient fills and strokes (with dashes); trim paths; masks; and
/// alpha mattes. Text layers, effects, expressions, repeaters, merge paths and
/// rounded corners are not supported and are skipped.
library;

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/widgets.dart';

import '../net/fetch.dart';
import '../zip.dart';

/// A parsed Lottie animation.
class LottieComposition {
  LottieComposition._({
    required this.frameRate,
    required this.inPoint,
    required this.outPoint,
    required this.width,
    required this.height,
    required this._layers,
    required this._assets,
  });

  /// Frames per second.
  final double frameRate;

  /// First frame.
  final double inPoint;

  /// Last frame (exclusive).
  final double outPoint;

  /// Composition width in pixels.
  final double width;

  /// Composition height in pixels.
  final double height;

  final List<_Layer> _layers;
  final Map<String, _Asset> _assets;
  final Map<String, ui.Image> _images = <String, ui.Image>{};

  /// Per layer list, the `ind` to layer lookup used for parenting. Built on
  /// first paint rather than every frame.
  final Map<List<_Layer>, Map<int, _Layer>> _layerIndex =
      <List<_Layer>, Map<int, _Layer>>{};

  /// Composition size.
  Size get size => Size(width, height);

  /// Length of one play-through.
  Duration get duration {
    final double frames = math.max(outPoint - inPoint, 1);
    return Duration(microseconds: (frames / frameRate * 1e6).round());
  }

  /// Decodes a `.json` animation or a `.zip` / dotLottie bundle.
  static Future<LottieComposition> fromBytes(Uint8List bytes) {
    Uint8List data = bytes;
    if (bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4B) {
      final Uint8List? entry = readZipEntry(
        bytes,
        (String name) =>
            name.toLowerCase().endsWith('.json') &&
            !name.toLowerCase().endsWith('manifest.json'),
      );
      if (entry == null) {
        throw const FormatException('no animation JSON found in archive');
      }
      data = entry;
    }
    return fromJsonString(utf8.decode(data, allowMalformed: true));
  }

  /// Decodes an animation from its JSON text.
  ///
  /// Large documents (animations with embedded images can be megabytes of
  /// JSON) are parsed on a background isolate on native platforms and inline
  /// on the web.
  static Future<LottieComposition> fromJsonString(String text) async {
    final Object? json = text.length > 64 * 1024
        ? await compute(jsonDecode, text, debugLabel: 'lottie jsonDecode')
        : jsonDecode(text);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Lottie JSON must be an object');
    }
    return fromJson(json);
  }

  /// Builds a composition from decoded JSON and loads its embedded images.
  static Future<LottieComposition> fromJson(Map<String, dynamic> json) async {
    final Map<String, _Asset> assets = <String, _Asset>{};
    for (final Object? a
        in (json['assets'] as List<dynamic>? ?? const <dynamic>[])) {
      if (a is Map<String, dynamic>) {
        final _Asset asset = _Asset.fromJson(a);
        assets[asset.id] = asset;
      }
    }
    final LottieComposition composition = LottieComposition._(
      frameRate: _num(json['fr'], 30),
      inPoint: _num(json['ip'], 0),
      outPoint: _num(json['op'], 0),
      width: _num(json['w'], 0),
      height: _num(json['h'], 0),
      layers: _parseLayers(json['layers']),
      assets: assets,
    );
    await composition._loadImages();
    return composition;
  }

  Future<void> _loadImages() async {
    for (final _Asset asset in _assets.values) {
      final String? source = asset.imageSource;
      if (source == null) continue;
      Uint8List? bytes;
      if (source.startsWith('data:')) {
        final int comma = source.indexOf(',');
        if (comma != -1) {
          try {
            bytes = base64Decode(
              source.substring(comma + 1).replaceAll(RegExp(r'\s'), ''),
            );
          } on FormatException {
            bytes = null;
          }
        }
      } else if (source.startsWith('http://') ||
          source.startsWith('https://')) {
        bytes = await fetchBytes(Uri.parse(source));
      }
      if (bytes == null) continue;
      try {
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frame = await codec.getNextFrame();
        _images[asset.id] = frame.image;
        codec.dispose();
      } catch (_) {
        // Unsupported image; the layer is skipped.
      }
    }
  }

  /// Releases decoded images.
  void dispose() {
    for (final ui.Image image in _images.values) {
      image.dispose();
    }
    _images.clear();
  }

  /// Paints [frame] into [size].
  void paint(
    Canvas canvas,
    Size size,
    double frame, {
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
  }) {
    if (size.isEmpty || width <= 0 || height <= 0) return;
    // `outPoint` is exclusive; clamp so the final frame still draws.
    final double clamped = frame.clamp(
      inPoint,
      math.max(inPoint, outPoint - 1e-3),
    );
    final FittedSizes sizes = applyBoxFit(fit, Size(width, height), size);
    final Rect dest = alignment.inscribe(sizes.destination, Offset.zero & size);
    canvas.save();
    canvas.clipRect(dest);
    canvas.translate(dest.left, dest.top);
    canvas.scale(dest.width / width, dest.height / height);
    _paintLayers(canvas, _layers, clamped);
    canvas.restore();
  }

  void _paintLayers(Canvas canvas, List<_Layer> layers, double frame) {
    final Map<int, _Layer> byIndex = _layerIndex.putIfAbsent(
      layers,
      () => <int, _Layer>{
        for (final _Layer l in layers)
          if (l.index != null) l.index!: l,
      },
    );
    // The first layer in the file is on top, so draw back to front.
    for (int i = layers.length - 1; i >= 0; i--) {
      final _Layer layer = layers[i];
      if (layer.isMatteSource || layer.hidden || !layer.isVisibleAt(frame)) {
        continue;
      }
      final _Layer? matte =
          layer.matteType != 0 && i > 0 && layers[i - 1].isMatteSource
          ? layers[i - 1]
          : null;
      if (matte == null) {
        _paintLayer(canvas, layer, frame, byIndex);
        continue;
      }
      canvas.saveLayer(null, Paint());
      _paintLayer(canvas, layer, frame, byIndex);
      final bool inverted = layer.matteType == 2 || layer.matteType == 4;
      canvas.saveLayer(
        null,
        Paint()..blendMode = inverted ? BlendMode.dstOut : BlendMode.dstIn,
      );
      if (matte.isVisibleAt(frame)) _paintLayer(canvas, matte, frame, byIndex);
      canvas.restore();
      canvas.restore();
    }
  }

  void _paintLayer(
    Canvas canvas,
    _Layer layer,
    double frame,
    Map<int, _Layer> byIndex,
  ) {
    final double local = layer.localFrame(frame);
    final Matrix4 matrix = Matrix4.identity();
    // Parents contribute transform only, each evaluated at its own local time.
    final List<_Layer> chain = <_Layer>[layer];
    int? parent = layer.parent;
    for (int depth = 0; parent != null && depth < 64; depth++) {
      final _Layer? p = byIndex[parent];
      if (p == null || chain.contains(p)) break;
      chain.add(p);
      parent = p.parent;
    }
    for (int i = chain.length - 1; i >= 0; i--) {
      matrix.multiply(chain[i].transform.matrixAt(chain[i].localFrame(frame)));
    }
    final double alpha = layer.transform.opacityAt(local);
    if (alpha <= 0) return;

    canvas.save();
    canvas.transform(matrix.storage);
    final Path? mask = layer.maskPathAt(local);
    if (mask != null) canvas.clipPath(mask);

    switch (layer.type) {
      case 4:
        for (int i = layer.contents.length - 1; i >= 0; i--) {
          final _Content c = layer.contents[i];
          if (c is _DrawContent && !c.hidden) c.draw(canvas, local, alpha);
        }
      case 1:
        final Color? color = layer.solidColor;
        if (color != null) {
          canvas.drawRect(
            Rect.fromLTWH(0, 0, layer.width, layer.height),
            Paint()..color = color.withValues(alpha: color.a * alpha),
          );
        }
      case 2:
        final ui.Image? image = _images[layer.refId];
        final _Asset? asset = _assets[layer.refId];
        if (image != null) {
          final double w = asset?.width ?? image.width.toDouble();
          final double h = asset?.height ?? image.height.toDouble();
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(
              0,
              0,
              image.width.toDouble(),
              image.height.toDouble(),
            ),
            Rect.fromLTWH(0, 0, w, h),
            Paint()
              ..color = Color.fromRGBO(255, 255, 255, alpha)
              ..filterQuality = FilterQuality.medium,
          );
        }
      case 0:
        final _Asset? asset = _assets[layer.refId];
        final List<_Layer>? layers = asset?.layers;
        if (layers != null && layers.isNotEmpty) {
          final double inner = layer.timeRemap == null
              ? local
              : layer.timeRemap!.valueAt(local) * frameRate;
          if (alpha < 1) {
            canvas.saveLayer(
              null,
              Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
            );
          }
          if (layer.width > 0 && layer.height > 0) {
            canvas.clipRect(Rect.fromLTWH(0, 0, layer.width, layer.height));
          }
          _paintLayers(canvas, layers, inner);
          if (alpha < 1) canvas.restore();
        }
      default:
        break;
    }
    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// JSON helpers
// ---------------------------------------------------------------------------

double _num(Object? v, double fallback) => v is num ? v.toDouble() : fallback;

double _scalar(Object? v) {
  if (v is num) return v.toDouble();
  if (v is List && v.isNotEmpty && v.first is num) {
    return (v.first as num).toDouble();
  }
  return 0;
}

List<double> _vector(Object? v) {
  if (v is List) return v.map((e) => e is num ? e.toDouble() : 0.0).toList();
  if (v is num) return <double>[v.toDouble()];
  return const <double>[];
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

List<double> _lerpVector(List<double> a, List<double> b, double t) {
  if (a.length != b.length) return t < 1 ? a : b;
  return List<double>.generate(
    a.length,
    (int i) => a[i] + (b[i] - a[i]) * t,
    growable: false,
  );
}

Color _colorFrom(List<double> c, double alpha) {
  if (c.length < 3) return Color.fromRGBO(0, 0, 0, alpha);
  final double scale = c.take(3).any((double v) => v > 1) ? 1 / 255 : 1;
  final double a = c.length > 3 ? (c[3] > 1 ? c[3] / 255 : c[3]) : 1;
  return Color.fromRGBO(
    (c[0] * scale * 255).round().clamp(0, 255),
    (c[1] * scale * 255).round().clamp(0, 255),
    (c[2] * scale * 255).round().clamp(0, 255),
    (a * alpha).clamp(0, 1),
  );
}

// ---------------------------------------------------------------------------
// Animation
// ---------------------------------------------------------------------------

class _Easing {
  const _Easing(this.x1, this.y1, this.x2, this.y2);

  final double x1, y1, x2, y2;

  static _Easing? fromJson(Object? o, Object? i) {
    if (o is! Map || i is! Map) return null;
    final double ox = _scalar(o['x']), oy = _scalar(o['y']);
    final double ix = _scalar(i['x']), iy = _scalar(i['y']);
    if (ox == oy && ix == iy) return null; // linear
    return _Easing(ox.clamp(0, 1), oy, ix.clamp(0, 1), iy);
  }

  static double _bezier(double t, double a, double b) {
    final double u = 1 - t;
    return 3 * u * u * t * a + 3 * u * t * t * b + t * t * t;
  }

  double transform(double x) {
    // Solve for the curve parameter with Newton iterations, then evaluate y.
    double t = x;
    for (int n = 0; n < 8; n++) {
      final double error = _bezier(t, x1, x2) - x;
      if (error.abs() < 1e-5) break;
      final double u = 1 - t;
      final double slope =
          3 * u * u * x1 + 6 * u * t * (x2 - x1) + 3 * t * t * (1 - x2);
      if (slope.abs() < 1e-6) break;
      t = (t - error / slope).clamp(0.0, 1.0);
    }
    return _bezier(t, y1, y2);
  }
}

class _Keyframe<T> {
  _Keyframe(
    this.time,
    this.start,
    this.end,
    this.easing,
    this.hold,
    this.spatialOut,
    this.spatialIn,
  );
  final double time;
  final T start;
  T? end;
  final _Easing? easing;
  final bool hold;
  final Offset? spatialOut;
  final Offset? spatialIn;
}

class _Animated<T> {
  _Animated.static(this._value) : _keyframes = null;
  final T _value;
  final List<_Keyframe<T>>? _keyframes;

  bool get isAnimated => _keyframes != null;

  static _Animated<T>? parse<T>(
    Object? json,
    T Function(Object?) read,
    T Function(T, T, double) lerp,
  ) {
    if (json is! Map) return null;
    final Object? k = json['k'];
    final bool animated =
        json['a'] == 1 ||
        (k is List &&
            k.isNotEmpty &&
            k.first is Map &&
            (k.first as Map).containsKey('t'));
    if (!animated) return _Animated<T>.static(read(k));
    final List<_Keyframe<T>> frames = <_Keyframe<T>>[];
    for (final Object? item in k as List) {
      if (item is! Map) continue;
      if (!item.containsKey('s')) continue;
      frames.add(
        _Keyframe<T>(
          _num(item['t'], 0),
          read(item['s']),
          item.containsKey('e') ? read(item['e']) : null,
          _Easing.fromJson(item['o'], item['i']),
          item['h'] == 1,
          item['to'] is List ? _offset(item['to']) : null,
          item['ti'] is List ? _offset(item['ti']) : null,
        ),
      );
    }
    if (frames.isEmpty) return null;
    for (int i = 0; i < frames.length - 1; i++) {
      frames[i].end ??= frames[i + 1].start;
    }
    return _Animated<T>._withLerp(frames, lerp);
  }

  _Animated._withLerp(List<_Keyframe<T>> keyframes, this._lerp)
    : _keyframes = keyframes,
      _value = keyframes.first.start;

  T Function(T, T, double)? _lerp;

  T valueAt(double frame) {
    final List<_Keyframe<T>>? frames = _keyframes;
    if (frames == null) return _value;
    if (frame <= frames.first.time) return frames.first.start;
    final _Keyframe<T> last = frames.last;
    if (frame >= last.time) return last.end ?? last.start;
    for (int i = 0; i < frames.length - 1; i++) {
      final _Keyframe<T> a = frames[i];
      final _Keyframe<T> b = frames[i + 1];
      if (frame < b.time) {
        final T end = a.end ?? b.start;
        if (a.hold) return a.start;
        final double span = b.time - a.time;
        double t = span <= 0 ? 1 : (frame - a.time) / span;
        if (a.easing != null) t = a.easing!.transform(t);
        final T start = a.start;
        if (a.spatialOut != null &&
            a.spatialIn != null &&
            start is List<double> &&
            end is List<double>) {
          return _spatial(start, end, a.spatialOut!, a.spatialIn!, t) as T;
        }
        return _lerp!(start, end, t);
      }
    }
    return last.start;
  }

  static Offset _offset(Object? v) {
    final List<double> l = _vector(v);
    return Offset(l.isNotEmpty ? l[0] : 0, l.length > 1 ? l[1] : 0);
  }

  static List<double> _spatial(
    List<double> s,
    List<double> e,
    Offset to,
    Offset ti,
    double t,
  ) {
    if (s.length < 2 || e.length < 2) return _lerpVector(s, e, t);
    final Offset p0 = Offset(s[0], s[1]);
    final Offset p3 = Offset(e[0], e[1]);
    final Offset p1 = p0 + to;
    final Offset p2 = p3 + ti;
    final double u = 1 - t;
    final Offset p =
        p0 * (u * u * u) +
        p1 * (3 * u * u * t) +
        p2 * (3 * u * t * t) +
        p3 * (t * t * t);
    return <double>[
      p.dx,
      p.dy,
      if (s.length > 2) _lerpDouble(s[2], e.length > 2 ? e[2] : s[2], t),
    ];
  }
}

_Animated<double>? _animScalar(Object? json) =>
    _Animated.parse<double>(json, _scalar, _lerpDouble);
_Animated<List<double>>? _animVector(Object? json) =>
    _Animated.parse<List<double>>(json, _vector, _lerpVector);
_Animated<_ShapeData>? _animShape(Object? json) =>
    _Animated.parse<_ShapeData>(json, _ShapeData.read, _ShapeData.lerp);

/// Position that may be split into separate x/y channels.
class _Position {
  _Position(this.joined, this.x, this.y);

  factory _Position.fromJson(Object? json) {
    if (json is Map && json['s'] == true) {
      return _Position(null, _animScalar(json['x']), _animScalar(json['y']));
    }
    return _Position(_animVector(json), null, null);
  }

  final _Animated<List<double>>? joined;
  final _Animated<double>? x;
  final _Animated<double>? y;

  Offset at(double frame) {
    if (joined != null) {
      final List<double> v = joined!.valueAt(frame);
      return Offset(v.isNotEmpty ? v[0] : 0, v.length > 1 ? v[1] : 0);
    }
    return Offset(x?.valueAt(frame) ?? 0, y?.valueAt(frame) ?? 0);
  }
}

class _Transform {
  _Transform.fromJson(Map<String, dynamic>? json)
    : anchor = _animVector(json?['a']),
      position = _Position.fromJson(json?['p']),
      scale = _animVector(json?['s']),
      rotation = _animScalar(json?['r']) ?? _animScalar(json?['rz']),
      opacity = _animScalar(json?['o']),
      skew = _animScalar(json?['sk']),
      skewAxis = _animScalar(json?['sa']);

  final _Animated<List<double>>? anchor;
  final _Position position;
  final _Animated<List<double>>? scale;
  final _Animated<double>? rotation;
  final _Animated<double>? opacity;
  final _Animated<double>? skew;
  final _Animated<double>? skewAxis;

  Matrix4 matrixAt(double frame) {
    final Matrix4 m = Matrix4.identity();
    final Offset p = position.at(frame);
    if (p != Offset.zero) {
      m.multiply(Matrix4.translationValues(p.dx, p.dy, 0));
    }
    final double r = rotation?.valueAt(frame) ?? 0;
    if (r != 0) m.rotateZ(r * math.pi / 180);
    final double sk = skew?.valueAt(frame) ?? 0;
    if (sk != 0) {
      final double axis = (skewAxis?.valueAt(frame) ?? 0) * math.pi / 180;
      m.rotateZ(axis);
      m.multiply(
        Matrix4.identity()..setEntry(0, 1, math.tan(-sk * math.pi / 180)),
      );
      m.rotateZ(-axis);
    }
    final List<double>? s = scale?.valueAt(frame);
    if (s != null && s.length >= 2 && (s[0] != 100 || s[1] != 100)) {
      m.multiply(Matrix4.diagonal3Values(s[0] / 100, s[1] / 100, 1));
    }
    final List<double>? a = anchor?.valueAt(frame);
    if (a != null && a.length >= 2 && (a[0] != 0 || a[1] != 0)) {
      m.multiply(Matrix4.translationValues(-a[0], -a[1], 0));
    }
    return m;
  }

  double opacityAt(double frame) =>
      ((opacity?.valueAt(frame) ?? 100) / 100).clamp(0.0, 1.0);
}

// ---------------------------------------------------------------------------
// Shapes
// ---------------------------------------------------------------------------

class _ShapeData {
  const _ShapeData(
    this.closed,
    this.vertices,
    this.inTangents,
    this.outTangents,
  );

  final bool closed;
  final List<Offset> vertices;
  final List<Offset> inTangents;
  final List<Offset> outTangents;

  static _ShapeData read(Object? json) {
    Object? data = json;
    if (data is List && data.isNotEmpty) data = data.first;
    if (data is! Map) {
      return const _ShapeData(false, <Offset>[], <Offset>[], <Offset>[]);
    }
    List<Offset> points(Object? v) {
      if (v is! List) return const <Offset>[];
      return v.map(_Animated._offset).toList(growable: false);
    }

    final List<Offset> vertices = points(data['v']);
    List<Offset> pad(List<Offset> l) => l.length == vertices.length
        ? l
        : List<Offset>.filled(vertices.length, Offset.zero);
    return _ShapeData(
      data['c'] == true,
      vertices,
      pad(points(data['i'])),
      pad(points(data['o'])),
    );
  }

  static _ShapeData lerp(_ShapeData a, _ShapeData b, double t) {
    if (a.vertices.length != b.vertices.length) return t < 1 ? a : b;
    List<Offset> mix(List<Offset> x, List<Offset> y) => List<Offset>.generate(
      x.length,
      (int i) => Offset.lerp(x[i], y[i], t)!,
      growable: false,
    );
    return _ShapeData(
      a.closed,
      mix(a.vertices, b.vertices),
      mix(a.inTangents, b.inTangents),
      mix(a.outTangents, b.outTangents),
    );
  }

  Path toPath() {
    final Path path = Path();
    if (vertices.isEmpty) return path;
    path.moveTo(vertices[0].dx, vertices[0].dy);
    for (int i = 0; i < vertices.length - 1; i++) {
      _curve(path, i, i + 1);
    }
    if (closed && vertices.length > 1) {
      _curve(path, vertices.length - 1, 0);
      path.close();
    }
    return path;
  }

  void _curve(Path path, int from, int to) {
    final Offset c1 = vertices[from] + outTangents[from];
    final Offset c2 = vertices[to] + inTangents[to];
    final Offset end = vertices[to];
    if (c1 == vertices[from] && c2 == end) {
      path.lineTo(end.dx, end.dy);
    } else {
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    }
  }
}

abstract class _Content {
  _Content(Map<String, dynamic> json) : hidden = json['hd'] == true;
  final bool hidden;
}

abstract class _PathContent extends _Content {
  _PathContent(super.json);
  Path pathAt(double frame);
}

abstract class _DrawContent extends _Content {
  _DrawContent(super.json);
  void draw(Canvas canvas, double frame, double alpha);
}

List<_Content> _parseContents(Object? items) {
  final List<_Content> out = <_Content>[];
  if (items is! List) return out;
  _Transform? groupTransform;
  for (final Object? raw in items) {
    if (raw is! Map<String, dynamic>) continue;
    switch (raw['ty']) {
      case 'gr':
        out.add(_Group(raw));
      case 'sh':
        out.add(_Shape.path(raw));
      case 'rc':
        out.add(_Shape.rect(raw));
      case 'el':
        out.add(_Shape.ellipse(raw));
      case 'sr':
        out.add(_Shape.star(raw));
      case 'fl':
        out.add(_Fill(raw));
      case 'gf':
        out.add(_GradientFill(raw));
      case 'st':
        out.add(_Stroke(raw));
      case 'gs':
        out.add(_GradientStroke(raw));
      case 'tm':
        out.add(_Trim(raw));
      case 'tr':
        groupTransform = _Transform.fromJson(raw);
      default:
        break; // mm, rp, rd and unknown items are not supported
    }
  }
  // Wire fills/strokes to the shapes above them and shapes to trims below.
  for (int i = 0; i < out.length; i++) {
    final _Content c = out[i];
    if (c is _Paint) {
      c.targets = out
          .take(i)
          .whereType<_PathContent>()
          .where((p) => !p.hidden)
          .toList(growable: false);
    } else if (c is _Shape) {
      c.trims = out
          .skip(i + 1)
          .whereType<_Trim>()
          .where((t) => !t.hidden)
          .toList(growable: false);
    }
  }
  if (groupTransform != null) out.add(_GroupTransformHolder(groupTransform));
  return out;
}

/// Carries a group's `tr` item through [_parseContents] to its [_Group].
class _GroupTransformHolder extends _Content {
  _GroupTransformHolder(this.transform) : super(const <String, dynamic>{});
  final _Transform transform;
}

class _Group extends _PathContent implements _DrawContent {
  _Group(Map<String, dynamic> json) : super(json) {
    final List<_Content> parsed = _parseContents(json['it']);
    final _GroupTransformHolder? holder = parsed
        .whereType<_GroupTransformHolder>()
        .firstOrNull;
    transform = holder?.transform;
    items = parsed
        .where((c) => c is! _GroupTransformHolder)
        .toList(growable: false);
  }

  late final List<_Content> items;
  late final _Transform? transform;

  @override
  Path pathAt(double frame) {
    final Path path = Path();
    final Matrix4? m = transform?.matrixAt(frame);
    for (final _Content item in items) {
      if (item is _PathContent && !item.hidden) {
        path.addPath(item.pathAt(frame), Offset.zero, matrix4: m?.storage);
      }
    }
    return path;
  }

  @override
  void draw(Canvas canvas, double frame, double alpha) {
    final double a = alpha * (transform?.opacityAt(frame) ?? 1);
    if (a <= 0) return;
    canvas.save();
    final Matrix4? m = transform?.matrixAt(frame);
    if (m != null) canvas.transform(m.storage);
    for (int i = items.length - 1; i >= 0; i--) {
      final _Content item = items[i];
      if (item is _DrawContent && !item.hidden) item.draw(canvas, frame, a);
    }
    canvas.restore();
  }
}

class _Shape extends _PathContent {
  _Shape.path(super.json)
    : _kind = 0,
      _shape = _animShape(json['ks']),
      _position = null,
      _size = null,
      _radius = null,
      _outerRadius = null,
      _innerRadius = null,
      _points = null,
      _rotation = null,
      _isStar = false;

  _Shape.rect(super.json)
    : _kind = 1,
      _shape = null,
      _position = _animVector(json['p']),
      _size = _animVector(json['s']),
      _radius = _animScalar(json['r']),
      _outerRadius = null,
      _innerRadius = null,
      _points = null,
      _rotation = null,
      _isStar = false;

  _Shape.ellipse(super.json)
    : _kind = 2,
      _shape = null,
      _position = _animVector(json['p']),
      _size = _animVector(json['s']),
      _radius = null,
      _outerRadius = null,
      _innerRadius = null,
      _points = null,
      _rotation = null,
      _isStar = false;

  _Shape.star(super.json)
    : _kind = 3,
      _shape = null,
      _position = _animVector(json['p']),
      _size = null,
      _radius = null,
      _outerRadius = _animScalar(json['or']),
      _innerRadius = _animScalar(json['ir']),
      _points = _animScalar(json['pt']),
      _rotation = _animScalar(json['r']),
      _isStar = json['sy'] != 2;

  final int _kind;
  final _Animated<_ShapeData>? _shape;
  final _Animated<List<double>>? _position;
  final _Animated<List<double>>? _size;
  final _Animated<double>? _radius;
  final _Animated<double>? _outerRadius;
  final _Animated<double>? _innerRadius;
  final _Animated<double>? _points;
  final _Animated<double>? _rotation;
  final bool _isStar;
  List<_Trim> trims = const <_Trim>[];

  Offset _center(double frame) {
    final List<double> p = _position?.valueAt(frame) ?? const <double>[0, 0];
    return Offset(p.isNotEmpty ? p[0] : 0, p.length > 1 ? p[1] : 0);
  }

  @override
  Path pathAt(double frame) {
    Path path;
    switch (_kind) {
      case 0:
        path = _shape?.valueAt(frame).toPath() ?? Path();
      case 1:
        final List<double> s = _size?.valueAt(frame) ?? const <double>[0, 0];
        final Rect rect = Rect.fromCenter(
          center: _center(frame),
          width: s.isNotEmpty ? s[0] : 0,
          height: s.length > 1 ? s[1] : 0,
        );
        final double r = math.min(
          _radius?.valueAt(frame) ?? 0,
          math.min(rect.width, rect.height) / 2,
        );
        path = Path();
        if (r > 0) {
          path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));
        } else {
          path.addRect(rect);
        }
      case 2:
        final List<double> s = _size?.valueAt(frame) ?? const <double>[0, 0];
        path = Path()
          ..addOval(
            Rect.fromCenter(
              center: _center(frame),
              width: s.isNotEmpty ? s[0] : 0,
              height: s.length > 1 ? s[1] : 0,
            ),
          );
      default:
        path = _starPath(frame);
    }
    for (final _Trim trim in trims) {
      path = trim.apply(path, frame);
    }
    return path;
  }

  Path _starPath(double frame) {
    final Path path = Path();
    final int points = (_points?.valueAt(frame) ?? 5).round();
    if (points < 3) return path;
    final Offset c = _center(frame);
    final double outer = _outerRadius?.valueAt(frame) ?? 0;
    final double inner = _innerRadius?.valueAt(frame) ?? outer / 2;
    final double rotation =
        ((_rotation?.valueAt(frame) ?? 0) - 90) * math.pi / 180;
    final int count = _isStar ? points * 2 : points;
    for (int i = 0; i < count; i++) {
      final double r = _isStar && i.isOdd ? inner : outer;
      final double angle = rotation + i * 2 * math.pi / count;
      final Offset p = c + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }
}

class _Trim extends _Content {
  _Trim(super.json)
    : start = _animScalar(json['s']),
      end = _animScalar(json['e']),
      offset = _animScalar(json['o']),
      individually = json['m'] == 2;

  final _Animated<double>? start;
  final _Animated<double>? end;
  final _Animated<double>? offset;
  final bool individually;

  Path apply(Path path, double frame) {
    final double o = (offset?.valueAt(frame) ?? 0) / 360;
    double s = (start?.valueAt(frame) ?? 0) / 100 + o;
    double e = (end?.valueAt(frame) ?? 100) / 100 + o;
    if (s > e) {
      final double tmp = s;
      s = e;
      e = tmp;
    }
    if (e - s >= 1) return path;
    s %= 1;
    e %= 1;
    if (e < s) e += 1;
    final Path out = Path();
    final List<ui.PathMetric> metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return out;
    if (individually) {
      final double total = metrics.fold(
        0,
        (double a, ui.PathMetric m) => a + m.length,
      );
      _extractRange(metrics, out, s * total, e * total, total);
    } else {
      for (final ui.PathMetric m in metrics) {
        _extractRange(
          <ui.PathMetric>[m],
          out,
          s * m.length,
          e * m.length,
          m.length,
        );
      }
    }
    return out;
  }

  /// Copies the portion [from]..[to] of a chain of [metrics] (with combined
  /// [total] length) into [out], wrapping past the end.
  static void _extractRange(
    List<ui.PathMetric> metrics,
    Path out,
    double from,
    double to,
    double total,
  ) {
    void take(double a, double b) {
      double offset = 0;
      for (final ui.PathMetric m in metrics) {
        final double start = math.max(a, offset);
        final double end = math.min(b, offset + m.length);
        if (end > start) {
          out.addPath(m.extractPath(start - offset, end - offset), Offset.zero);
        }
        offset += m.length;
      }
    }

    if (to <= total) {
      take(from, to);
    } else {
      take(from, total);
      take(0, to - total);
    }
  }
}

abstract class _Paint extends _DrawContent {
  _Paint(super.json);
  List<_PathContent> targets = const <_PathContent>[];

  Path combinedPath(double frame) {
    final Path path = Path();
    for (final _PathContent t in targets) {
      path.addPath(t.pathAt(frame), Offset.zero);
    }
    return path;
  }
}

class _Fill extends _Paint {
  _Fill(super.json)
    : color = _animVector(json['c']),
      opacity = _animScalar(json['o']),
      fillRule = json['r'] == 2 ? PathFillType.evenOdd : PathFillType.nonZero;

  final _Animated<List<double>>? color;
  final _Animated<double>? opacity;
  final PathFillType fillRule;

  @override
  void draw(Canvas canvas, double frame, double alpha) {
    final double a = alpha * ((opacity?.valueAt(frame) ?? 100) / 100);
    if (a <= 0 || targets.isEmpty) return;
    final Path path = combinedPath(frame)..fillType = fillRule;
    canvas.drawPath(
      path,
      Paint()
        ..color = _colorFrom(
          color?.valueAt(frame) ?? const <double>[0, 0, 0],
          a,
        ),
    );
  }
}

class _Stroke extends _Paint {
  _Stroke(super.json)
    : color = _animVector(json['c']),
      opacity = _animScalar(json['o']),
      width = _animScalar(json['w']),
      cap = switch (json['lc']) {
        2 => StrokeCap.round,
        3 => StrokeCap.square,
        _ => StrokeCap.butt,
      },
      join = switch (json['lj']) {
        2 => StrokeJoin.round,
        3 => StrokeJoin.bevel,
        _ => StrokeJoin.miter,
      },
      miterLimit = _num(json['ml'], 4),
      dashes = _parseDashes(json['d']);

  final _Animated<List<double>>? color;
  final _Animated<double>? opacity;
  final _Animated<double>? width;
  final StrokeCap cap;
  final StrokeJoin join;
  final double miterLimit;
  final List<MapEntry<String, _Animated<double>>> dashes;

  static List<MapEntry<String, _Animated<double>>> _parseDashes(Object? json) {
    if (json is! List) return const <MapEntry<String, _Animated<double>>>[];
    final List<MapEntry<String, _Animated<double>>> out =
        <MapEntry<String, _Animated<double>>>[];
    for (final Object? d in json) {
      if (d is Map<String, dynamic>) {
        final _Animated<double>? v = _animScalar(d['v']);
        if (v != null) {
          out.add(
            MapEntry<String, _Animated<double>>(d['n'] as String? ?? 'd', v),
          );
        }
      }
    }
    return out;
  }

  Paint strokePaint(double frame, double alpha) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width?.valueAt(frame) ?? 1
    ..strokeCap = cap
    ..strokeJoin = join
    ..strokeMiterLimit = miterLimit
    ..color = _colorFrom(
      color?.valueAt(frame) ?? const <double>[0, 0, 0],
      alpha,
    );

  Path dashed(Path path, double frame) {
    if (dashes.isEmpty) return path;
    final List<double> pattern = <double>[];
    double offset = 0;
    for (final MapEntry<String, _Animated<double>> d in dashes) {
      if (d.key == 'o') {
        offset = d.value.valueAt(frame);
      } else {
        pattern.add(math.max(0, d.value.valueAt(frame)));
      }
    }
    if (pattern.isEmpty || pattern.every((double v) => v <= 0)) return path;
    return _dashPath(path, pattern, offset);
  }

  @override
  void draw(Canvas canvas, double frame, double alpha) {
    final double a = alpha * ((opacity?.valueAt(frame) ?? 100) / 100);
    if (a <= 0 || targets.isEmpty) return;
    final Paint paint = strokePaint(frame, a);
    if (paint.strokeWidth <= 0) return;
    canvas.drawPath(dashed(combinedPath(frame), frame), paint);
  }
}

mixin _GradientMixin {
  int get gradientType;
  _Animated<List<double>>? get startPoint;
  _Animated<List<double>>? get endPoint;
  _Animated<List<double>>? get colorStops;
  int get stopCount;

  ui.Shader? shaderAt(double frame, double alpha) {
    final List<double> k = colorStops?.valueAt(frame) ?? const <double>[];
    final int n = stopCount > 0 ? stopCount : k.length ~/ 4;
    if (n == 0 || k.length < n * 4) return null;
    final List<double> stops = <double>[];
    final List<Color> colors = <Color>[];
    // Alpha stops follow the colour stops as (offset, alpha) pairs.
    final List<double> alphaStops = k.length > n * 4
        ? k.sublist(n * 4)
        : const <double>[];
    double alphaAt(double offset) {
      if (alphaStops.length < 2) return 1;
      if (offset <= alphaStops[0]) return alphaStops[1];
      for (int i = 0; i + 3 < alphaStops.length; i += 2) {
        if (offset <= alphaStops[i + 2]) {
          final double span = alphaStops[i + 2] - alphaStops[i];
          final double t = span <= 0 ? 1 : (offset - alphaStops[i]) / span;
          return _lerpDouble(alphaStops[i + 1], alphaStops[i + 3], t);
        }
      }
      return alphaStops[alphaStops.length - 1];
    }

    for (int i = 0; i < n; i++) {
      final double offset = k[i * 4].clamp(0.0, 1.0);
      stops.add(stops.isNotEmpty && offset < stops.last ? stops.last : offset);
      colors.add(
        _colorFrom(<double>[
          k[i * 4 + 1],
          k[i * 4 + 2],
          k[i * 4 + 3],
        ], alpha * alphaAt(offset)),
      );
    }
    if (colors.length == 1) {
      colors.add(colors.first);
      stops.add(1);
    }
    final List<double> s = startPoint?.valueAt(frame) ?? const <double>[0, 0];
    final List<double> e = endPoint?.valueAt(frame) ?? const <double>[0, 0];
    final Offset start = Offset(
      s.isNotEmpty ? s[0] : 0,
      s.length > 1 ? s[1] : 0,
    );
    final Offset end = Offset(e.isNotEmpty ? e[0] : 0, e.length > 1 ? e[1] : 0);
    if (gradientType == 2) {
      final double radius = (end - start).distance;
      if (radius <= 0) return null;
      return ui.Gradient.radial(start, radius, colors, stops);
    }
    return ui.Gradient.linear(start, end, colors, stops);
  }
}

class _GradientFill extends _Paint with _GradientMixin {
  _GradientFill(super.json)
    : gradientType = json['t'] == 2 ? 2 : 1,
      startPoint = _animVector(json['s']),
      endPoint = _animVector(json['e']),
      colorStops = _animVector((json['g'] as Map<String, dynamic>?)?['k']),
      stopCount =
          ((json['g'] as Map<String, dynamic>?)?['p'] as num?)?.toInt() ?? 0,
      opacity = _animScalar(json['o']),
      fillRule = json['r'] == 2 ? PathFillType.evenOdd : PathFillType.nonZero;

  @override
  final int gradientType;
  @override
  final _Animated<List<double>>? startPoint;
  @override
  final _Animated<List<double>>? endPoint;
  @override
  final _Animated<List<double>>? colorStops;
  @override
  final int stopCount;
  final _Animated<double>? opacity;
  final PathFillType fillRule;

  @override
  void draw(Canvas canvas, double frame, double alpha) {
    final double a = alpha * ((opacity?.valueAt(frame) ?? 100) / 100);
    if (a <= 0 || targets.isEmpty) return;
    final ui.Shader? shader = shaderAt(frame, a);
    if (shader == null) return;
    canvas.drawPath(
      combinedPath(frame)..fillType = fillRule,
      Paint()..shader = shader,
    );
  }
}

class _GradientStroke extends _Stroke with _GradientMixin {
  _GradientStroke(super.json)
    : gradientType = json['t'] == 2 ? 2 : 1,
      startPoint = _animVector(json['s']),
      endPoint = _animVector(json['e']),
      colorStops = _animVector((json['g'] as Map<String, dynamic>?)?['k']),
      stopCount =
          ((json['g'] as Map<String, dynamic>?)?['p'] as num?)?.toInt() ?? 0;

  @override
  final int gradientType;
  @override
  final _Animated<List<double>>? startPoint;
  @override
  final _Animated<List<double>>? endPoint;
  @override
  final _Animated<List<double>>? colorStops;
  @override
  final int stopCount;

  @override
  void draw(Canvas canvas, double frame, double alpha) {
    final double a = alpha * ((opacity?.valueAt(frame) ?? 100) / 100);
    if (a <= 0 || targets.isEmpty) return;
    final ui.Shader? shader = shaderAt(frame, a);
    if (shader == null) return;
    final Paint paint = strokePaint(frame, a)..shader = shader;
    if (paint.strokeWidth <= 0) return;
    canvas.drawPath(dashed(combinedPath(frame), frame), paint);
  }
}

Path _dashPath(Path source, List<double> pattern, double offset) {
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

// ---------------------------------------------------------------------------
// Layers and assets
// ---------------------------------------------------------------------------

class _Mask {
  _Mask(Map<String, dynamic> json)
    : mode = json['mode'] as String? ?? 'a',
      inverted = json['inv'] == true,
      shape = _animShape(json['pt']);

  final String mode;
  final bool inverted;
  final _Animated<_ShapeData>? shape;
}

class _Layer {
  _Layer.fromJson(Map<String, dynamic> json)
    : type = (json['ty'] as num?)?.toInt() ?? -1,
      index = (json['ind'] as num?)?.toInt(),
      parent = (json['parent'] as num?)?.toInt(),
      inPoint = _num(json['ip'], 0),
      outPoint = _num(json['op'], double.infinity),
      startTime = _num(json['st'], 0),
      stretch = _num(json['sr'], 1) == 0 ? 1 : _num(json['sr'], 1),
      transform = _Transform.fromJson(json['ks'] as Map<String, dynamic>?),
      refId = json['refId'] as String?,
      width = _num(json['w'] ?? json['sw'], 0),
      height = _num(json['h'] ?? json['sh'], 0),
      solidColor = json['sc'] is String
          ? _hexColor(json['sc'] as String)
          : null,
      matteType = (json['tt'] as num?)?.toInt() ?? 0,
      isMatteSource = json['td'] == 1,
      hidden = json['hd'] == true,
      timeRemap = _animScalar(json['tm']),
      contents = json['ty'] == 4
          ? _parseContents(json['shapes'])
          : const <_Content>[],
      masks = (json['masksProperties'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_Mask.new)
          .toList(growable: false);

  final int type;
  final int? index;
  final int? parent;
  final double inPoint;
  final double outPoint;
  final double startTime;
  final double stretch;
  final _Transform transform;
  final String? refId;
  final double width;
  final double height;
  final Color? solidColor;
  final int matteType;
  final bool isMatteSource;
  final bool hidden;
  final _Animated<double>? timeRemap;
  final List<_Content> contents;
  final List<_Mask> masks;

  bool isVisibleAt(double frame) => frame >= inPoint && frame < outPoint;

  double localFrame(double frame) => (frame - startTime) / stretch;

  Path? maskPathAt(double frame) {
    Path? result;
    for (final _Mask mask in masks) {
      if (mask.mode == 'n' || mask.shape == null) continue;
      Path p = mask.shape!.valueAt(frame).toPath();
      if (mask.inverted) {
        p = Path.combine(
          PathOperation.difference,
          Path()..addRect(const Rect.fromLTRB(-1e5, -1e5, 1e5, 1e5)),
          p,
        );
      }
      if (result == null) {
        result = p;
        continue;
      }
      result = switch (mask.mode) {
        's' => Path.combine(PathOperation.difference, result, p),
        'i' => Path.combine(PathOperation.intersect, result, p),
        _ => Path.combine(PathOperation.union, result, p),
      };
    }
    return result;
  }

  static Color? _hexColor(String hex) {
    final String h = hex.replaceFirst('#', '');
    final int? v = int.tryParse(h, radix: 16);
    if (v == null) return null;
    return h.length == 8 ? Color(v) : Color(0xFF000000 | v);
  }
}

List<_Layer> _parseLayers(Object? json) {
  if (json is! List) return const <_Layer>[];
  return json
      .whereType<Map<String, dynamic>>()
      .map(_Layer.fromJson)
      .toList(growable: false);
}

class _Asset {
  _Asset.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String? ?? '',
      width = (json['w'] as num?)?.toDouble(),
      height = (json['h'] as num?)?.toDouble(),
      imageSource = _imageSource(json),
      layers = json.containsKey('layers') ? _parseLayers(json['layers']) : null;

  final String id;
  final double? width;
  final double? height;
  final String? imageSource;
  final List<_Layer>? layers;

  static String? _imageSource(Map<String, dynamic> json) {
    final String? p = json['p'] as String?;
    if (p == null || p.isEmpty) return null;
    final String u = json['u'] as String? ?? '';
    if (p.startsWith('data:')) return p;
    final String full = '$u$p';
    return full.startsWith('http://') || full.startsWith('https://')
        ? full
        : null;
  }
}
