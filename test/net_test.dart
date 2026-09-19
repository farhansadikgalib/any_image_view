import 'dart:io';
import 'dart:typed_data';

import 'package:any_image_view/src/net/disk_cache.dart';
import 'package:any_image_view/src/net/fetch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cache keys are stable and distinct', () {
    expect(
      AnyImageCache.cacheKey('https://a/b.png'),
      AnyImageCache.cacheKey('https://a/b.png'),
    );
    expect(
      AnyImageCache.cacheKey('https://a/b.png'),
      isNot(AnyImageCache.cacheKey('https://a/c.png')),
    );
    expect(AnyImageCache.cacheKey('x'), matches(RegExp(r'^[0-9a-f]+_1$')));
  });

  test('disk cache round-trips, expires and clears', () async {
    final String key = AnyImageCache.cacheKey(
      'test://${DateTime.now().microsecondsSinceEpoch}',
    );
    final Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3]);
    await writeCached(key, bytes);
    expect(await readCached(key), bytes);

    AnyImageCache.maxAge = const Duration(seconds: -1);
    expect(await readCached(key), isNull);
    AnyImageCache.maxAge = const Duration(days: 7);

    await writeCached(key, bytes);
    await AnyImageCache.evict('missing');
    expect(await readCached(key), bytes);
    await AnyImageCache.clear();
    expect(await readCached(key), isNull);
  });

  test(
    'fetchBytes downloads from a local server and reports failures',
    () async {
      final HttpServer server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      server.listen((HttpRequest request) {
        if (request.uri.path == '/ok') {
          request.response.headers.contentType = ContentType.text;
          request.response.write('hello ${request.headers.value('x-token')}');
        } else {
          request.response.statusCode = HttpStatus.notFound;
        }
        request.response.close();
      });
      final String base = 'http://${server.address.host}:${server.port}';
      try {
        expect(
          await fetchString(
            Uri.parse('$base/ok'),
            headers: <String, String>{'x-token': 't'},
          ),
          'hello t',
        );
        expect(await fetchBytes(Uri.parse('$base/missing')), isNull);
        expect(
          await fetchBytes(Uri.parse('http://127.0.0.1:1/unreachable')),
          isNull,
        );
      } finally {
        await server.close(force: true);
      }
    },
  );
}
