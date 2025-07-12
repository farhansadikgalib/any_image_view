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
  final String? errorPlaceHolder;

  /// Widget displayed while the image is loading.
  final Widget? placeholderWidget;

  /// Widget displayed when an error occurs while loading the image.
  final Widget? errorWidget;

  /// Duration for fade-in animation when switching images.
  final Duration fadeDuration;

  /// Constructor for [AnyImageView].
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
    this.errorPlaceHolder,
    this.placeholderWidget,
    this.errorWidget,
    this.fadeDuration = const Duration(milliseconds: 400),
  });

  /// Default asset path for the error placeholder image.
  String get _defaultErrorAsset =>
      'packages/any_image_view/assets/images/not_found.png';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
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
    Widget errorFallback() =>
        errorWidget ??
        Image.asset(
          errorPlaceHolder ?? _defaultErrorAsset,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
        );

    if (imagePath is XFile) {
      return _buildFileImage((imagePath as XFile).path, errorFallback);
    } else if (imagePath is String) {
      return _buildStringImage(imagePath as String, errorFallback);
    }
    return const SizedBox();
  }

  /// Builds an image widget for a local file.
  ///
  /// [path] is the file path.
  /// [errorFallback] is the widget displayed on error.
  Widget _buildFileImage(String path, Widget Function() errorFallback) {
    return FadeInImage(
      placeholder: AssetImage(errorPlaceHolder ?? _defaultErrorAsset),
      image: FileImage(File(path)),
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      imageErrorBuilder: (_, __, ___) => errorFallback(),
    );
  }

  /// Builds an image widget for a string path (e.g., network URL, SVG, etc.).
  ///
  /// [path] is the image path or URL.
  /// [errorFallback] is the widget displayed on error.
  Widget _buildStringImage(String path, Widget Function() errorFallback) {
    switch (path.imageType) {
      case ImageType.svg:
        return SvgPicture.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          placeholderBuilder: (_) =>
              placeholderWidget ??
              SizedBox(
                height: height,
                width: width,
                child: LinearProgressIndicator(),
              ),
          errorBuilder: (_, __, ___) => errorFallback(),
        );
      case ImageType.json:
      case ImageType.zip:
        return Lottie.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          errorBuilder: (_, __, ___) => errorFallback(),
        );
      case ImageType.network:
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: path,
          placeholder: (_, __) =>
              placeholderWidget ??
              SizedBox(
                height: height,
                width: width,
                child: LinearProgressIndicator(
                  color: Colors.grey.shade200,
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
          errorWidget: (_, __, ___) => errorFallback(),
          fadeInDuration: fadeDuration,
        );
      default:
        return FadeInImage(
          placeholder: AssetImage(errorPlaceHolder ?? _defaultErrorAsset),
          image: AssetImage(path),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          imageErrorBuilder: (_, __, ___) => errorFallback(),
        );
    }
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
