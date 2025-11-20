import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

/// A widget that displays an image from various sources (local file, network, SVG, etc.)
/// with customizable properties, premium skeleton loading effect, and optional zoom.
class AnyImageView extends StatelessWidget {
  /// The path or source of the image. Can be a local file, network URL, or other formats.
  final Object? imagePath;

  /// The height of the image.
  final double? height;

  /// The width of the image.
  final double? width;

  /// How the image should be inscribed into the box.
  final BoxFit? fit;

  /// Alignment of the image within its container.
  final Alignment? alignment;

  /// Callback triggered when the image is tapped.
  final VoidCallback? onTap;

  /// Margin around the image container.
  final EdgeInsetsGeometry? margin;

  /// Padding inside the image container.
  final EdgeInsetsGeometry? padding;

  /// Border radius of the image container.
  final BorderRadius? borderRadius;

  /// Border of the image container.
  final BoxBorder? border;

  /// Shadow effects applied to the image container.
  final List<BoxShadow>? boxShadow;

  /// Shape of the image container (e.g., rectangle or circle).
  final BoxShape shape;

  /// Path to the placeholder image displayed on error.
  final String errorPlaceHolder;

  /// Custom widget displayed as a placeholder while loading.
  final Widget? placeholderWidget;

  /// Custom widget displayed when an error occurs.
  final Widget? errorWidget;

  /// Duration of the fade-in animation for the image.
  final Duration fadeDuration;

  /// Whether zoom functionality is enabled for the image.
  final bool enableZoom;

  /// Custom HTTP headers for network images.
  final Map<String, String>? httpHeaders;

  /// Maximum cache duration for network images.
  final Duration? cacheMaxAge;

  /// Maximum number of retry attempts for failed network requests.
  final int maxRetryAttempts;

  /// Whether to use memory cache for network images.
  final bool useMemoryCache;

  /// Memory cache width for network images (optional, helps with memory optimization).
  final int? memCacheWidth;

  /// Memory cache height for network images (optional, helps with memory optimization).
  final int? memCacheHeight;

  /// Creates an image view widget with various customization options.
  const AnyImageView({
    Key? key,
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
    String? errorPlaceHolder,
    this.placeholderWidget,
    this.errorWidget,
    this.fadeDuration = const Duration(milliseconds: 400),
    this.enableZoom = false,
    this.httpHeaders,
    this.cacheMaxAge,
    this.maxRetryAttempts = 3,
    this.useMemoryCache = true,
    this.memCacheWidth,
    this.memCacheHeight,
  })  : errorPlaceHolder = errorPlaceHolder ?? 'assets/images/not_found.png',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Builds the image content with optional zoom functionality.
    Widget imageContent = AnimatedSwitcher(
      duration: fadeDuration,
      child: _buildImage(),
    );

