import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

/// A widget that displays an image from various sources (local file, network, SVG, etc.)
/// with customizable properties such as size, alignment, and error handling.
class AnyImageView extends StatelessWidget {
  /// The source of the image. Can be a [String] (path or URL) or [XFile].
  final Object? imagePath;

  /// The height of the image container.
  final double? height;

  /// The width of the image container.
  final double? width;

  /// Defines how the image should be inscribed into the container.
  final BoxFit? fit;

  /// Aligns the image within the container.
  final Alignment? alignment;

  /// Callback triggered when the image is tapped.
  final VoidCallback? onTap;

  /// Margin around the image container.
  final EdgeInsetsGeometry? margin;

  /// Padding inside the image container.
  final EdgeInsetsGeometry? padding;

  /// Border radius for the image container.
  final BorderRadius? borderRadius;

  /// Border for the image container.
  final BoxBorder? border;

  /// Shadow effects for the image container.
  final List<BoxShadow>? boxShadow;

  /// Shape of the image container (e.g., rectangle or circle).
  final BoxShape shape;

  /// Path to the placeholder image displayed on error.
  final String errorPlaceHolder;

  /// Widget displayed while the image is loading.
  final Widget? placeholderWidget;

  /// Widget displayed when an error occurs while loading the image.
  final Widget? errorWidget;

  /// Duration for fade-in animation when switching images.
  final Duration fadeDuration;

  /// Constructor for [AnyImageView].
  ///
  /// [imagePath] specifies the image source.
  /// [height] and [width] define the dimensions of the image container.
  /// [fit] determines how the image is inscribed into the container.
  /// [alignment] aligns the image within the container.
  /// [onTap] is a callback triggered when the image is tapped.
  /// [margin] and [padding] define spacing around and inside the container.
  /// [borderRadius], [border], and [boxShadow] customize the container's appearance.
  /// [shape] specifies the container's shape.
  /// [errorPlaceHolder] is the path to the placeholder image displayed on error.
  /// [placeholderWidget] and [errorWidget] are widgets displayed during loading or error states.
  /// [fadeDuration] sets the duration for fade-in animations.
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
    String? errorPlaceHolder,
    this.placeholderWidget,
    this.errorWidget,
    this.fadeDuration = const Duration(milliseconds: 400),
  }) : errorPlaceHolder = errorPlaceHolder ?? 'assets/images/not_found.png';

  @override
  Widget build(BuildContext context) {
    // Builds the main widget structure, including the container and image.
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
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: AnimatedSwitcher(
            duration: fadeDuration,
            child: _buildImage(),
          ),
        ),
      ),
    );
  }

  /// Builds the appropriate image widget based on the [imagePath] type.
  Widget _buildImage() {
    // Fallback widget displayed on error.
    Widget errorFallback() =>
        errorWidget ??
        Image.asset(
          errorPlaceHolder,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a simple error widget if asset loading fails.
            return Container(
              height: height,
              width: width,
              color: Colors.grey[300],
              child: Icon(
                Icons.error_outline,
                color: Colors.grey[600],
                size: (height ?? 100) * 0.3,
              ),
            );
          },
        );

    // Handles null imagePath.
    if (imagePath == null) {
      return errorFallback();
    }

    // Handles XFile type imagePath.
    if (imagePath is XFile) {
      final xFile = imagePath as XFile;
      final path = xFile.path;
      if (path?.isEmpty ?? true) {
        return errorFallback();
      }
      return _buildFileImage(path!, errorFallback);
    } else if (imagePath is String) {
      // Handles String type imagePath.
      final path = imagePath as String;
      if (path.isEmpty) {
        return errorFallback();
      }
      return _buildStringImage(path, errorFallback);
    }

    return errorFallback();
  }

  /// Builds an image widget for a local file.
  ///
  /// [path] is the file path.
  /// [errorFallback] is the widget displayed on error.
  Widget _buildFileImage(String path, Widget Function() errorFallback) {
    // Validate file existence.
    final file = File(path);
    if (!file.existsSync()) {
      return errorFallback();
    }

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return errorFallback();
        }

        return FadeInImage(
          placeholder: AssetImage(errorPlaceHolder),
          image: FileImage(file),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) => errorFallback(),
          placeholderErrorBuilder: (context, error, stackTrace) =>
              errorFallback(),
        );
      },
    );
  }

  /// Builds an image widget for a string path (e.g., network URL, SVG, etc.).
  ///
  /// [path] is the image path or URL.
  /// [errorFallback] is the widget displayed on error.
  Widget _buildStringImage(String path, Widget Function() errorFallback) {
    switch (path.imageType) {
      case ImageType.svg:
        // Handles SVG images.
        return SvgPicture.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          placeholderBuilder: (_) => _buildLoadingWidget(),
        );
      case ImageType.json:
      case ImageType.zip:
        // Handles Lottie animations.
        return Lottie.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
        );
      case ImageType.network:
        // Handles network images.
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: path,
          placeholder: (_, __) => _buildLoadingWidget(),
          errorWidget: (_, __, ___) => errorFallback(),
          fadeInDuration: fadeDuration,
          memCacheWidth: (width ?? 300).toInt(),
          memCacheHeight: (height ?? 300).toInt(),
        );
      case ImageType.file:
        // Handles local file images.
        return _buildFileImage(path, errorFallback);
      default:
        // Handles other image types.
        return FadeInImage(
          placeholder: AssetImage(errorPlaceHolder),
          image: AssetImage(path),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) => errorFallback(),
          placeholderErrorBuilder: (context, error, stackTrace) =>
              errorFallback(),
        );
    }
  }

  /// Builds a consistent loading widget.
  Widget _buildLoadingWidget() {
    return placeholderWidget ??
        Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: Center(
            child: SizedBox(
              height: (height ?? 100) * 0.2,
              width: (width ?? 100) * 0.2,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
              ),
            ),
          ),
        );
  }
}

/// Extension on [String] to determine the type of image based on its path or URL.
extension ImageTypeExtension on String {
  /// Returns the [ImageType] based on the file extension or URL prefix.
  ImageType get imageType {
    if (startsWith('http') || startsWith('https')) return ImageType.network;
    if (endsWith('.svg')) return ImageType.svg;
    if (endsWith('.json')) return ImageType.json;
    if (endsWith('.zip')) return ImageType.zip;
    if (endsWith('.webp')) return ImageType.webp;
    if (endsWith('.gif')) return ImageType.gif;
    if (endsWith('.jpg')) return ImageType.jpg;
    if (endsWith('.jpeg')) return ImageType.jpeg;
    if (endsWith('.tiff')) return ImageType.tiff;
    if (endsWith('.raw')) return ImageType.raw;
    if (startsWith('file://') || startsWith('/')) return ImageType.file;
    return ImageType.png;
  }
}

/// Enum representing different types of images.
enum ImageType {
  svg,
  png,
  jpg,
  jpeg,
  tiff,
  raw,
  webp,
  gif,
  network,
  json,
  zip,
  file,
}
