/// Parsers for SVG attribute values: path data, transforms, colors, lengths.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Parses SVG path data (`d` attribute) into a [Path].
///
/// Throws [FormatException] on malformed input.
Path parseSvgPath(String data) {
  final _Scanner s = _Scanner(data);
  final Path path = Path();
  double cx = 0, cy = 0; // current point
  double sx = 0, sy = 0; // subpath start
  double? lastCx, lastCy; // last cubic control point (for S)
  double? lastQx, lastQy; // last quadratic control point (for T)
  String? command;

  while (true) {
    s.skipSeparators();
    if (s.done) break;
    final String? next = s.command();
    if (next != null) {
      command = next;
    } else if (command == null) {
      throw FormatException('path data must start with a command', data, s.i);
    } else if (command == 'M') {
      command = 'L';
    } else if (command == 'm') {
      command = 'l';
    } else if (command == 'Z' || command == 'z') {
      throw FormatException('unexpected data after close path', data, s.i);
    }

    final bool relative = command.toLowerCase() == command;
    final double ox = relative ? cx : 0, oy = relative ? cy : 0;
    switch (command.toUpperCase()) {
      case 'M':
        cx = ox + s.number();
        cy = oy + s.number();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        lastCx = lastCy = lastQx = lastQy = null;
      case 'L':
        cx = ox + s.number();
        cy = oy + s.number();
        path.lineTo(cx, cy);
        lastCx = lastCy = lastQx = lastQy = null;
      case 'H':
        cx = ox + s.number();
        path.lineTo(cx, cy);
        lastCx = lastCy = lastQx = lastQy = null;
      case 'V':
        cy = oy + s.number();
        path.lineTo(cx, cy);
        lastCx = lastCy = lastQx = lastQy = null;
      case 'C':
        final double x1 = ox + s.number(), y1 = oy + s.number();
        final double x2 = ox + s.number(), y2 = oy + s.number();
        cx = ox + s.number();
        cy = oy + s.number();
        path.cubicTo(x1, y1, x2, y2, cx, cy);
        lastCx = x2;
        lastCy = y2;
        lastQx = lastQy = null;
      case 'S':
        final double x1 = lastCx == null ? cx : 2 * cx - lastCx;
        final double y1 = lastCy == null ? cy : 2 * cy - lastCy;
        final double x2 = ox + s.number(), y2 = oy + s.number();
        cx = ox + s.number();
        cy = oy + s.number();
        path.cubicTo(x1, y1, x2, y2, cx, cy);
        lastCx = x2;
        lastCy = y2;
        lastQx = lastQy = null;
      case 'Q':
        final double x1 = ox + s.number(), y1 = oy + s.number();
        cx = ox + s.number();
        cy = oy + s.number();
        path.quadraticBezierTo(x1, y1, cx, cy);
        lastQx = x1;
        lastQy = y1;
        lastCx = lastCy = null;
      case 'T':
        final double x1 = lastQx == null ? cx : 2 * cx - lastQx;
        final double y1 = lastQy == null ? cy : 2 * cy - lastQy;
        cx = ox + s.number();
        cy = oy + s.number();
        path.quadraticBezierTo(x1, y1, cx, cy);
        lastQx = x1;
        lastQy = y1;
        lastCx = lastCy = null;
      case 'A':
        final double rx = s.number().abs(), ry = s.number().abs();
        final double rotation = s.number();
        final bool largeArc = s.flag(), sweep = s.flag();
        final double x = ox + s.number(), y = oy + s.number();
        if (rx == 0 || ry == 0) {
          path.lineTo(x, y);
        } else {
          path.arcToPoint(
            Offset(x, y),
            radius: Radius.elliptical(rx, ry),
            rotation: rotation,
            largeArc: largeArc,
            clockwise: sweep,
          );
        }
        cx = x;
        cy = y;
        lastCx = lastCy = lastQx = lastQy = null;
      case 'Z':
        path.close();
        cx = sx;
        cy = sy;
        lastCx = lastCy = lastQx = lastQy = null;
      default:
        throw FormatException('unknown path command "$command"', data, s.i);
    }
  }
  return path;
}

class _Scanner {
  _Scanner(this.src);
  final String src;
  int i = 0;

