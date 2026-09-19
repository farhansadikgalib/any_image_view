import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'file_image.dart';
import 'image_type.dart';
import 'lottie/lottie_composition.dart';
import 'lottie/lottie_widget.dart';
import 'net/disk_cache.dart';
import 'net/fetch.dart';
import 'net/network_image_provider.dart';
import 'shimmer.dart';
import 'svg/svg_widget.dart';

/// A widget that displays an image from various sources (local file, network,
/// SVG, Lottie, etc.) with customizable styling, a shimmer loading effect and
/// optional zoom / fullscreen viewing.
class AnyImageView extends StatelessWidget {
  /// Creates an image view widget with various customization options.
  const AnyImageView({
    super.key,
    this.imagePath,
    this.height,
    this.width,
    this.fit,
    this.alignment,
    this.onTap,
    this.margin,
    this.padding,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.shape = BoxShape.rectangle,
    this.placeholderWidget,
    this.errorWidget,
    this.fadeDuration = const Duration(milliseconds: 400),
    this.enableZoom = false,
    this.httpHeaders,
    this.maxRetryAttempts = 3,
    this.svgColor,
    this.svgColorFilter,
    this.enableFullscreen = false,
  });

  /// The image source: a network URL, asset path, local file path, `file://`
  /// URI, or any object exposing a `String path` (such as `XFile` or `File`).
  final Object? imagePath;

  /// The height of the image.
  final double? height;

  /// The width of the image.
  final double? width;

  /// How the image should be inscribed into the box.
  ///
  /// Defaults to [BoxFit.cover] for raster images and [BoxFit.contain] for
  /// SVG and Lottie content.
  final BoxFit? fit;

  /// Alignment of the image within its container.
  final Alignment? alignment;

  /// Callback triggered when the image is tapped.
  final VoidCallback? onTap;

  /// Margin around the image container.
  final EdgeInsetsGeometry? margin;

  /// Padding inside the image container.
  final EdgeInsetsGeometry? padding;

  /// Border radius of the image container (rectangle shape only).
  final BorderRadius? borderRadius;

  /// Border of the image container.
  final BoxBorder? border;

  /// Shadow effects applied to the image container.
  final List<BoxShadow>? boxShadow;

  /// Shape of the image container (e.g., rectangle or circle).
  final BoxShape shape;

  /// Custom widget displayed as a placeholder while loading.
  final Widget? placeholderWidget;

  /// Custom widget displayed when an error occurs.
  final Widget? errorWidget;

  /// Duration of the fade-in animation for the image.
  final Duration fadeDuration;

  /// Whether pinch-to-zoom is enabled for the image.
  final bool enableZoom;

  /// Custom HTTP headers for network images and network SVGs.
  final Map<String, String>? httpHeaders;

  /// Maximum number of additional attempts made when a network image or
  /// network SVG fails to load. Attempts are spaced out with a short,
  /// increasing delay. Set to `0` to disable retries.
  final int maxRetryAttempts;

  /// Optional color to tint SVG images (both asset and network).
  /// When set, SVG fill/stroke is replaced with this color (BlendMode.srcIn).
  final Color? svgColor;

  /// Optional custom color filter for SVG images (overrides [svgColor] if both set).
  final ColorFilter? svgColorFilter;

  /// When true, tapping the image opens a fullscreen dialog with a close
  /// button (top-right) and pinch-to-zoom. Ignored if [onTap] is provided.
  final bool enableFullscreen;

  static const Color _fallbackBackground = Color(0xFFEEEEEE);
  static const Color _fallbackIconColor = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    Widget imageContent = AnimatedSwitcher(
      duration: fadeDuration,
      child: _buildImage(),
    );

