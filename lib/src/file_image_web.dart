import 'package:flutter/widgets.dart';

Widget buildFileImage(
  String path, {
  required double? height,
  required double? width,
  required BoxFit fit,
  required Map<String, String>? headers,
  required Widget Function() errorBuilder,
}) => Image.network(
  path,
  height: height,
  width: width,
  fit: fit,
  headers: headers,
  errorBuilder: (_, _, _) => errorBuilder(),
);
