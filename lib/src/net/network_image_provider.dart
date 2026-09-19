import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'disk_cache.dart';
import 'fetch.dart';

/// An [ImageProvider] that downloads [url] once and keeps the bytes in the
/// on-disk cache (see [AnyImageCache]) for later loads. Decoded frames are
/// cached in Flutter's regular [ImageCache] like any other provider.
///
/// On the web prefer [NetworkImage]; the browser already caches, and it can
/// fall back to an `<img>` element for cross-origin images.
@immutable
class AnyNetworkImage extends ImageProvider<AnyNetworkImage> {
  /// Creates a provider for [url].
  const AnyNetworkImage(this.url, {this.headers, this.scale = 1.0});

  /// The URL to download.
  final String url;

  /// Extra HTTP headers sent with the request (ignored for cache hits).
  final Map<String, String>? headers;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<AnyNetworkImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<AnyNetworkImage>(this);

  @override
  ImageStreamCompleter loadImage(
    AnyNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode),
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<AnyNetworkImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _load(
    AnyNetworkImage key,
    ImageDecoderCallback decode,
  ) async {
    final String cacheKey = AnyImageCache.cacheKey(key.url);
    Uint8List? bytes = await readCached(cacheKey);
    if (bytes == null) {
      bytes = await fetchBytes(Uri.parse(key.url), headers: key.headers);
      if (bytes == null || bytes.isEmpty) {
        throw NetworkImageLoadException(statusCode: 0, uri: Uri.parse(key.url));
      }
      // Best-effort; do not delay decoding on disk I/O.
      // ignore: unawaited_futures
      writeCached(cacheKey, bytes);
    }
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is AnyNetworkImage && other.url == url && other.scale == scale;

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => 'AnyNetworkImage("$url", scale: $scale)';
}