  bool get done => i >= src.length;

  void skipSeparators() {
    while (!done) {
      final int c = src.codeUnitAt(i);
      if (c == 0x20 || c == 0x2C || c == 0x09 || c == 0x0A || c == 0x0D) {
        i++;
      } else {
        return;
      }
    }
  }

  String? command() {
    final int c = src.codeUnitAt(i);
    if ((c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A)) {
      i++;
      return String.fromCharCode(c);
    }
    return null;
  }

  double number() {
    skipSeparators();
    final int start = i;
    if (!done && (src.codeUnitAt(i) == 0x2B || src.codeUnitAt(i) == 0x2D)) i++;
    bool digits = false;
    while (!done && _isDigit(src.codeUnitAt(i))) {
      i++;
      digits = true;
    }
    if (!done && src.codeUnitAt(i) == 0x2E) {
      i++;
      while (!done && _isDigit(src.codeUnitAt(i))) {
        i++;
        digits = true;
      }
    }
    if (!digits) throw FormatException('expected a number', src, start);
    if (!done && (src.codeUnitAt(i) == 0x65 || src.codeUnitAt(i) == 0x45)) {
      final int save = i;
      i++;
      if (!done && (src.codeUnitAt(i) == 0x2B || src.codeUnitAt(i) == 0x2D)) {
        i++;
      }
      if (!done && _isDigit(src.codeUnitAt(i))) {
        while (!done && _isDigit(src.codeUnitAt(i))) {
          i++;
        }
      } else {
        i = save;
      }
    }
    return double.parse(src.substring(start, i));
  }

  bool flag() {
    skipSeparators();
    if (done) throw FormatException('expected a flag', src, i);
    final int c = src.codeUnitAt(i++);
    if (c == 0x30) return false;
    if (c == 0x31) return true;
    throw FormatException('expected 0 or 1', src, i - 1);
  }

  static bool _isDigit(int c) => c >= 0x30 && c <= 0x39;
}

/// Parses a whitespace/comma separated list of numbers.
List<double> parseNumberList(String value) {
  final List<double> out = <double>[];
  final _Scanner s = _Scanner(value);
  while (true) {
    s.skipSeparators();
    if (s.done) return out;
    out.add(s.number());
  }
}

/// Parses an SVG `transform` attribute into a [Matrix4] (identity if empty).
Matrix4 parseSvgTransform(String? value) {
  final Matrix4 result = Matrix4.identity();
  if (value == null || value.trim().isEmpty) return result;
  final RegExp fn = RegExp(r'([a-zA-Z]+)\s*\(([^)]*)\)');
  for (final RegExpMatch m in fn.allMatches(value)) {
    final String name = m[1]!;
    final List<double> a = parseNumberList(m[2]!);
    final Matrix4 t;
    switch (name) {
      case 'matrix':
        if (a.length != 6) {
          throw FormatException('matrix needs 6 values', value);
        }
        t = Matrix4(
          a[0],
          a[1],
          0,
          0,
          a[2],
          a[3],
          0,
          0,
          0,
          0,
          1,
          0,
          a[4],
          a[5],
          0,
          1,
        );
      case 'translate':
        t = Matrix4.translationValues(a[0], a.length > 1 ? a[1] : 0, 0);
      case 'scale':
        t = Matrix4.diagonal3Values(a[0], a.length > 1 ? a[1] : a[0], 1);
      case 'rotate':
        final double rad = a[0] * math.pi / 180;
        if (a.length >= 3) {
          t = Matrix4.translationValues(a[1], a[2], 0)
            ..rotateZ(rad)
            ..multiply(Matrix4.translationValues(-a[1], -a[2], 0));
        } else {
          t = Matrix4.rotationZ(rad);
        }
      case 'skewX':
        t = Matrix4.identity()..setEntry(0, 1, math.tan(a[0] * math.pi / 180));
      case 'skewY':
        t = Matrix4.identity()..setEntry(1, 0, math.tan(a[0] * math.pi / 180));
      default:
        continue;
    }
    result.multiply(t);
  }
  return result;
}

