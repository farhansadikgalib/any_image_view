import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:any_image_view/any_image_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders [svg] into a [size] bitmap and returns the ARGB pixel at ([x], [y]).
Future<Color> pixel(
  String svg,
  int x,
  int y, {
  Size size = const Size(10, 10),
  ColorFilter? filter,
  BoxFit fit = BoxFit.contain,
}) async {
  final SvgDocument doc = SvgDocument.parse(svg);
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  doc.paint(canvas, size, fit: fit, colorFilter: filter);
  final ui.Image image = await recorder.endRecording().toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
  final ByteData? data = await image.toByteData();
  final int offset = (y * image.width + x) * 4;
  final Color color = Color.fromARGB(
    data!.getUint8(offset + 3),
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
  );
  image.dispose();
  doc.dispose();
  return color;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String red = '#ff0000';

  test('basic shapes fill the expected pixels', () async {
    const String svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">'
        '<rect width="5" height="10" fill="$red"/>'
        '<circle cx="7.5" cy="5" r="2" fill="blue"/></svg>';
    expect(await pixel(svg, 2, 5), const Color(0xFFFF0000));
    expect(await pixel(svg, 7, 5), const Color(0xFF0000FF));
    expect((await pixel(svg, 9, 0)).a, 0);
  });

  test('path, transform, group opacity and stroke', () async {
    const String svg =
        '<svg viewBox="0 0 10 10">'
        '<g transform="translate(5 0)"><path d="M0 0h5v10h-5z" fill="$red"/></g>'
        '<g opacity="0.5"><rect width="5" height="5" fill="black"/></g>'
        '<line x1="0" y1="8" x2="5" y2="8" stroke="lime" stroke-width="2"/></svg>';
    expect(await pixel(svg, 7, 5), const Color(0xFFFF0000));
    expect((await pixel(svg, 2, 2)).a, closeTo(0.5, 0.03));
    expect(await pixel(svg, 2, 8), const Color(0xFF00FF00));
  });

  test('css classes, inline style and currentColor', () async {
    const String svg =
        '<svg viewBox="0 0 10 10" color="$red">'
        '<style>.a { fill: blue } #b { fill: lime }</style>'
        '<rect class="a" width="3" height="10"/>'
        '<rect id="b" x="3" width="3" height="10" style="fill: yellow"/>'
        '<rect x="6" width="4" height="10" fill="currentColor"/></svg>';
    expect(await pixel(svg, 1, 5), const Color(0xFF0000FF));
    expect(await pixel(svg, 4, 5), const Color(0xFFFFFF00));
    expect(await pixel(svg, 8, 5), const Color(0xFFFF0000));
  });

  test('use/symbol, defs and linear gradient', () async {
    const String svg =
        '<svg viewBox="0 0 10 10">'
        '<defs><linearGradient id="g" x1="0" x2="1" y1="0" y2="0">'
        '<stop offset="0" stop-color="$red"/><stop offset="1" stop-color="$red"/></linearGradient>'
        '<symbol id="s"><rect width="10" height="5" fill="url(#g)"/></symbol></defs>'
        '<use href="#s" y="5"/></svg>';
    expect((await pixel(svg, 5, 2)).a, 0);
    expect(await pixel(svg, 5, 7), const Color(0xFFFF0000));
  });

  test('clip-path and display:none', () async {
    const String svg =
        '<svg viewBox="0 0 10 10">'
        '<clipPath id="c"><rect width="5" height="10"/></clipPath>'
        '<rect width="10" height="10" fill="$red" clip-path="url(#c)"/>'
        '<rect width="10" height="10" fill="blue" display="none"/></svg>';
    expect(await pixel(svg, 2, 5), const Color(0xFFFF0000));
    expect((await pixel(svg, 8, 5)).a, 0);
  });

  test('color filter tints the whole drawing', () async {
    const String svg =
        '<svg viewBox="0 0 10 10"><rect width="10" height="10" fill="$red"/></svg>';
    expect(
      await pixel(
        svg,
        5,
        5,
        filter: const ColorFilter.mode(Color(0xFF00FF00), BlendMode.srcIn),
      ),
      const Color(0xFF00FF00),
    );
  });

  test('viewBox aspect ratio is preserved with BoxFit.contain', () async {
    const String svg =
        '<svg viewBox="0 0 10 5"><rect width="10" height="5" fill="$red"/></svg>';
    expect(
      await pixel(svg, 5, 5, size: const Size(10, 10)),
      const Color(0xFFFF0000),
    );
    expect((await pixel(svg, 5, 0, size: const Size(10, 10))).a, 0);
    expect(
      await pixel(svg, 5, 0, size: const Size(10, 10), fit: BoxFit.fill),
      const Color(0xFFFF0000),
    );
  });

  test('sizing falls back to width/height, then to content bounds', () {
    expect(
      SvgDocument.parse(
        '<svg width="30" height="20"><rect width="1" height="1"/></svg>',
      ).size,
      const Size(30, 20),
    );
    expect(
      SvgDocument.parse('<svg viewBox="0 0 8 4"/>').size,
      const Size(8, 4),
    );
    expect(
      SvgDocument.parse('<svg><rect x="5" y="5" width="10" height="20"/></svg>')
          .viewBox,
      const Rect.fromLTWH(5, 5, 10, 20),
    );
  });

  test('invalid documents throw', () {
    expect(() => SvgDocument.parse('<div/>'), throwsFormatException);
    expect(() => SvgDocument.parse('not xml'), throwsA(anything));
  });

  test('renders the example asset', () async {
    final String svg = File('example/assets/svg/flutter.svg')
        .readAsStringSync();
    final SvgDocument doc = SvgDocument.parse(svg);
    expect(doc.viewBox, const Rect.fromLTWH(0, 0, 48, 48));
    expect(doc.size, const Size(480, 480));
    expect(
      await pixel(svg, 26, 26, size: const Size(48, 48)),
      isNot(const Color(0x00000000)),
    );
    doc.dispose();
  });

  testWidgets('AnySvg widget reports parse errors through errorBuilder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AnySvg.string(
          '<broken',
          errorBuilder: (_, _) => const Text('bad'),
        ),
      ),
    );
    expect(find.text('bad'), findsOneWidget);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AnySvg.string('<svg viewBox="0 0 1 1"/>', width: 20),
      ),
    );
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.byType(AspectRatio), findsOneWidget);
  });
}
