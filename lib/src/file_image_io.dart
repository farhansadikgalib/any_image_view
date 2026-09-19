import 'dart:io';

import 'package:flutter/widgets.dart';

Widget buildFileImage(
  String path, {
  required double? height,
  required double? width,
  required BoxFit fit,
  required Map<String, String>? headers,
  required Widget Function() errorBuilder,
}) {
  final File file = path.startsWith('file://')
      ? File.fromUri(Uri.parse(path))
      : File(path);
  if (!file.existsSync()) return errorBuilder();
  return Image.file(
    file,
    height: height,
    width: width,
    fit: fit,
    errorBuilder: (_, _, _) => errorBuilder(),
  );
}
