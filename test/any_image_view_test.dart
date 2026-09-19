import 'dart:io';

import 'package:any_image_view/any_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a throwaway file with [extension] that is deleted after the test.
File _tempFile(String extension) {
  final File file = File(
    '${Directory.systemTemp.path}/any_image_view_'
    '${DateTime.now().microsecondsSinceEpoch}.$extension',
  );
  file.writeAsBytesSync(const <int>[0]);
  addTearDown(() {
    if (file.existsSync()) file.deleteSync();
  });
  return file;
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Stands in for `XFile` / `File`: any object with a `path` getter works.
class _FakeXFile {
  const _FakeXFile(this.path);
  final String path;
}

void main() {
  group('ImageType extension', () {
    group('network URLs', () {
      test('https URL returns ImageType.network', () {
        expect('https://example.com/image.png'.imageType, ImageType.network);
      });
      test('http URL returns ImageType.network', () {
        expect('http://example.com/photo.jpg'.imageType, ImageType.network);
      });
      test('upper-case scheme returns ImageType.network', () {
        expect('HTTPS://example.com/photo.jpg'.imageType, ImageType.network);
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
      test('https URL ending in .json is network (not lottie asset)', () {
        expect('https://example.com/a.json'.imageType, ImageType.network);
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
      test('.jpg and .jpeg return ImageType.jpeg', () {
        expect('assets/images/photo.jpg'.imageType, ImageType.jpeg);
        expect('assets/images/photo.jpeg'.imageType, ImageType.jpeg);
      });
      test('.webp returns ImageType.webp', () {
        expect('assets/images/photo.webp'.imageType, ImageType.webp);
      });
      test('.gif returns ImageType.gif', () {
        expect('assets/images/anim.gif'.imageType, ImageType.gif);
      });
      test('.tif and .tiff return ImageType.tiff', () {
        expect('assets/images/scan.tif'.imageType, ImageType.tiff);
        expect('assets/images/photo.tiff'.imageType, ImageType.tiff);
      });
      test('.raw returns ImageType.raw', () {
        expect('assets/images/photo.raw'.imageType, ImageType.raw);
      });
      test('.heic / .heif return their types', () {
        expect('assets/images/photo.heic'.imageType, ImageType.heic);
        expect('assets/images/photo.heif'.imageType, ImageType.heif);
      });
      test('.bmp / .ico / .exr / .hdr return their types', () {
        expect('assets/images/photo.bmp'.imageType, ImageType.bmp);
        expect('assets/icons/app.ico'.imageType, ImageType.ico);
        expect('assets/images/photo.exr'.imageType, ImageType.exr);
        expect('assets/images/photo.hdr'.imageType, ImageType.hdr);
      });
      test('upper-case extensions are detected', () {
        expect('assets/icons/logo.SVG'.imageType, ImageType.svg);
        expect('assets/lottie/anim.JSON'.imageType, ImageType.json);
        expect('assets/images/photo.JPG'.imageType, ImageType.jpeg);
        expect('assets/images/photo.WebP'.imageType, ImageType.webp);
      });
      test('query string and fragment are ignored', () {
        expect('assets/icons/logo.svg?v=2'.imageType, ImageType.svg);
        expect('assets/icons/logo.svg#layer'.imageType, ImageType.svg);
        expect('assets/icons/logo.svg?v=2#layer'.imageType, ImageType.svg);
      });
      test('path with no extension defaults to ImageType.png', () {
        expect('assets/images/photo'.imageType, ImageType.png);
      });
      test('edge cases: empty, query-only and fragment-only strings', () {
        expect(''.imageType, ImageType.png);
        expect('?v=1'.imageType, ImageType.png);
        expect('#frag'.imageType, ImageType.png);
        expect('.svg'.imageType, ImageType.svg);
        expect('photo.'.imageType, ImageType.png);
      });
      test('dot in a directory segment does not confuse detection', () {
        expect('assets/v1.2/photo'.imageType, ImageType.png);
      });
      test('.avif returns ImageType.avif', () {
        expect('assets/images/photo.avif'.imageType, ImageType.avif);
        expect('assets/images/photo.AVIF?v=2'.imageType, ImageType.avif);
      });
    });
  });

  group('AnyImageView builds the right child for each source', () {
    testWidgets('network image URL builds Image with AnyNetworkImage', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: 'https://example.com/photo.jpg',
            width: 100,
            height: 100,
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<Image>(find.byType(Image)).image,
        isA<AnyNetworkImage>(),
      );
    });

    testWidgets(
      'network URL with query string builds Image with AnyNetworkImage',
      (tester) async {
        await tester.pumpWidget(
          _app(
            const AnyImageView(
              imagePath: 'https://cdn.example.com/image.png?token=abc',
              width: 100,
              height: 100,
            ),
          ),
        );
        await tester.pump();
        expect(
          tester.widget<Image>(find.byType(Image)).image,
          isA<AnyNetworkImage>(),
        );
      },
    );

    testWidgets('null imagePath shows error fallback (broken image)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const AnyImageView(imagePath: null, width: 100, height: 100)),
      );
      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('empty string imagePath shows error fallback', (tester) async {
      await tester.pumpWidget(
        _app(const AnyImageView(imagePath: '', width: 100, height: 100)),
      );
      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('unsupported imagePath type shows error fallback', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const AnyImageView(imagePath: 42, width: 100, height: 100)),
      );
      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('custom errorWidget replaces the default fallback', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: null,
            width: 100,
            height: 100,
            errorWidget: Text('nope'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('nope'), findsOneWidget);
      expect(find.byIcon(Icons.broken_image), findsNothing);
    });

    testWidgets('missing asset SVG shows loading then error fallback', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: 'assets/svg/icon.svg',
            width: 100,
            height: 100,
          ),
        ),
      );
      // No asset in the test package: the load fails and the fallback shows.
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('custom placeholderWidget is used while loading', (
      tester,
    ) async {
      // A network image stays in the loading state (initial fetch, then the
      // retry back-off) long enough to observe the placeholder reliably.
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: 'https://example.com/photo.jpg',
            width: 100,
            height: 100,
            placeholderWidget: Text('loading'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('loading'), findsOneWidget);
      expect(find.byType(Shimmer), findsNothing);
    });

    testWidgets('missing asset JSON shows loading then error fallback', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: 'assets/lottie/animation.json',
            width: 100,
            height: 100,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('asset PNG path builds Image (asset)', (tester) async {
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: 'assets/images/photo.png',
            width: 100,
            height: 100,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('missing local file path shows error fallback', (tester) async {
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: '/definitely/not/here.png',
            width: 100,
            height: 100,
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('existing local file path builds Image (file route)', (
      tester,
    ) async {
      final File file = _tempFile('png');
      await tester.pumpWidget(
        _app(AnyImageView(imagePath: file.path, width: 100, height: 100)),
      );
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Shimmer), findsNothing);
    });

    testWidgets('file:// URI resolves to the same file', (tester) async {
      final File file = _tempFile('png');
      await tester.pumpWidget(
        _app(
          AnyImageView(imagePath: file.uri.toString(), width: 100, height: 100),
        ),
      );
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.broken_image), findsNothing);
    });

    testWidgets('object with a path getter builds Image (file route)', (
      tester,
    ) async {
      final File file = _tempFile('jpg');
      await tester.pumpWidget(
        _app(
          AnyImageView(
            imagePath: _FakeXFile(file.path),
            width: 100,
            height: 100,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('XFile with empty path shows error fallback', (tester) async {
      await tester.pumpWidget(
        _app(
          AnyImageView(
            imagePath: const _FakeXFile(''),
            width: 100,
            height: 100,
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });
  });

  group('AnyImageView layout and interaction', () {
    testWidgets('works without a Material ancestor', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AnyImageView(
            imagePath: null,
            width: 100,
            height: 100,
            onTap: () => tapped++,
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(AnyImageView));
      expect(tapped, 1);
    });

    testWidgets('no gesture wrapper when nothing handles taps', (tester) async {
      await tester.pumpWidget(
        _app(const AnyImageView(imagePath: null, width: 100, height: 100)),
      );
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(AnyImageView),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('circle shape clips with ClipOval', (tester) async {
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: null,
            width: 100,
            height: 100,
            shape: BoxShape.circle,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ClipOval), findsOneWidget);
      expect(find.byType(ClipRRect), findsNothing);
    });

    testWidgets('rounded rectangle clips with ClipRRect, plain one does not', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: null,
            width: 100,
            height: 100,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ClipRRect), findsOneWidget);

      await tester.pumpWidget(
        _app(const AnyImageView(imagePath: null, width: 100, height: 100)),
      );
      await tester.pump();
      expect(find.byType(ClipRRect), findsNothing);
      expect(find.byType(ClipOval), findsNothing);
    });

    testWidgets('enableZoom wraps the image in InteractiveViewer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const AnyImageView(
            imagePath: null,
            width: 100,
            height: 100,
            enableZoom: true,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets(
      'enableFullscreen: true opens dialog with close button on tap',
      (tester) async {
        await tester.pumpWidget(
          _app(
            const AnyImageView(
              imagePath: 'https://example.com/photo.jpg',
              width: 100,
              height: 100,
              enableFullscreen: true,
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(AnyImageView).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);

        final InteractiveViewer viewer = tester.widget<InteractiveViewer>(
          find.byType(InteractiveViewer),
        );
        expect(viewer.scaleEnabled, isTrue);
        expect(viewer.panEnabled, isTrue);
        expect(viewer.maxScale, greaterThan(viewer.minScale));

        // Double-tap zooms in; a second double-tap resets.
        final TransformationController controller =
            viewer.transformationController!;
        expect(controller.value, Matrix4.identity());
        await tester.tap(find.byType(InteractiveViewer));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.byType(InteractiveViewer));
        await tester.pump(const Duration(milliseconds: 50));
        expect(controller.value, isNot(Matrix4.identity()));
        expect(controller.value.getMaxScaleOnAxis(), closeTo(2.5, 0.001));

        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.byType(InteractiveViewer));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.byType(InteractiveViewer));
        await tester.pump(const Duration(milliseconds: 50));
        expect(controller.value, Matrix4.identity());

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(Dialog), findsNothing);
      },
    );

    testWidgets(
      'enableFullscreen: true does NOT open dialog when onTap is provided',
      (tester) async {
        var tapped = 0;
        await tester.pumpWidget(
          _app(
            AnyImageView(
              imagePath: 'https://example.com/photo.jpg',
              width: 100,
              height: 100,
              enableFullscreen: true,
              onTap: () => tapped++,
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(AnyImageView).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(tapped, 1);
        expect(find.byType(Dialog), findsNothing);
      },
    );
  });

  group('Shimmer', () {
    testWidgets('renders an animated ShaderMask and disposes cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const Shimmer(width: 100, height: 100)));
      expect(find.byType(ShaderMask), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(_app(const SizedBox()));
      expect(tester.takeException(), isNull);
    });
  });
}
