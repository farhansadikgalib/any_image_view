/// Minimal ZIP reading (stored and deflate entries) for `.zip` / dotLottie
/// bundles. Inflating needs `dart:io`'s zlib, so this returns `null` on the web.
library;

import 'dart:typed_data';

import 'zip_stub.dart' if (dart.library.io) 'zip_io.dart' as impl;

/// Returns the inflated bytes of the first entry accepted by [select], or
/// `null` if there is none or the archive cannot be read.
Uint8List? readZipEntry(Uint8List archive, bool Function(String name) select) =>
    impl.readZipEntry(archive, select);
