/// Platform-neutral byte fetching. Native platforms use `dart:io`'s
/// [HttpClient]; the web uses the browser's `fetch` through `dart:js_interop`.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'fetch_io.dart' if (dart.library.js_interop) 'fetch_web.dart' as impl;

/// Downloads [uri] and returns the body bytes, or `null` on any failure
/// (transport error or a non-2xx status).
Future<Uint8List?> fetchBytes(Uri uri, {Map<String, String>? headers}) =>
    impl.fetchBytes(uri, headers: headers);

/// Downloads [uri] and decodes the body as UTF-8, or `null` on failure.
Future<String?> fetchString(Uri uri, {Map<String, String>? headers}) async {
  final Uint8List? bytes = await fetchBytes(uri, headers: headers);
  if (bytes == null) return null;
  return utf8.decode(bytes, allowMalformed: true);
}