/// Result of parsing a paint value: a solid color, a reference (`url(#id)`),
/// `none`, or `currentColor`.
class SvgPaint {
  const SvgPaint.color(this.color)
    : reference = null,
      isNone = false,
      isCurrentColor = false;
  const SvgPaint.reference(this.reference)
    : color = null,
      isNone = false,
      isCurrentColor = false;
  const SvgPaint.none()
    : color = null,
      reference = null,
      isNone = true,
      isCurrentColor = false;
  const SvgPaint.currentColor()
    : color = null,
      reference = null,
      isNone = false,
      isCurrentColor = true;

  final Color? color;
  final String? reference;
  final bool isNone;
  final bool isCurrentColor;
}

/// Parses `fill` / `stroke` style values. Returns `null` if unparseable.
SvgPaint? parseSvgPaint(String? value) {
  if (value == null) return null;
  final String v = value.trim();
  if (v.isEmpty || v == 'inherit') return null;
  if (v == 'none' || v == 'transparent') return const SvgPaint.none();
  if (v == 'currentColor' || v == 'currentcolor') {
    return const SvgPaint.currentColor();
  }
  if (v.startsWith('url(')) {
    final int hash = v.indexOf('#');
    final int close = v.indexOf(')');
    if (hash == -1 || close == -1) return null;
    return SvgPaint.reference(v.substring(hash + 1, close).trim());
  }
  final Color? color = parseSvgColor(v);
  return color == null ? null : SvgPaint.color(color);
}

