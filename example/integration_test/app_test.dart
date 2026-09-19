import 'dart:io';

import 'package:any_image_view/any_image_view.dart';
import 'package:example/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Pumps frames for [duration] without waiting for animations to settle
/// (the shimmer and Lottie tiles animate forever).
Future<void> settle(WidgetTester tester, Duration duration) async {
  final DateTime end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The AnyImageView inside the tile whose title is [title].
Finder viewIn(String title) => find.descendant(
  of: find.ancestor(of: find.text(title), matching: find.byType(Card)),
  matching: find.byType(AnyImageView),
);

Future<void> scrollTo(WidgetTester tester, String title) async {
  await tester.scrollUntilVisible(
    find.text(title),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await settle(tester, const Duration(milliseconds: 300));
}

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every tile renders its format', (WidgetTester tester) async {
    app.main();
    await settle(tester, const Duration(seconds: 6));
    await binding.takeScreenshot('01_top');

    // Network image: an Image backed by the package's provider, no fallback.
    final Finder network = viewIn('Network image · tap for fullscreen');
    expect(network, findsOneWidget);
    expect(
      tester
          .widget<Image>(
            find.descendant(of: network, matching: find.byType(Image)),
          )
          .image,
      isA<AnyNetworkImage>(),
    );
    expect(
      find.descendant(of: network, matching: find.byIcon(Icons.broken_image)),
      findsNothing,
    );
    expect(
      find.descendant(of: network, matching: find.byType(Shimmer)),
      findsNothing,
      reason: 'network image should have finished loading',
    );

    expect(
      find.descendant(of: viewIn('PNG asset'), matching: find.byType(Image)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: viewIn('SVG asset'), matching: find.byType(AnySvg)),
      findsOneWidget,
    );

    await scrollTo(tester, 'Network SVG · color filter');
    await settle(tester, const Duration(seconds: 3));
    expect(
      find.descendant(
        of: viewIn('Network SVG · color filter'),
        matching: find.byType(AnySvg),
      ),
      findsOneWidget,
    );
    await binding.takeScreenshot('02_svg');

    await scrollTo(tester, 'AVIF asset');
    await settle(tester, const Duration(seconds: 3));
    final Finder avifAsset = viewIn('AVIF asset');
    expect(
      find.descendant(of: avifAsset, matching: find.byType(Image)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: avifAsset, matching: find.byIcon(Icons.broken_image)),
      findsNothing,
      reason: 'platform decoder should handle AVIF',
    );
    await binding.takeScreenshot('03_avif');

    await scrollTo(tester, 'AVIF network');
    await settle(tester, const Duration(seconds: 5));
    final Finder avifNet = viewIn('AVIF network');
    expect(
      find.descendant(of: avifNet, matching: find.byIcon(Icons.broken_image)),
      findsNothing,
    );
    expect(
      find.descendant(of: avifNet, matching: find.byType(Shimmer)),
      findsNothing,
    );
    await binding.takeScreenshot('04_avif_network');

    await scrollTo(tester, 'Lottie animation');
    await settle(tester, const Duration(seconds: 3));
    expect(
      find.descendant(
        of: viewIn('Lottie animation'),
        matching: find.byType(AnyLottie),
      ),
      findsOneWidget,
    );
    await binding.takeScreenshot('05_lottie');

    await scrollTo(tester, 'Circular avatar');
    await settle(tester, const Duration(seconds: 4));
    final Finder avatar = viewIn('Circular avatar');
    expect(
      find.descendant(of: avatar, matching: find.byType(ClipOval)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: avatar, matching: find.byIcon(Icons.broken_image)),
      findsNothing,
    );
    expect(
      find.descendant(of: avatar, matching: find.byType(Shimmer)),
      findsNothing,
    );

    await scrollTo(tester, 'Custom error widget');
    // Initial attempt + 3 retries with 300/600/900 ms back-off.
    await settle(tester, const Duration(seconds: 5));
    expect(find.text('Image not available'), findsOneWidget);
    await binding.takeScreenshot('06_bottom');

    // Disk cache: every network resource loaded above must be on disk.
    final String? dir = await AnyImageCache.directory;
    expect(dir, isNotNull);
    final List<FileSystemEntity> files = Directory(dir!).listSync();
    expect(
      files.where((f) => !f.path.endsWith('.part')).length,
      greaterThanOrEqualTo(4),
      reason:
          'mountain photo, network SVG, AVIF fox and avatar should be cached in $dir',
    );
  });

  testWidgets('fullscreen opens, zooms on double tap and closes', (
    WidgetTester tester,
  ) async {
    app.main();
    await settle(tester, const Duration(seconds: 4));
    await tester.tap(viewIn('Network image · tap for fullscreen'));
    await settle(tester, const Duration(seconds: 1));
    expect(find.byType(Dialog), findsOneWidget);
    await binding.takeScreenshot('07_fullscreen');

    final Finder viewer = find.byType(InteractiveViewer);
    final TransformationController controller = tester
        .widget<InteractiveViewer>(viewer)
        .transformationController!;
    expect(controller.value, Matrix4.identity());
    await tester.tap(viewer);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(viewer);
    await settle(tester, const Duration(milliseconds: 500));
    expect(controller.value.getMaxScaleOnAxis(), closeTo(2.5, 0.01));
    await binding.takeScreenshot('08_zoomed');

    await tester.tap(find.byIcon(Icons.close));
    await settle(tester, const Duration(seconds: 1));
    expect(find.byType(Dialog), findsNothing);
  });
}
