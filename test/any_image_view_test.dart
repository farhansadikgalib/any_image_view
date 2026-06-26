import 'dart:io';

import 'package:any_image_view/any_image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  group('ImageType extension', () {
    group('network URLs', () {
      test('https URL returns ImageType.network', () {
        expect('https://example.com/image.png'.imageType, ImageType.network);
      });
      test('http URL returns ImageType.network', () {
        expect('http://example.com/photo.jpg'.imageType, ImageType.network);
      });
      test('network SVG URL returns ImageType.network', () {
        expect('https://example.com/icon.svg'.imageType, ImageType.network);
      });
      test('network URL with query string returns ImageType.network', () {
        expect(
          'https://cdn.example.com/img.svg?token=abc'.imageType,
          ImageType.network,
        );
      });
    });

    group('file paths', () {
      test('file:// prefix returns ImageType.file', () {
        expect('file:///tmp/photo.png'.imageType, ImageType.file);
      });
      test('absolute path starting with / returns ImageType.file', () {
        expect('/data/local/image.jpg'.imageType, ImageType.file);
      });
      test('file path ending in .svg still returns ImageType.file', () {
        expect('/tmp/icon.svg'.imageType, ImageType.file);
      });
      test('file path ending in .avif still returns ImageType.file', () {
        expect('/tmp/photo.avif'.imageType, ImageType.file);
      });
    });

    group('asset paths by extension', () {
      test('.svg returns ImageType.svg', () {
        expect('assets/icons/logo.svg'.imageType, ImageType.svg);
      });
      test('.json returns ImageType.json', () {
        expect('assets/lottie/animation.json'.imageType, ImageType.json);
      });
      test('.zip returns ImageType.zip', () {
        expect('assets/lottie/animation.zip'.imageType, ImageType.zip);
      });
      test('.avif returns ImageType.avif', () {
        expect('assets/images/photo.avif'.imageType, ImageType.avif);
      });
      test('.png returns ImageType.png', () {
        expect('assets/images/photo.png'.imageType, ImageType.png);
      });
      test('.jpg returns ImageType.jpeg', () {
        expect('assets/images/photo.jpg'.imageType, ImageType.jpeg);
      });
      test('.jpeg returns ImageType.jpeg', () {
        expect('assets/images/photo.jpeg'.imageType, ImageType.jpeg);
      });
      test('.webp returns ImageType.webp', () {
        expect('assets/images/photo.webp'.imageType, ImageType.webp);
      });
      test('.gif returns ImageType.gif', () {
        expect('assets/images/anim.gif'.imageType, ImageType.gif);
      });
      test('.tiff returns ImageType.tiff', () {
        expect('assets/images/photo.tiff'.imageType, ImageType.tiff);
      });
      test('.raw returns ImageType.raw', () {
        expect('assets/images/photo.raw'.imageType, ImageType.raw);
      });
      test('.heic returns ImageType.heic', () {
        expect('assets/images/photo.heic'.imageType, ImageType.heic);
      });
      test('.heif returns ImageType.heif', () {
        expect('assets/images/photo.heif'.imageType, ImageType.heif);
      });
      test('.bmp returns ImageType.bmp', () {
        expect('assets/images/photo.bmp'.imageType, ImageType.bmp);
      });
      test('.ico returns ImageType.ico', () {
        expect('assets/icons/app.ico'.imageType, ImageType.ico);
      });
      test('.exr returns ImageType.exr', () {
        expect('assets/images/photo.exr'.imageType, ImageType.exr);
      });
      test('.hdr returns ImageType.hdr', () {
        expect('assets/images/photo.hdr'.imageType, ImageType.hdr);
      });
      test('path with no extension defaults to ImageType.png', () {
        expect('assets/images/photo'.imageType, ImageType.png);
      });
    });

    group('URL vs extension order', () {
      test('https URL ending in .svg is network (not svg asset)', () {
        expect('https://example.com/a.svg'.imageType, ImageType.network);
      });
      test('https URL ending in .json is network (not lottie asset)', () {
        expect('https://example.com/a.json'.imageType, ImageType.network);
      });
      test('https URL ending in .avif is network (not avif asset)', () {
        expect('https://example.com/photo.avif'.imageType, ImageType.network);
      });
      test('https URL with .avif and query string returns ImageType.network', () {
        expect(
          'https://cdn.example.com/photo.avif?token=abc'.imageType,
          ImageType.network,
        );
      });
    });
  });

  group('AnyImageView widget builds correct child for format', () {
    // Network SVG: extension test verifies URL → ImageType.network; routing to
    // SvgPicture.network is in code. Widget test skipped (HTTP 400 in test env).

    testWidgets('network image URL builds CachedNetworkImage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'https://example.com/photo.jpg',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('network PNG URL builds CachedNetworkImage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'https://example.com/image.png',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('network AVIF URL builds CachedNetworkAvifImage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'https://example.com/photo.avif',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CachedNetworkAvifImage), findsOneWidget);
    });

    testWidgets('network AVIF URL with query string builds CachedNetworkAvifImage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'https://cdn.example.com/photo.avif?token=abc',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CachedNetworkAvifImage), findsOneWidget);
    });

    testWidgets('null imagePath shows error fallback (broken image)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(imagePath: null, width: 100, height: 100),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('empty string imagePath shows error fallback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(imagePath: '', width: 100, height: 100),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('asset SVG path shows loading then SvgPicture or error fallback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'assets/svg/icon.svg',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pump();
      // No asset in test package: future fails, so we show error fallback.
      await tester.pumpAndSettle();
      expect(
        find.byIcon(Icons.broken_image),
        findsOneWidget,
      );
    });

    testWidgets('asset JSON path builds Lottie', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'assets/lottie/animation.json',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(LottieBuilder), findsOneWidget);
    });

    testWidgets('asset AVIF path builds AvifImage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'assets/images/photo.avif',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AvifImage), findsOneWidget);
    });

    testWidgets('local file AVIF path builds AvifImage (file route)',
        (tester) async {
      // Real on-disk file required: _buildFileImage's existsSync() gate would
      // otherwise short-circuit to the error fallback before any AvifImage is
      // mounted, so we cannot fake this with a string path alone.
      final tmpFile = File(
        '${Directory.systemTemp.path}/any_image_view_file_route_'
        '${DateTime.now().microsecondsSinceEpoch}.avif',
      );
      tmpFile.writeAsBytesSync(const [0]);
      addTearDown(() {
        if (tmpFile.existsSync()) tmpFile.deleteSync();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: tmpFile.path,
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
      // _buildFileImage wraps the AvifImage in a FutureBuilder<bool> on
      // file.exists(); runAsync lets that future resolve, then pump rebuilds.
      // pumpAndSettle would deadlock on Shimmer's repeating animation.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.byType(AvifImage), findsOneWidget);
    });

    testWidgets('asset PNG path builds Image (asset)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'assets/images/photo.png',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('enableFullscreen: true opens dialog with close button on tap',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'https://example.com/photo.jpg',
              width: 100,
              height: 100,
              enableFullscreen: true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(AnyImageView).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.scaleEnabled, isTrue);
      expect(viewer.panEnabled, isTrue);
      expect(viewer.maxScale, greaterThan(viewer.minScale));

      final controller = viewer.transformationController!;
      expect(controller.value, Matrix4.identity());
      await tester.tap(find.byType(InteractiveViewer));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(InteractiveViewer));
      await tester.pump(const Duration(milliseconds: 50));
      expect(controller.value, isNot(Matrix4.identity()));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets(
        'enableFullscreen: true does NOT open dialog when onTap is provided',
        (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnyImageView(
              imagePath: 'https://example.com/photo.jpg',
              width: 100,
              height: 100,
              enableFullscreen: true,
              onTap: () => tapped++,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(AnyImageView).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tapped, 1);
      expect(find.byType(Dialog), findsNothing);
    });
  });
}