/// Parses a CSS color: `#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa`, `rgb()`,
/// `rgba()`, `hsl()`, `hsla()` or a named color. Returns `null` if unknown.
Color? parseSvgColor(String value) {
  final String v = value.trim().toLowerCase();
  if (v.startsWith('#')) {
    final String hex = v.substring(1);
    if (!RegExp(r'^[0-9a-f]+$').hasMatch(hex)) return null;
    switch (hex.length) {
      case 3:
      case 4:
        final String full = hex.split('').map((c) => '$c$c').join();
        return _hex(
          full.length == 6
              ? 'ff$full'
              : full.substring(6) + full.substring(0, 6),
        );
      case 6:
        return _hex('ff$hex');
      case 8:
        return _hex(hex.substring(6) + hex.substring(0, 6));
      default:
        return null;
    }
  }
  final RegExpMatch? fn = RegExp(r'^(rgba?|hsla?)\s*\((.*)\)$').firstMatch(v);
  if (fn != null) {
    final List<String> parts = fn[2]!
        .replaceAll('/', ' ')
        .split(RegExp(r'[\s,]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length < 3) return null;
    double alpha = 1;
    if (parts.length > 3) {
      alpha = _percentOr(parts[3], 1);
    }
    if (fn[1]!.startsWith('rgb')) {
      final int r = _channel(parts[0]),
          g = _channel(parts[1]),
          b = _channel(parts[2]);
      return Color.fromARGB((alpha * 255).round().clamp(0, 255), r, g, b);
    }
    final double h =
        (double.tryParse(parts[0].replaceAll('deg', '')) ?? 0) % 360;
    final double s = _percentOr(parts[1], 1);
    final double l = _percentOr(parts[2], 1);
    return HSLColor.fromAHSL(
      alpha.clamp(0, 1),
      h,
      s.clamp(0, 1),
      l.clamp(0, 1),
    ).toColor();
  }
  final int? named = _namedColors[v];
  return named == null ? null : Color(named);
}

Color _hex(String argb) => Color(int.parse(argb, radix: 16));

int _channel(String v) {
  if (v.endsWith('%')) {
    return ((double.tryParse(v.substring(0, v.length - 1)) ?? 0) * 2.55)
        .round()
        .clamp(0, 255);
  }
  return (double.tryParse(v) ?? 0).round().clamp(0, 255);
}

double _percentOr(String v, double scale) {
  if (v.endsWith('%')) {
    return (double.tryParse(v.substring(0, v.length - 1)) ?? 0) / 100 * scale;
  }
  return double.tryParse(v) ?? 0;
}

/// Parses a length such as `12`, `12px`, `50%`, `1.5em`. Percentages resolve
/// against [reference]; returns `null` if unparseable.
double? parseSvgLength(
  String? value, {
  double? reference,
  double fontSize = 16,
}) {
  if (value == null) return null;
  final String v = value.trim();
  if (v.isEmpty) return null;
  final RegExpMatch? m = RegExp(
    r'^([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)\s*([a-z%]*)$',
  ).firstMatch(v);
  if (m == null) return null;
  final double n = double.parse(m[1]!);
  switch (m[2]) {
    case '':
    case 'px':
      return n;
    case '%':
      return reference == null ? null : n / 100 * reference;
    case 'em':
      return n * fontSize;
    case 'pt':
      return n * 4 / 3;
    case 'pc':
      return n * 16;
    case 'in':
      return n * 96;
    case 'cm':
      return n * 96 / 2.54;
    case 'mm':
      return n * 96 / 25.4;
    default:
      return null;
  }
}

/// Parses a `0..1` number or `n%` opacity value.
double? parseSvgOpacity(String? value) {
  if (value == null) return null;
  final String v = value.trim();
  if (v.endsWith('%')) {
    final double? n = double.tryParse(v.substring(0, v.length - 1));
    return n == null ? null : (n / 100).clamp(0.0, 1.0);
  }
  final double? n = double.tryParse(v);
  return n?.clamp(0.0, 1.0);
}

const Map<String, int> _namedColors = <String, int>{
  'aliceblue': 0xFFF0F8FF,
  'antiquewhite': 0xFFFAEBD7,
  'aqua': 0xFF00FFFF,
  'aquamarine': 0xFF7FFFD4,
  'azure': 0xFFF0FFFF,
  'beige': 0xFFF5F5DC,
  'bisque': 0xFFFFE4C4,
  'black': 0xFF000000,
  'blanchedalmond': 0xFFFFEBCD,
  'blue': 0xFF0000FF,
  'blueviolet': 0xFF8A2BE2,
  'brown': 0xFFA52A2A,
  'burlywood': 0xFFDEB887,
  'cadetblue': 0xFF5F9EA0,
  'chartreuse': 0xFF7FFF00,
  'chocolate': 0xFFD2691E,
  'coral': 0xFFFF7F50,
  'cornflowerblue': 0xFF6495ED,
  'cornsilk': 0xFFFFF8DC,
  'crimson': 0xFFDC143C,
  'cyan': 0xFF00FFFF,
  'darkblue': 0xFF00008B,
  'darkcyan': 0xFF008B8B,
  'darkgoldenrod': 0xFFB8860B,
  'darkgray': 0xFFA9A9A9,
  'darkgreen': 0xFF006400,
  'darkgrey': 0xFFA9A9A9,
  'darkkhaki': 0xFFBDB76B,
  'darkmagenta': 0xFF8B008B,
  'darkolivegreen': 0xFF556B2F,
  'darkorange': 0xFFFF8C00,
  'darkorchid': 0xFF9932CC,
  'darkred': 0xFF8B0000,
  'darksalmon': 0xFFE9967A,
  'darkseagreen': 0xFF8FBC8F,
  'darkslateblue': 0xFF483D8B,
  'darkslategray': 0xFF2F4F4F,
  'darkslategrey': 0xFF2F4F4F,
  'darkturquoise': 0xFF00CED1,
  'darkviolet': 0xFF9400D3,
  'deeppink': 0xFFFF1493,
  'deepskyblue': 0xFF00BFFF,
  'dimgray': 0xFF696969,
  'dimgrey': 0xFF696969,
  'dodgerblue': 0xFF1E90FF,
  'firebrick': 0xFFB22222,
  'floralwhite': 0xFFFFFAF0,
  'forestgreen': 0xFF228B22,
  'fuchsia': 0xFFFF00FF,
  'gainsboro': 0xFFDCDCDC,
  'ghostwhite': 0xFFF8F8FF,
  'gold': 0xFFFFD700,
  'goldenrod': 0xFFDAA520,
  'gray': 0xFF808080,
  'green': 0xFF008000,
  'greenyellow': 0xFFADFF2F,
  'grey': 0xFF808080,
  'honeydew': 0xFFF0FFF0,
  'hotpink': 0xFFFF69B4,
  'indianred': 0xFFCD5C5C,
  'indigo': 0xFF4B0082,
  'ivory': 0xFFFFFFF0,
  'khaki': 0xFFF0E68C,
  'lavender': 0xFFE6E6FA,
  'lavenderblush': 0xFFFFF0F5,
  'lawngreen': 0xFF7CFC00,
  'lemonchiffon': 0xFFFFFACD,
  'lightblue': 0xFFADD8E6,
  'lightcoral': 0xFFF08080,
  'lightcyan': 0xFFE0FFFF,
  'lightgoldenrodyellow': 0xFFFAFAD2,
  'lightgray': 0xFFD3D3D3,
  'lightgreen': 0xFF90EE90,
  'lightgrey': 0xFFD3D3D3,
  'lightpink': 0xFFFFB6C1,
  'lightsalmon': 0xFFFFA07A,
  'lightseagreen': 0xFF20B2AA,
  'lightskyblue': 0xFF87CEFA,
  'lightslategray': 0xFF778899,
  'lightslategrey': 0xFF778899,
  'lightsteelblue': 0xFFB0C4DE,
  'lightyellow': 0xFFFFFFE0,
  'lime': 0xFF00FF00,
  'limegreen': 0xFF32CD32,
  'linen': 0xFFFAF0E6,
  'magenta': 0xFFFF00FF,
  'maroon': 0xFF800000,
  'mediumaquamarine': 0xFF66CDAA,
  'mediumblue': 0xFF0000CD,
  'mediumorchid': 0xFFBA55D3,
  'mediumpurple': 0xFF9370DB,
  'mediumseagreen': 0xFF3CB371,
  'mediumslateblue': 0xFF7B68EE,
  'mediumspringgreen': 0xFF00FA9A,
  'mediumturquoise': 0xFF48D1CC,
  'mediumvioletred': 0xFFC71585,
  'midnightblue': 0xFF191970,
  'mintcream': 0xFFF5FFFA,
  'mistyrose': 0xFFFFE4E1,
  'moccasin': 0xFFFFE4B5,
  'navajowhite': 0xFFFFDEAD,
  'navy': 0xFF000080,
  'oldlace': 0xFFFDF5E6,
  'olive': 0xFF808000,
  'olivedrab': 0xFF6B8E23,
  'orange': 0xFFFFA500,
  'orangered': 0xFFFF4500,
  'orchid': 0xFFDA70D6,
  'palegoldenrod': 0xFFEEE8AA,
  'palegreen': 0xFF98FB98,
  'paleturquoise': 0xFFAFEEEE,
  'palevioletred': 0xFFDB7093,
  'papayawhip': 0xFFFFEFD5,
  'peachpuff': 0xFFFFDAB9,
  'peru': 0xFFCD853F,
  'pink': 0xFFFFC0CB,
  'plum': 0xFFDDA0DD,
  'powderblue': 0xFFB0E0E6,
  'purple': 0xFF800080,
  'rebeccapurple': 0xFF663399,
  'red': 0xFFFF0000,
  'rosybrown': 0xFFBC8F8F,
  'royalblue': 0xFF4169E1,
  'saddlebrown': 0xFF8B4513,
  'salmon': 0xFFFA8072,
  'sandybrown': 0xFFF4A460,
  'seagreen': 0xFF2E8B57,
  'seashell': 0xFFFFF5EE,
  'sienna': 0xFFA0522D,
  'silver': 0xFFC0C0C0,
  'skyblue': 0xFF87CEEB,
  'slateblue': 0xFF6A5ACD,
  'slategray': 0xFF708090,
  'slategrey': 0xFF708090,
  'snow': 0xFFFFFAFA,
  'springgreen': 0xFF00FF7F,
  'steelblue': 0xFF4682B4,
  'tan': 0xFFD2B48C,
  'teal': 0xFF008080,
  'thistle': 0xFFD8BFD8,
  'tomato': 0xFFFF6347,
  'turquoise': 0xFF40E0D0,
  'violet': 0xFFEE82EE,
  'wheat': 0xFFF5DEB3,
  'white': 0xFFFFFFFF,
  'whitesmoke': 0xFFF5F5F5,
  'yellow': 0xFFFFFF00,
  'yellowgreen': 0xFF9ACD32,
};
