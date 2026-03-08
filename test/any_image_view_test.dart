import 'package:any_image_view/any_image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
  });
}
