/// A versatile, dependency-free Flutter image viewer.
///
/// This library provides [AnyImageView], a single widget that can display:
/// - Network images (HTTP/HTTPS URLs), cached on disk
/// - Network SVG images (URLs ending with .svg)
/// - Local asset images (PNG, JPG, WebP, GIF, etc.)
/// - AVIF and HEIC through the platform decoder (Android 12+, iOS 16+,
///   macOS 13+, web)
/// - SVG graphics (local assets and network), with optional
///   [AnyImageView.svgColor] / [AnyImageView.svgColorFilter]
/// - Lottie animations (JSON, ZIP / dotLottie)
/// - `XFile` objects (from image_picker), or any object with a `path`
/// - Local file paths and `file://` URIs
///
/// Everything is implemented inside this package on top of the Flutter SDK:
/// no third-party dependencies. The SVG and Lottie renderers cover the common
/// subsets described on [SvgDocument] and [LottieComposition].
///
/// ## Usage
/// ```dart
/// import 'package:any_image_view/any_image_view.dart';
///
/// AnyImageView(
///   imagePath: 'https://example.com/image.jpg',
///   height: 200,
///   width: 200,
///   borderRadius: BorderRadius.circular(12),
/// )
/// ```
library;

export 'src/any_image_view.dart';
export 'src/image_type.dart' show ImageType, ImageTypeExtension;
export 'src/lottie/lottie_composition.dart' show LottieComposition;
export 'src/lottie/lottie_widget.dart';
export 'src/net/disk_cache.dart' show AnyImageCache;
export 'src/net/network_image_provider.dart';
export 'src/shimmer.dart';
export 'src/svg/svg_document.dart' show SvgDocument;
export 'src/svg/svg_widget.dart';
