import 'dart:io';
import 'dart:typed_data';

/// One shared client so keep-alive connections are reused across images.
final HttpClient _client = HttpClient()
  ..autoUncompress = true
  ..connectionTimeout = const Duration(seconds: 15);

Future<Uint8List?> fetchBytes(Uri uri, {Map<String, String>? headers}) async {
  try {
    final HttpClientRequest request = await _client.getUrl(uri);
    headers?.forEach(request.headers.set);
    final HttpClientResponse response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await response.drain<void>();
      return null;
    }
    final BytesBuilder builder = BytesBuilder(copy: false);
    await for (final List<int> chunk in response) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  } catch (_) {
    return null;
  }
}
