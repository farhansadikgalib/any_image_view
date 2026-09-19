/// A small, dependency-free XML reader sufficient for SVG documents.
///
/// Supports elements, attributes (single or double quoted), text and CDATA
/// nodes, comments, processing instructions, DOCTYPE declarations and the
/// predefined / numeric character entities. Namespace prefixes on element
/// names are dropped (`svg:path` → `path`); attribute names keep theirs
/// (`xlink:href`).
library;

/// An XML element.
class XmlElement {
  XmlElement(this.name, this.attributes, this.children);

  /// Local element name without namespace prefix.
  final String name;

  /// Attributes as written, entity-decoded.
  final Map<String, String> attributes;

  /// Child nodes: [XmlElement] or [String] text.
  final List<Object> children;

  /// Child elements only.
  Iterable<XmlElement> get elements => children.whereType<XmlElement>();

  /// Concatenated text of all descendant text nodes.
  String get text {
    final StringBuffer buffer = StringBuffer();
    void walk(XmlElement element) {
      for (final Object child in element.children) {
        if (child is String) {
          buffer.write(child);
        } else if (child is XmlElement) {
          walk(child);
        }
      }
    }

    walk(this);
    return buffer.toString();
  }

  /// Depth-first traversal of this element and all descendants.
  Iterable<XmlElement> get descendants sync* {
    yield this;
    for (final XmlElement child in elements) {
      yield* child.descendants;
    }
  }
}

/// Thrown when the input is not well-formed enough to build a tree.
class XmlParseException implements Exception {
  XmlParseException(this.message, this.offset);
  final String message;
  final int offset;
  @override
  String toString() => 'XmlParseException: $message (at $offset)';
}

/// Parses [source] and returns its root element.
XmlElement parseXml(String source) => _XmlReader(source).readDocument();

class _XmlReader {
  _XmlReader(this.src);

  final String src;
  int pos = 0;

  bool get atEnd => pos >= src.length;

  XmlElement readDocument() {
    XmlElement? root;
    while (!atEnd) {
      skipWhitespace();
      if (atEnd) break;
      if (startsWith('<?')) {
        skipUntil('?>');
      } else if (startsWith('<!--')) {
        skipUntil('-->');
      } else if (startsWith('<!')) {
        skipDeclaration();
      } else if (src.codeUnitAt(pos) == 0x3C /* < */ ) {
        if (root != null) fail('multiple root elements');
        root = readElement();
      } else {
        // Stray text outside the root element.
        pos++;
      }
    }
    if (root == null) fail('no root element');
    return root;
  }

  XmlElement readElement() {
    expect('<');
    final String rawName = readName();
    final String name = _localName(rawName);
    final Map<String, String> attributes = <String, String>{};
    while (true) {
      skipWhitespace();
      if (atEnd) fail('unterminated start tag <$rawName>');
      if (startsWith('/>')) {
        pos += 2;
        return XmlElement(name, attributes, const <Object>[]);
      }
      if (src.codeUnitAt(pos) == 0x3E /* > */ ) {
        pos++;
        break;
      }
      final String attrName = readName();
      skipWhitespace();
      String value = '';
      if (!atEnd && src.codeUnitAt(pos) == 0x3D /* = */ ) {
        pos++;
        skipWhitespace();
        value = readQuoted();
      }
      attributes[attrName] = value;
    }

    final List<Object> children = <Object>[];
    while (true) {
      if (atEnd) fail('unterminated element <$rawName>');
      if (startsWith('</')) {
        pos += 2;
        readName();
        skipWhitespace();
        expect('>');
        return XmlElement(name, attributes, children);
      }
      if (startsWith('<!--')) {
        skipUntil('-->');
      } else if (startsWith('<![CDATA[')) {
        pos += 9;
        final int end = src.indexOf(']]>', pos);
        if (end == -1) fail('unterminated CDATA');
        children.add(src.substring(pos, end));
        pos = end + 3;
      } else if (startsWith('<?')) {
        skipUntil('?>');
      } else if (startsWith('<!')) {
        skipDeclaration();
      } else if (src.codeUnitAt(pos) == 0x3C) {
        children.add(readElement());
      } else {
        final int end = src.indexOf('<', pos);
        final int stop = end == -1 ? src.length : end;
        final String text = _decodeEntities(src.substring(pos, stop));
        if (text.trim().isNotEmpty) children.add(text);
        pos = stop;
      }
    }
  }

