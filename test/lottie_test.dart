import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:any_image_view/any_image_view.dart';
import 'package:any_image_view/src/zip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Color> pixel(LottieComposition comp, double frame, int x, int y) async {
  const Size size = Size(100, 100);
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  comp.paint(Canvas(recorder), size, frame);
  final ui.Image image = await recorder.endRecording().toImage(100, 100);
  final ByteData? data = await image.toByteData();
  final int offset = (y * image.width + x) * 4;
  final Color color = Color.fromARGB(
    data!.getUint8(offset + 3),
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
  );
  image.dispose();
  return color;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Uint8List json = File('test/fixtures/moving_square.json')
      .readAsBytesSync();

  test('parses composition metadata', () async {
    final LottieComposition comp = await LottieComposition.fromBytes(json);
    expect(comp.frameRate, 30);
    expect(comp.size, const Size(100, 100));
    expect(comp.duration, const Duration(seconds: 1));
    comp.dispose();
  });

  test('keyframed position moves the square and easing is applied', () async {
    final LottieComposition comp = await LottieComposition.fromBytes(json);
    expect(await pixel(comp, 0, 25, 50), const Color(0xFFFF0000));
    expect((await pixel(comp, 0, 75, 50)).a, 0);
    expect(await pixel(comp, 15, 50, 50), const Color(0xFFFF0000));
    expect(await pixel(comp, 30, 75, 50), const Color(0xFFFF0000));
    // Ease-in-out: at 25% of the time the square has moved well under 25%
    // (a linear move would already cover x = 42).
    expect((await pixel(comp, 7.5, 42, 50)).a, 0);
    comp.dispose();
  });

  test('reads dotLottie and stored zip bundles', () async {
    for (final String name in <String>[
      'moving_square.lottie',
      'moving_square_stored.zip',
    ]) {
      final Uint8List bytes = File('test/fixtures/$name').readAsBytesSync();
      final Uint8List? entry = readZipEntry(
        bytes,
        (String n) => n.endsWith('a.json'),
      );
      expect(entry, isNotNull, reason: name);
      final LottieComposition comp = await LottieComposition.fromBytes(bytes);
      expect(await pixel(comp, 0, 25, 50), const Color(0xFFFF0000));
      comp.dispose();
    }
  });

  test('rejects invalid input', () async {
    expect(() => LottieComposition.fromJsonString('[]'), throwsFormatException);
    expect(
      () => LottieComposition.fromBytes(
        Uint8List.fromList('PK\x03\x04junk'.codeUnits),
      ),
      throwsFormatException,
    );
  });

  test('renders image layers from the example asset', () async {
    final Uint8List bytes = File('example/assets/lottie/flutter_mobile.json')
        .readAsBytesSync();
    final LottieComposition comp = await LottieComposition.fromBytes(bytes);
    expect(comp.size, const Size(819, 696));
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    comp.paint(Canvas(recorder), const Size(200, 170), 15);
    final ui.Image image = await recorder.endRecording().toImage(200, 170);
    final ByteData? data = await image.toByteData();
    int opaque = 0;
    for (int i = 3; i < data!.lengthInBytes; i += 4) {
      if (data.getUint8(i) > 0) opaque++;
    }
    expect(opaque, greaterThan(100));
    image.dispose();
    comp.dispose();
  });

  testWidgets('AnyLottie animates and disposes cleanly', (
    WidgetTester tester,
  ) async {
    final LottieComposition comp = await LottieComposition.fromBytes(json);
    await tester.pumpWidget(
      AnyLottie(composition: comp, width: 50, height: 50),
    );
    expect(find.byType(CustomPaint), findsWidgets);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox());
    comp.dispose();
    expect(tester.takeException(), isNull);
  });
}
