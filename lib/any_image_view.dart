import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class Shimmer extends StatefulWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(rect);
          },
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: (0.15 * 255).toDouble()),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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

/// A widget that displays an image from various sources (local file, network, SVG, etc.)
/// with customizable properties, premium skeleton loading effect, and optional zoom.
class AnyImageView extends StatelessWidget {
  final Object? imagePath;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final BoxShape shape;
  final String errorPlaceHolder;
  final Widget? placeholderWidget;
  final Widget? errorWidget;
  final Duration fadeDuration;
  final bool enableZoom;

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
  })  : errorPlaceHolder = errorPlaceHolder ?? 'assets/images/not_found.png',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageContent = ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: AnimatedSwitcher(
        duration: fadeDuration,
        child: _buildImage(),
      ),
    );

    if (enableZoom) {
      imageContent = InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: imageContent,
      );
    }

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
        child: imageContent,
      ),
    );
  }

  Widget _buildImage() {
    Widget errorFallback() =>
        errorWidget ??
        Image.asset(
          errorPlaceHolder,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
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

    if (imagePath == null) {
      return errorFallback();
    }

    if (imagePath is XFile) {
      final xFile = imagePath as XFile;
      final path = xFile.path;
      if (path.isEmpty) {
        return errorFallback();
      }
      return _buildFileImage(path, errorFallback);
    } else if (imagePath is String) {
      final path = imagePath as String;
      if (path.isEmpty) {
        return errorFallback();
      }
      return _buildStringImage(path, errorFallback);
    }

    return errorFallback();
  }

  Widget _buildFileImage(String path, Widget Function() errorFallback) {
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

  Widget _buildStringImage(String path, Widget Function() errorFallback) {
    switch (path.imageType) {
      case ImageType.svg:
        return SvgPicture.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          placeholderBuilder: (_) => _buildLoadingWidget(),
        );
      case ImageType.json:
      case ImageType.zip:
        return Lottie.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
        );
      case ImageType.network:
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: path,
          placeholder: (_, __) => _buildLoadingWidget(),
          errorWidget: (_, __, ___) => errorFallback(),
          fadeInDuration: fadeDuration,
          memCacheWidth: (width != null && width!.isFinite && !width!.isNaN)
              ? width!.toInt()
              : null,
          memCacheHeight: (height != null && height!.isFinite && !height!.isNaN)
              ? height!.toInt()
              : null,
        );
      case ImageType.file:
        return _buildFileImage(path, errorFallback);
      default:
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

/// Extension on [String] to determine the type of image based on its path or URL.
extension ImageTypeExtension on String {
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