  String readName() {
    final int start = pos;
    while (!atEnd) {
      final int c = src.codeUnitAt(pos);
      if (c == 0x20 ||
          c == 0x09 ||
          c == 0x0A ||
          c == 0x0D ||
          c == 0x3E /* > */ ||
          c == 0x2F /* / */ ||
          c == 0x3D /* = */ ||
          c == 0x3C /* < */ ||
          c == 0x22 ||
          c == 0x27) {
        break;
      }
      pos++;
    }
    if (pos == start) fail('expected a name');
    return src.substring(start, pos);
  }

  String readQuoted() {
    if (atEnd) fail('expected quoted value');
    final int quote = src.codeUnitAt(pos);
    if (quote != 0x22 && quote != 0x27) {
      // Unquoted attribute value: tolerate up to whitespace or `>`.
      final int start = pos;
      while (!atEnd) {
        final int c = src.codeUnitAt(pos);
        if (c == 0x20 || c == 0x3E || c == 0x2F || c == 0x0A) break;
        pos++;
      }
      return _decodeEntities(src.substring(start, pos));
    }
    pos++;
    final int end = src.indexOf(String.fromCharCode(quote), pos);
    if (end == -1) fail('unterminated attribute value');
    final String value = src.substring(pos, end);
    pos = end + 1;
    return _decodeEntities(value);
  }

  void skipDeclaration() {
    // <!DOCTYPE ...> possibly containing an internal subset in [ ... ].
    int depth = 0;
    while (!atEnd) {
      final int c = src.codeUnitAt(pos++);
      if (c == 0x5B /* [ */ ) {
        depth++;
      } else if (c == 0x5D /* ] */ ) {
        depth--;
      } else if (c == 0x3E && depth <= 0) {
        return;
      }
    }
  }

  void skipUntil(String marker) {
    final int end = src.indexOf(marker, pos);
    pos = end == -1 ? src.length : end + marker.length;
  }

  void skipWhitespace() {
    while (!atEnd) {
      final int c = src.codeUnitAt(pos);
      if (c != 0x20 && c != 0x09 && c != 0x0A && c != 0x0D) return;
      pos++;
    }
  }

  bool startsWith(String s) => src.startsWith(s, pos);

  void expect(String s) {
    if (!startsWith(s)) fail('expected "$s"');
    pos += s.length;
  }

  Never fail(String message) => throw XmlParseException(message, pos);
}

String _localName(String name) {
  final int colon = name.indexOf(':');
  return colon == -1 ? name : name.substring(colon + 1);
}

String _decodeEntities(String text) {
  if (!text.contains('&')) return text;
  return text.replaceAllMapped(
    RegExp(r'&(#x[0-9a-fA-F]+|#[0-9]+|[a-zA-Z]+);'),
    (Match m) {
      final String entity = m[1]!;
      if (entity.startsWith('#x')) {
        return String.fromCharCode(int.parse(entity.substring(2), radix: 16));
      }
      if (entity.startsWith('#')) {
        return String.fromCharCode(int.parse(entity.substring(1)));
      }
      switch (entity) {
        case 'amp':
          return '&';
        case 'lt':
          return '<';
        case 'gt':
          return '>';
        case 'quot':
          return '"';
        case 'apos':
          return "'";
        case 'nbsp':
          return ' ';
      }
      return m[0]!;
    },
  );
}
