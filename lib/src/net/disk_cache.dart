/// On-disk cache for downloaded images. A no-op on the web, where the browser
/// cache already covers network images.
library;

import 'dart:typed_data';

import 'disk_cache_stub.dart' if (dart.library.io) 'disk_cache_io.dart' as impl;

/// Controls the on-disk cache used for network images on native platforms.
///
/// Files live in the app's cache directory on Android and under the system
/// temporary directory elsewhere, so the OS may purge them under storage
/// pressure; the cache is a performance aid, not persistent storage.
class AnyImageCache {
  AnyImageCache._();

  /// Cached files older than this are re-downloaded. Defaults to 7 days.
  static Duration maxAge = const Duration(days: 7);

  /// Deletes every cached file.
  static Future<void> clear() => impl.clear();

  /// The directory holding cached files, or `null` on the web or when no
  /// writable location could be found.
  static Future<String?> get directory => impl.directoryPath();

  /// Deletes the cached file for [url], if any.
  static Future<void> evict(String url) => impl.remove(cacheKey(url));

  /// Stable file name for [url]: two 32-bit FNV-1a hashes (different seeds)
  /// plus the URL length. Kept within 32-bit arithmetic so the same key is
  /// produced on the VM and on the web.
  static String cacheKey(String url) {
    final String a = _fnv1a32(url, 0x811c9dc5).toRadixString(16);
    final String b = _fnv1a32(url, 0x9747b28c).toRadixString(16);
    return '${a.padLeft(8, '0')}${b.padLeft(8, '0')}_${url.length}';
  }

  static int _fnv1a32(String text, int seed) {
    int h = seed;
    for (int i = 0; i < text.length; i++) {
      h ^= text.codeUnitAt(i);
      // h *= 16777619, written as shifts and adds so no intermediate value
      // exceeds what JavaScript numbers represent exactly.
      h =
          (h + (h << 1) + (h << 4) + (h << 7) + (h << 8) + (h << 24)) &
          0xFFFFFFFF;
    }
    return h;
  }
}

/// Reads the cached bytes for [key], or `null` if missing or expired.
Future<Uint8List?> readCached(String key) =>
    impl.read(key, AnyImageCache.maxAge);

/// Stores [bytes] under [key]. Failures are ignored.
Future<void> writeCached(String key, Uint8List bytes) => impl.write(key, bytes);
