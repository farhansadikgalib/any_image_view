import 'dart:io';
import 'dart:typed_data';

/// Resolved once: the first candidate directory the app can actually write.
Future<Directory?>? _directory;

Future<Directory?> _cacheDirectory() => _directory ??= _resolveDirectory();

Future<Directory?> _resolveDirectory() async {
  for (final Directory candidate in _candidates()) {
    try {
      await candidate.create(recursive: true);
      // Probe a write so a directory that exists but is read-only is skipped.
      final File probe = File('${candidate.path}/.probe');
      await probe.writeAsBytes(const <int>[0], flush: true);
      await probe.delete();
      return candidate;
    } catch (_) {
      // Try the next candidate.
    }
  }
  return null;
}

List<Directory> _candidates() {
  final List<Directory> out = <Directory>[];
  if (Platform.isAndroid) {
    // `Directory.systemTemp` is `/data/local/tmp` on Android, which apps
    // cannot write. The app's own cache directory is derived from the process
    // name, which is the package name for the main process.
    final String? package = _androidPackageName();
    if (package != null) {
      out.add(Directory('/data/data/$package/cache/any_image_view'));
    }
  }
  final String? tmp = Platform.environment['TMPDIR'];
  if (tmp != null && tmp.isNotEmpty) out.add(Directory('$tmp/any_image_view'));
  out.add(Directory('${Directory.systemTemp.path}/any_image_view'));
  return out;
}

String? _androidPackageName() {
  try {
    // NUL-separated argv; the first entry is "com.example.app" for the main
    // process or "com.example.app:remote" for a secondary one.
    final String cmdline = File('/proc/self/cmdline').readAsStringSync();
    final String name = cmdline
        .split(String.fromCharCode(0))
        .first
        .split(':')
        .first
        .trim();
    return RegExp(r'^[A-Za-z][\w.]*$').hasMatch(name) ? name : null;
  } catch (_) {
    return null;
  }
}

Future<File?> _file(String key) async {
  final Directory? dir = await _cacheDirectory();
  return dir == null ? null : File('${dir.path}/$key');
}

Future<Uint8List?> read(String key, Duration maxAge) async {
  try {
    final File? file = await _file(key);
    if (file == null || !await file.exists()) return null;
    final DateTime modified = await file.lastModified();
    if (DateTime.now().difference(modified) > maxAge) {
      await file.delete();
      return null;
    }
    return await file.readAsBytes();
  } catch (_) {
    return null;
  }
}

Future<void> write(String key, Uint8List bytes) async {
  try {
    final File? file = await _file(key);
    if (file == null) return;
    // Write to a temp name first so a concurrent reader never sees a partial file.
    final File tmp = File('${file.path}.part');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(file.path);
  } catch (_) {
    // Caching is best-effort.
  }
}

Future<void> remove(String key) async {
  try {
    final File? file = await _file(key);
    if (file != null && await file.exists()) await file.delete();
  } catch (_) {}
}

Future<void> clear() async {
  try {
    final Directory? dir = await _cacheDirectory();
    if (dir != null && await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }
  } catch (_) {}
}

/// The directory in use, or `null` if no writable location was found.
Future<String?> directoryPath() async => (await _cacheDirectory())?.path;