    if (enableZoom) {
      imageContent = InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: imageContent,
      );
    }

    final bool isRectangle = shape == BoxShape.rectangle;
    final BorderRadius? radius = isRectangle ? borderRadius : null;

    // Only pay for a clip layer when there is actually something to clip.
    if (!isRectangle) {
      imageContent = ClipOval(child: imageContent);
    } else if (radius != null && radius != BorderRadius.zero) {
      imageContent = ClipRRect(borderRadius: radius, child: imageContent);
    }

    final Widget content = Container(
      alignment: alignment,
      margin: margin,
      padding: padding,
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: border,
        boxShadow: boxShadow,
        shape: shape,
        borderRadius: radius,
      ),
      child: imageContent,
    );

    // If the user did not supply their own onTap and enableFullscreen is on,
    // tapping opens the fullscreen dialog. An explicit onTap always wins.
    final VoidCallback? effectiveOnTap =
        onTap ?? (enableFullscreen ? () => _openFullscreen(context) : null);
    if (effectiveOnTap == null) return content;

    // A plain GestureDetector (rather than InkWell) keeps the widget usable
    // outside a Material ancestor and skips the ink/splash machinery entirely.
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: effectiveOnTap,
        child: content,
      ),
    );
  }

  /// Opens a fullscreen dialog with a zoomable view of [imagePath] and a
  /// close button anchored at the top-right corner.
  void _openFullscreen(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      useSafeArea: false,
      builder: (_) => _FullscreenImageDialog(
        imagePath: imagePath,
        httpHeaders: httpHeaders,
        placeholderWidget: placeholderWidget,
        errorWidget: errorWidget,
        svgColor: svgColor,
        svgColorFilter: svgColorFilter,
        fadeDuration: fadeDuration,
        maxRetryAttempts: maxRetryAttempts,
      ),
    );
  }

  /// Effective color filter for SVG: [svgColorFilter] if set, else from [svgColor].
  ColorFilter? get _effectiveSvgColorFilter {
    if (svgColorFilter != null) return svgColorFilter;
    final Color? color = svgColor;
    return color == null ? null : ColorFilter.mode(color, BlendMode.srcIn);
  }

  /// True if the path is a network URL pointing to an SVG file.
  ///
  /// Ignores query strings and fragments, so `icon.svg?v=2` still matches.
  static bool _isSvgUrl(String path) =>
      isHttpUrl(path) && extensionOf(path) == 'svg';

  /// Fallback widget displayed when an error occurs or the source is invalid.
  Widget _errorFallback() =>
      errorWidget ??
      Container(
        height: height,
        width: width,
        padding: const EdgeInsets.all(20),
        color: _fallbackBackground,
        child: const FittedBox(
          fit: BoxFit.contain,
          child: Icon(Icons.broken_image, color: _fallbackIconColor),
        ),
      );

  /// Extracts a path from [source]: the string itself, or the `path` getter
  /// of objects such as `XFile` and `File` (resolved dynamically so the
  /// package needs no dependency on them).
  static String? _pathOf(Object source) {
    if (source is String) return source;
    try {
      final Object? path = (source as dynamic).path;
      return path is String ? path : null;
    } on NoSuchMethodError {
      return null;
    }
  }

  /// Builds the image widget based on the provided [imagePath].
  Widget _buildImage() {
    final Object? source = imagePath;
    if (source == null) return _errorFallback();
    final String? path = _pathOf(source);
    if (path == null || path.isEmpty) return _errorFallback();
    // Non-string sources (XFile, File) always refer to a local file.
    return source is String ? _buildStringImage(path) : _buildFileImage(path);
  }

  /// Builds an image widget for a local file path (or `file://` URI).
  Widget _buildFileImage(String path) => buildFileImage(
    path,
    height: height,
    width: width,
    fit: fit ?? BoxFit.cover,
    headers: httpHeaders,
    errorBuilder: _errorFallback,
  );

  /// Builds an image widget for a string path, dispatching on its [ImageType].
  Widget _buildStringImage(String path) {
    switch (path.imageType) {
      case ImageType.svg:
        return _buildSvg(path, isNetwork: false);
      case ImageType.json:
      case ImageType.zip:
        return _LottieLoader(
          path: path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          loadingWidget: _buildLoadingWidget(),
          errorFallback: _errorFallback,
        );
      case ImageType.network:
        if (_isSvgUrl(path)) return _buildSvg(path, isNetwork: true);
        return _buildNetworkImage(path);
      case ImageType.file:
        return _buildFileImage(path);
      default:
        // Every remaining raster format is decoded by the framework.
        return Image.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (_, _, _) => _errorFallback(),
        );
    }
  }

  Widget _buildSvg(String path, {required bool isNetwork}) {
    return _SafeSvgLoader(
      path: path,
      isNetwork: isNetwork,
      httpHeaders: httpHeaders,
      maxRetryAttempts: maxRetryAttempts,
      height: height,
      width: width,
      fit: fit ?? BoxFit.contain,
      colorFilter: _effectiveSvgColorFilter,
      loadingWidget: _buildLoadingWidget(),
      errorFallback: _errorFallback,
    );
  }

  Widget _buildNetworkImage(String url) {
    return _RetryLoader(
      maxAttempts: maxRetryAttempts,
      loadingWidget: _buildLoadingWidget(),
      errorFallback: _errorFallback,
      builder: (Key key, Widget Function() onError) => Image(
        key: key,
        // The browser already caches on the web and NetworkImage can fall back
        // to an <img> element for cross-origin images.
        image: kIsWeb
            ? NetworkImage(url, headers: httpHeaders)
            : AnyNetworkImage(url, headers: httpHeaders),
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        frameBuilder: _frameBuilder,
        errorBuilder: (_, Object error, _) {
          if (kDebugMode) {
            debugPrint('AnyImageView: network image failed: $error');
          }
          return onError();
        },
      ),
    );
  }

  /// Shows the placeholder until the first frame, then fades the image in.
  Widget _frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    if (frame == null) return _buildLoadingWidget();
    return _FadeIn(duration: fadeDuration, child: child);
  }

  /// Builds the loading placeholder, a shimmer effect by default.
  Widget _buildLoadingWidget() {
    return placeholderWidget ??
        Shimmer(height: height, width: width, borderRadius: borderRadius);
  }
}

