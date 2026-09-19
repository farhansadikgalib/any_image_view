import 'dart:js_interop';
import 'dart:typed_data';

@JS('fetch')
external JSPromise<_Response> _fetch(JSString input, JSAny? init);

extension type _Response._(JSObject _) implements JSObject {
  external int get status;
  external JSPromise<JSArrayBuffer> arrayBuffer();
}

Future<Uint8List?> fetchBytes(Uri uri, {Map<String, String>? headers}) async {
  try {
    final JSAny? init = headers == null
        ? null
        : <String, Object>{'headers': headers}.jsify();
    final _Response response = await _fetch(uri.toString().toJS, init).toDart;
    if (response.status < 200 || response.status >= 300) return null;
    final JSArrayBuffer buffer = await response.arrayBuffer().toDart;
    return buffer.toDart.asUint8List();
  } catch (_) {
    return null;
  }
}