    // Wraps the image content with InteractiveViewer if zoom is enabled.
    if (enableZoom) {
      imageContent = InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: imageContent,
      );
    }

    // Returns the image wrapped in a container with customizable properties.
    return InkWell(
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        alignment: alignment,
        margin: margin,
        padding: padding,
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: border,
          boxShadow: boxShadow,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        ),
        child: ClipRRect(
          borderRadius: shape == BoxShape.rectangle
              ? (borderRadius ?? BorderRadius.zero)
              : BorderRadius.zero,
          child: imageContent,
        ),
      ),
    );
  }

  /// Builds the image widget based on the provided `imagePath`.
  Widget _buildImage() {
    // Fallback widget displayed when an error occurs or the image path is invalid.
    Widget errorFallback() =>
        errorWidget ??
        Image.asset(
          errorPlaceHolder,
          package: 'any_image_view',
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
        );

    // Returns the fallback widget if the image path is null.
    if (imagePath == null) {
      return errorFallback();
    }

    // Handles image loading for XFile type.
    if (imagePath is XFile) {
      final xFile = imagePath as XFile;
      final path = xFile.path;
      if (path.isEmpty) {
        return errorFallback();
      }
      return _buildFileImage(path, errorFallback);
    }
    // Handles image loading for String type.
    else if (imagePath is String) {
      final path = imagePath as String;
      if (path.isEmpty) {
        return errorFallback();
      }
      return _buildStringImage(path, errorFallback);
    }

    // Returns the fallback widget for unsupported image types.
    return errorFallback();
  }

  /// Builds an image widget for a local file path.
  Widget _buildFileImage(String path, Widget Function() errorFallback) {
    final file = File(path);
    if (!file.existsSync()) {
      return errorFallback();
    }

    // Uses FutureBuilder to check file existence and display the image.
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return errorFallback();
        }

        // Displays the image with fade-in animation.
        return Image.file(
          file,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => errorFallback(),
        );
      },
    );
  }

  /// Builds an image widget for a string path, determining the type of image.
  Widget _buildStringImage(String path, Widget Function() errorFallback) {
    switch (path.imageType) {
      case ImageType.svg:
        // Handles SVG image loading.
        if (path.startsWith('http') || path.startsWith('https')) {
          return SvgPicture.network(
            path,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            placeholderBuilder: (_) => _buildLoadingWidget(),
          );
        }
        return SvgPicture.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          placeholderBuilder: (_) => _buildLoadingWidget(),
        );
      case ImageType.json:
      case ImageType.zip:
        // Handles Lottie animation loading.
        if (path.startsWith('http') || path.startsWith('https')) {
          return Lottie.network(
            path,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
          );
        }
        return Lottie.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
        );
      case ImageType.network:
        // Handles network image loading with advanced caching and retry logic.
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: path,
          placeholder: (_, __) => _buildLoadingWidget(),
          errorWidget: (_, __, ___) => errorFallback(),
          fadeInDuration: fadeDuration,
          fadeOutDuration: const Duration(milliseconds: 300),
          httpHeaders: httpHeaders,
          cacheKey: path,
          maxHeightDiskCache: memCacheHeight,
          maxWidthDiskCache: memCacheWidth,
          memCacheHeight: memCacheHeight,
          memCacheWidth: memCacheWidth,
          useOldImageOnUrlChange: false,
          filterQuality: FilterQuality.medium,
          errorListener: (error) {
            // Log error for debugging (can be extended with custom error handling)
            debugPrint('CachedNetworkImage Error: $error');
          },
        );
      case ImageType.file:
        // Handles local file image loading.
        return _buildFileImage(path, errorFallback);
      default:
        // Handles asset image loading with fade-in animation.
        return Image.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => errorFallback(),
        );
    }
  }

  /// Builds a loading widget, typically a shimmer effect.
  Widget _buildLoadingWidget() {
    return placeholderWidget ??
        Center(
          child: Shimmer(
            height: height,
            width: width,
            borderRadius: borderRadius,
          ),
        );
  }
}

// Update the enum
enum ImageType {
  svg,
  png,
  jpg,
  jpeg,
  tiff,
  raw,
  webp,
  gif,
  heic,
  heif,
  bmp,
  ico,
  exr,
  hdr,
  network,
  json,
  zip,
  file,
}

// Update the extension
extension ImageTypeExtension on String {
  ImageType get imageType {
    // Check for specific file extensions first (works for both local and network paths)
    if (endsWith('.svg')) return ImageType.svg;
    if (endsWith('.json')) return ImageType.json;
    if (endsWith('.zip')) return ImageType.zip;
    if (endsWith('.webp')) return ImageType.webp;
    if (endsWith('.gif')) return ImageType.gif;
    if (endsWith('.jpg') || endsWith('.jpeg')) return ImageType.jpeg;
    if (endsWith('.tiff')) return ImageType.tiff;
    if (endsWith('.raw')) return ImageType.raw;
    if (endsWith('.heic')) return ImageType.heic;
    if (endsWith('.heif')) return ImageType.heif;
    if (endsWith('.bmp')) return ImageType.bmp;
    if (endsWith('.ico')) return ImageType.ico;
    if (endsWith('.exr')) return ImageType.exr;
    if (endsWith('.hdr')) return ImageType.hdr;
    // Check for network URLs after checking extensions
    if (startsWith('http') || startsWith('https')) return ImageType.network;
    // Check for file paths
    if (startsWith('file://') || startsWith('/')) return ImageType.file;
    // Default to PNG for asset paths
    return ImageType.png;
  }
}

/// A widget that creates a shimmer effect, often used as a loading placeholder.
class Shimmer extends StatefulWidget {
  /// The height of the shimmer effect.
  final double? height;

  /// The width of the shimmer effect.
  final double? width;

  /// The border radius of the shimmer effect.
  final BorderRadius? borderRadius;

  /// Creates a shimmer effect widget.
  const Shimmer({
    Key? key,
    this.height,
    this.width,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  /// Animation controller for the shimmer effect.
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initializes the animation controller and starts the animation loop.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    // Disposes the animation controller to free resources.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Builds the shimmer effect using an animated gradient.
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                (_controller.value - 0.2).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.2).clamp(0.0, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(rect);
          },
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: widget.borderRadius ?? BorderRadius.zero,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.15 * 255).toInt()),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          blendMode: BlendMode.srcATop,
        );
      },
    );
  }
}