/// Fades its child in once, on first build.
class _FadeIn extends StatefulWidget {
  const _FadeIn({required this.duration, required this.child});

  final Duration duration;
  final Widget child;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _controller, child: widget.child);
}

/// Rebuilds its child with a fresh [Key] when a load fails, up to
/// [maxAttempts] extra times, showing [loadingWidget] in between and
/// [errorFallback] once the attempts are exhausted.
class _RetryLoader extends StatefulWidget {
  const _RetryLoader({
    required this.maxAttempts,
    required this.loadingWidget,
    required this.errorFallback,
    required this.builder,
  });

  final int maxAttempts;
  final Widget loadingWidget;
  final Widget Function() errorFallback;

  /// Builds one attempt. [key] changes per attempt so the image is reloaded;
  /// [onError] must be used as the attempt's error widget.
  final Widget Function(Key key, Widget Function() onError) builder;

  @override
  State<_RetryLoader> createState() => _RetryLoaderState();
}

class _RetryLoaderState extends State<_RetryLoader> {
  int _attempt = 0;
  Timer? _retryTimer;

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Widget _onError() {
    if (_attempt >= widget.maxAttempts) return widget.errorFallback();
    // Called during build: schedule the retry instead of rebuilding inline.
    _retryTimer ??= Timer(retryDelay(_attempt), () {
      _retryTimer = null;
      if (mounted) setState(() => _attempt++);
    });
    return widget.loadingWidget;
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(ValueKey<int>(_attempt), _onError);
}

/// Delay before retry number [attempt] (0-based): 300ms, 600ms, 900ms, ...
Duration retryDelay(int attempt) => Duration(milliseconds: 300 * (attempt + 1));

/// Fullscreen dialog used by [AnyImageView.enableFullscreen]. Renders the image
/// inside an [InteractiveViewer] for pinch-to-zoom (and pan) on a black backdrop,
/// with a close button anchored at the top-right corner (respecting safe area).
///
/// The viewer is placed above all clipping so that pinch-zoomed and panned
/// pixels are not cropped. Double-tap toggles between fit and a 2.5x zoom
/// centered on the tap point.
class _FullscreenImageDialog extends StatefulWidget {
  const _FullscreenImageDialog({
    required this.imagePath,
    required this.httpHeaders,
    required this.placeholderWidget,
    required this.errorWidget,
    required this.svgColor,
    required this.svgColorFilter,
    required this.fadeDuration,
    required this.maxRetryAttempts,
  });

  final Object? imagePath;
  final Map<String, String>? httpHeaders;
  final Widget? placeholderWidget;
  final Widget? errorWidget;
  final Color? svgColor;
  final ColorFilter? svgColorFilter;
  final Duration fadeDuration;
  final int maxRetryAttempts;

