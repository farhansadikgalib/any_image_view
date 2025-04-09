library any_image_view;

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

/// This `AnyImageView` class is used for displaying any type of image in Flutter.
/// It supports various image types such as SVG, JSON (Lottie), ZIP (Lottie),
/// file-based images, network images, and asset images.
/// It also provides customization options for size, alignment, border, shape,
/// and placeholder handling.
class AnyImageView extends StatelessWidget {
  /// The path of the image. It can be a network URL, file path, or asset path.
  String? imagePath;

  /// The height of the image.
  double? height;

  /// The width of the image.
  double? width;

  /// The `BoxFit` property to define how the image should be fitted inside its container.
  BoxFit? boxFit;

  /// The height of the placeholder for `CachedNetworkImage`.
  double? cachedNetPlaceholderHeight;

  /// The width of the placeholder for `CachedNetworkImage`.
  double? cachedNetPlaceholderWidth;

  /// The placeholder image to display when the network image fails to load.
  String errorPlaceHolder;

  /// The alignment of the image within its container.
  Alignment? alignment;

  /// The callback function to handle tap events on the image.
  VoidCallback? onTap;

  /// The margin around the image.
  EdgeInsetsGeometry? margin;

  /// The padding inside the image container.
  EdgeInsetsGeometry? padding;

  /// The border radius of the image container.
  BorderRadius? borderRadius;

  /// The border of the image container.
  BoxBorder? border;

  /// The shadow effects applied to the image container.
  List<BoxShadow>? boxShadow;

  /// The shape of the image container (e.g., rectangle or circle).
  BoxShape shape;

  /// Constructs an `AnyImageView` object with customizable properties.
  AnyImageView({
    super.key,
    this.imagePath,
    this.height,
    this.width,
    this.boxFit,
    this.alignment,
    this.onTap,
    this.borderRadius,
    this.margin,
    this.padding,
    this.border,
    this.cachedNetPlaceholderHeight,
    this.cachedNetPlaceholderWidth,
    this.errorPlaceHolder = 'assets/images/not_found.png',
    this.boxShadow,
    this.shape = BoxShape.rectangle,
  });

  /// Builds the widget tree for the `AnyImageView`.
  /// It wraps the image in an `InkWell` to handle tap events and applies
  /// the specified decorations and properties.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent, // Removes focus color
      highlightColor: Colors.transparent, // Removes highlight color
      onTap: onTap, // Handles tap events
      child: Container(
        alignment: alignment, // Sets alignment
        padding: padding, // Sets padding
        height: height, // Sets height
        width: width, // Sets width
        decoration: BoxDecoration(
          border: border, // Sets border
          boxShadow: boxShadow, // Sets shadow effects
          shape: shape, // Sets shape
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero, // Sets border radius
          child: imageTypeView(), // Displays the appropriate image type
        ),
      ),
    );
  }

  /// Determines the type of image to display based on the `imagePath` extension
  /// and returns the corresponding widget.
  Widget imageTypeView() {
    if (imagePath != null) {
      switch (imagePath!.imageType) {
        case ImageType.svg:
          return SvgPicture.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.contain,
          ); // Displays an SVG image
        case ImageType.json:
          return Lottie.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.contain,
          ); // Displays a Lottie animation (JSON)
        case ImageType.zip:
          return Lottie.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.contain,
          ); // Displays a Lottie animation (ZIP)
        case ImageType.file:
          return Image.file(
            File(imagePath!),
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.cover,
          ); // Displays an image from a file
        case ImageType.network:
          return CachedNetworkImage(
            height: height,
            width: width,
            fit: boxFit,
            imageUrl: imagePath!,
            placeholder: (context, url) => SizedBox(
              height: cachedNetPlaceholderHeight ?? 30,
              width: cachedNetPlaceholderWidth ?? 30,
              child: LinearProgressIndicator(
                color: Colors.grey.shade200,
                backgroundColor: Colors.grey.shade100,
              ),
            ), // Displays a placeholder while loading
            errorWidget: (context, url, error) => Image.asset(
              errorPlaceHolder,
              height: height,
              width: width,
              fit: boxFit ?? BoxFit.cover,
              package: 'any_image_view',
            ), // Displays an error placeholder
          );
        case ImageType.png:
        default:
          return Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.cover,
          ); // Displays an asset image
      }
    }
    return const SizedBox(); // Returns an empty widget if no image path is provided
  }
}

/// Extension on `String` to determine the type of image based on its path or URL.
extension ImageTypeExtension on String {
  /// Returns the `ImageType` based on the file extension or URL prefix.
  ImageType get imageType {
    if (startsWith('http') || startsWith('https')) {
      return ImageType.network; // Network image
    } else if (endsWith('.svg')) {
      return ImageType.svg; // SVG image
    } else if (endsWith('.json')) {
      return ImageType.json; // Lottie JSON animation
    } else if (endsWith('.zip')) {
      return ImageType.zip; // Lottie ZIP animation
    } else if (startsWith('file://')) {
      return ImageType.file; // File-based image
    } else {
      return ImageType.png; // Default to PNG asset image
    }
  }
}

/// Enum to represent different types of images.
enum ImageType { svg, png, network, json, zip, file, unknown }
