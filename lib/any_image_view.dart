library any_image_view;

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

// This AnyImageView Class is using for showing any type of images in flutter
class AnyImageView extends StatelessWidget {
  // ignore_for_file: must_be_immutable
  String? imagePath; // Image Path can be any type of image
  double? height; // Height of the Image
  double? width; // Width of the Image
  BoxFit? boxFit; // BoxFit of the Image
  double?
      cachedNetPlaceholderHeight; // Height of the Placeholder for CachedNetworkImage
  double?
      cachedNetPlaceholderWidth; // Width of the Placeholder for CachedNetworkImage
  String errorPlaceHolder; // Error Placeholder for CachedNetworkImage
  Alignment? alignment; // Alignment of the Image
  VoidCallback? onTap; // OnTap of the Image
  EdgeInsetsGeometry? margin, padding; // Margin and Padding of the Image
  BorderRadius? borderRadius; // BorderRadius of the Image
  BoxBorder? border; // Border of the Image
  List<BoxShadow>? boxShadow; // BoxShadow of the Image
  BoxShape shape; // Shape of the Image

  ///a [AnyImageView] it can be used for showing any type of images
  /// it will shows the placeholder image if image is not found on network image
  ///
  ///
  /// Constructs a [AnyImageView] object.
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

  /// Constructs a [AnyImageView] object.

  ///a [AnyImageView] it can be used for showing any type of images
  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent, // to set the focus color
      highlightColor: Colors.transparent, // to set the highlight color
      onTap: onTap, //to set the onTap function
      child: Container(
        alignment: alignment,
        //to set the alignment
        padding: padding,
        //to set the padding
        height: height,
        // to set the height
        width: width,
        // to set the width
        decoration: BoxDecoration(
          border: border,
          boxShadow: boxShadow,
          shape: shape,
        ),
        // to set the decoration
        child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            // to set the borderRadius
            child: imageTypeView()), // to set the imageTypeView
      ),
    );
  }

  Widget imageTypeView() {
    if (imagePath != null) {
      switch (imagePath!.imageType) {
        case ImageType.svg:
          return SvgPicture.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.contain,
          ); // to set the SvgPicture
        case ImageType.json:
          return Lottie.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.contain,
          ); // to set the Lottie.asset
        case ImageType.zip:
          return Lottie.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.contain,
          ); // to set the Lottie.asset
        case ImageType.file:
          return Image.file(
            File(imagePath!),
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.cover,
          ); // to set the Image.file
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
            ),
            errorWidget: (context, url, error) => Image.asset(
              errorPlaceHolder,
              height: height,
              width: width,
              fit: boxFit ?? BoxFit.cover,
              package: 'any_image_view',
            ),
          ); // to set the CachedNetworkImage
        case ImageType.png:
        default:
          return Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.cover,
          ); // to set the Image.asset
      }
    }
    return const SizedBox();
  }
}

///a [AnyImageView] it can be used for showing any type of images

// Image Type Extension defines image type of the image path
extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('http') || startsWith('https')) {
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (endsWith('.json')) {
      return ImageType.json;
    } else if (endsWith('.zip')) {
      return ImageType.zip;
    } else if (startsWith('file://')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}
// Image Type Extension defines image type of the image path

// Image Type Enums
enum ImageType { svg, png, network, json, zip, file, unknown }
// Image Type Enums
