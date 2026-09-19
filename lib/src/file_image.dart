/// Builds the widget for a local file source. Native platforms read the file
/// with `dart:io`; the web treats the path as a URL (`XFile` paths from
/// `image_picker` are blob:/data: URLs there).
library;

import 'package:flutter/widgets.dart';

import 'file_image_web.dart' if (dart.library.io) 'file_image_io.dart' as impl;

/// Returns an [Image] for [path], or the result of [errorBuilder] when the
/// file does not exist or cannot be read.
Widget buildFileImage(
  String path, {
  required double? height,
  required double? width,
  required BoxFit fit,
  required Map<String, String>? headers,
  required Widget Function() errorBuilder,
}) => impl.buildFileImage(
  path,
  height: height,
  width: width,
  fit: fit,
  headers: headers,
  errorBuilder: errorBuilder,
);
