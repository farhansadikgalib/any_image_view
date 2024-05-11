library any_image_view;

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'generated/assets.dart';

class AnyImageView extends StatelessWidget {
  String? imagePath;
  double? height;
  double? width;
  Color? color;
  BoxFit? boxFit;
  double? cachedNetHeight;
  double? cachedNetWidth;
  final String errorPlaceHolder;
  Alignment? alignment;
  VoidCallback? onTap;
  EdgeInsetsGeometry? margin, padding;
  BorderRadius? borderRadius;
  BoxBorder? border;
  List<BoxShadow>? boxShadow;
  BoxShape shape;

  ///a [AnyImageView] it can be used for showing any type of images
  /// it will shows the placeholder image if image is not found on network image
  AnyImageView({
    super.key,
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.boxFit,
    this.alignment,
    this.onTap,
    this.borderRadius,
    this.margin,
    this.border,
    this.cachedNetHeight,
    this.cachedNetWidth,
    this.errorPlaceHolder = Assets.imagesNoImageFound,
    this.boxShadow,
    this.shape = BoxShape.rectangle,
  });

  @override
  /* Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment!,
            child: _buildWidget(),
          )
        : _buildWidget();
  }*/
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: alignment,
        padding: padding,
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: border,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
          shape: shape,
        ),
        child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: imageTypeView()),
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
            color: color,
          );
        case ImageType.json:
          return Lottie.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.contain,
          );
        case ImageType.file:
          return Image.file(
            File(imagePath!),
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.cover,
            color: color,
          );
        case ImageType.network:
          return CachedNetworkImage(
            height: height,
            width: width,
            fit: boxFit,
            imageUrl: imagePath!,
            color: color,
            placeholder: (context, url) => SizedBox(
              height: cachedNetHeight ?? 30,
              width: cachedNetWidth ?? 30,
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
          );
        case ImageType.png:
        default:
          return Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: boxFit ?? BoxFit.cover,
            color: color,
          );
      }
    }
    return const SizedBox();
  }
}

extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('http') || startsWith('https')) {
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (endsWith('.json')) {
      return ImageType.json;
    } else if (startsWith('file://')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, json, file, unknown }
