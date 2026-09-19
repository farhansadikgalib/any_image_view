import 'dart:ui';

import 'package:any_image_view/src/svg/svg_values.dart';
import 'package:any_image_view/src/xml.dart';
import 'package:flutter/widgets.dart' show Matrix4;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XML parser', () {
    test('parses elements, attributes, text, entities and CDATA', () {
      final XmlElement root = parseXml('''
<?xml version="1.0"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<!-- comment -->
<svg:svg xmlns:svg="http://www.w3.org/2000/svg" width='10' height="20">
  <g id="a&amp;b" class="x"/>
  <style><![CDATA[ .x { fill: red; } ]]></style>
  <text>Tom &amp; Jerry &#65;&#x42;</text>
</svg:svg>''');
      expect(root.name, 'svg');
      expect(root.attributes['width'], '10');
      expect(root.attributes['height'], '20');
      expect(root.elements.length, 3);
      expect(root.elements.first.attributes['id'], 'a&b');
      expect(root.elements.elementAt(1).text.trim(), '.x { fill: red; }');
      expect(root.elements.last.text, 'Tom & Jerry AB');
    });

    test('rejects malformed input', () {
      expect(
        () => parseXml('<svg><g></svg>'),
        throwsA(isA<XmlParseException>()),
      );
      expect(() => parseXml(''), throwsA(isA<XmlParseException>()));
    });
  });

  group('SVG path data', () {
    test('absolute and relative commands', () {
      final Path p = parseSvgPath('M10 10 h 10 v 10 H 10 Z');
      expect(p.getBounds(), const Rect.fromLTWH(10, 10, 10, 10));
    });

    test('compact number syntax and arc flags', () {
      final Path p = parseSvgPath('M1.5.5l-1-1a1 1 0 01 2 2');
      expect(p.getBounds().left, closeTo(0.5, 0.01));
      final Path arc = parseSvgPath('M0 5A5 5 0 1 1 10 5');
      expect(arc.getBounds().width, closeTo(10, 0.01));
    });

    test('smooth curves and implicit line-to after move', () {
      final Path p = parseSvgPath(
        'M0 0 10 0 10 10 C 10 20 0 20 0 10 S 0 0 0 0',
      );
      expect(p.getBounds().bottom, greaterThan(10));
    });

    test('malformed data throws', () {
      expect(() => parseSvgPath('M 1'), throwsFormatException);
      expect(() => parseSvgPath('X 1 2'), throwsFormatException);
    });
  });

  group('SVG values', () {
    test('transform list composes in order', () {
      final Matrix4 m = parseSvgTransform('translate(10 20) scale(2)');
      expect(m.storage[12], 10);
      expect(m.storage[13], 20);
      expect(m.storage[0], 2);
      final Matrix4 r = parseSvgTransform('rotate(90 5 5)');
      final List<double> v = r.applyToVector3Array(<double>[10, 5, 0]);
      expect(v[0], closeTo(5, 1e-9));
      expect(v[1], closeTo(10, 1e-9));
    });

    test('colors', () {
      expect(parseSvgColor('#f00'), const Color(0xFFFF0000));
      expect(parseSvgColor('#ff000080'), const Color(0x80FF0000));
      expect(parseSvgColor('rgb(0, 255, 0)'), const Color(0xFF00FF00));
      expect(parseSvgColor('rgba(0,0,255,0.5)')!.a, closeTo(0.5, 0.01));
      expect(parseSvgColor('hsl(120, 100%, 50%)'), const Color(0xFF00FF00));
      expect(parseSvgColor('RebeccaPurple'), const Color(0xFF663399));
      expect(parseSvgColor('nope'), isNull);
    });

    test('paint values', () {
      expect(parseSvgPaint('none')!.isNone, isTrue);
      expect(parseSvgPaint('currentColor')!.isCurrentColor, isTrue);
      expect(parseSvgPaint('url(#g1)')!.reference, 'g1');
      expect(parseSvgPaint('blue')!.color, const Color(0xFF0000FF));
    });

    test('lengths and opacities', () {
      expect(parseSvgLength('12'), 12);
      expect(parseSvgLength('1in'), 96);
      expect(parseSvgLength('50%', reference: 200), 100);
      expect(parseSvgLength('50%'), isNull);
      expect(parseSvgOpacity('50%'), 0.5);
      expect(parseSvgOpacity('2'), 1);
    });
  });
}