  @override
  State<_FullscreenImageDialog> createState() => _FullscreenImageDialogState();
}

class _FullscreenImageDialogState extends State<_FullscreenImageDialog> {
  final TransformationController _transformController =
      TransformationController();
  Offset? _doubleTapPosition;

  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;
  static const double _doubleTapScale = 2.5;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_transformController.value != Matrix4.identity()) {
      _transformController.value = Matrix4.identity();
      return;
    }
    final Offset? position = _doubleTapPosition;
    if (position == null) return;
    const double s = _doubleTapScale;
    // Scale about the tap point: translate so that point stays fixed.
    _transformController.value = Matrix4.diagonal3Values(s, s, 1)
      ..setTranslationRaw(-position.dx * (s - 1), -position.dy * (s - 1), 0);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: (TapDownDetails details) =>
                  _doubleTapPosition = details.localPosition,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: _minScale,
                maxScale: _maxScale,
                clipBehavior: Clip.none,
                child: AnyImageView(
                  imagePath: widget.imagePath,
                  fit: BoxFit.contain,
                  httpHeaders: widget.httpHeaders,
                  placeholderWidget: widget.placeholderWidget,
                  errorWidget: widget.errorWidget,
                  svgColor: widget.svgColor,
                  svgColorFilter: widget.svgColorFilter,
                  fadeDuration: widget.fadeDuration,
                  maxRetryAttempts: widget.maxRetryAttempts,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loads an SVG (asset or network) as a string, then renders it with
/// [AnySvg]; any load or parse failure shows the error fallback instead of
/// throwing.
class _SafeSvgLoader extends StatefulWidget {
  const _SafeSvgLoader({
    required this.path,
    required this.isNetwork,
    required this.httpHeaders,
    required this.maxRetryAttempts,
    required this.height,
    required this.width,
    required this.fit,
    required this.colorFilter,
    required this.loadingWidget,
    required this.errorFallback,
  });

  final String path;
  final bool isNetwork;
  final Map<String, String>? httpHeaders;
  final int maxRetryAttempts;
  final double? height;
  final double? width;
  final BoxFit fit;
  final ColorFilter? colorFilter;
  final Widget loadingWidget;
  final Widget Function() errorFallback;

  @override
  State<_SafeSvgLoader> createState() => _SafeSvgLoaderState();
}

class _SafeSvgLoaderState extends State<_SafeSvgLoader> {
  late Future<String?> _future = _load();

  @override
  void didUpdateWidget(_SafeSvgLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when the source changes; otherwise the first SVG would stick.
    if (oldWidget.path != widget.path ||
        oldWidget.isNetwork != widget.isNetwork ||
        !mapEquals(oldWidget.httpHeaders, widget.httpHeaders)) {
      _future = _load();
    }
  }

  Future<String?> _load() => widget.isNetwork
      ? _loadNetworkSvg(
          widget.path,
          widget.httpHeaders,
          widget.maxRetryAttempts,
        )
      : _loadAssetSvg(widget.path);

  static Future<String?> _loadAssetSvg(String path) async {
    try {
      final String svg = await rootBundle.loadString(path);
      return svg.isNotEmpty ? svg : null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _loadNetworkSvg(
    String url,
    Map<String, String>? headers,
    int maxRetryAttempts,
  ) async {
    // Network SVGs share the image disk cache, so a repeat visit is free.
    final String cacheKey = AnyImageCache.cacheKey(url);
    final Uint8List? cached = await readCached(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return utf8.decode(cached, allowMalformed: true);
    }
    final Uri uri = Uri.parse(url);
    for (int attempt = 0; ; attempt++) {
      final Uint8List? body = await fetchBytes(uri, headers: headers);
      if (body != null && body.isNotEmpty) {
        // Best-effort; the SVG renders whether or not the write succeeds.
        unawaited(writeCached(cacheKey, body));
        return utf8.decode(body, allowMalformed: true);
      }
      if (attempt >= maxRetryAttempts) return null;
      await Future<void>.delayed(retryDelay(attempt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.loadingWidget;
        }
        final String? svg = snapshot.data;
        if (svg == null) return widget.errorFallback();
        return AnySvg.string(
          svg,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          colorFilter: widget.colorFilter,
          errorBuilder: (_, _) => widget.errorFallback(),
        );
      },
    );
  }
}

/// Loads a Lottie asset (`.json`, `.zip` or `.lottie`) and plays it with
/// [AnyLottie]; failures show the error fallback.
class _LottieLoader extends StatefulWidget {
  const _LottieLoader({
    required this.path,
    required this.height,
    required this.width,
    required this.fit,
    required this.loadingWidget,
    required this.errorFallback,
  });

  final String path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget loadingWidget;
  final Widget Function() errorFallback;

  @override
  State<_LottieLoader> createState() => _LottieLoaderState();
}

class _LottieLoaderState extends State<_LottieLoader> {
  late Future<LottieComposition?> _future = _load();
  LottieComposition? _composition;

  @override
  void didUpdateWidget(_LottieLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _composition?.dispose();
      _composition = null;
      _future = _load();
    }
  }

  Future<LottieComposition?> _load() async {
    try {
      final ByteData data = await rootBundle.load(widget.path);
      final Uint8List bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final LottieComposition composition = await LottieComposition.fromBytes(
        bytes,
      );
      if (!mounted) {
        composition.dispose();
        return null;
      }
      _composition = composition;
      return composition;
    } catch (e) {
      if (kDebugMode) debugPrint('AnyImageView: Lottie load failed: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _composition?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LottieComposition?>(
      future: _future,
      builder:
          (BuildContext context, AsyncSnapshot<LottieComposition?> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return widget.loadingWidget;
            }
            final LottieComposition? composition = snapshot.data;
            if (composition == null) return widget.errorFallback();
            return AnyLottie(
              composition: composition,
              height: widget.height,
              width: widget.width,
              fit: widget.fit,
            );
          },
    );
  }
}
