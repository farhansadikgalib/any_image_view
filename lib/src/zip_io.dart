import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const int _endOfCentralDirectory = 0x06054b50;
const int _centralDirectoryHeader = 0x02014b50;
const int _localFileHeader = 0x04034b50;

Uint8List? readZipEntry(Uint8List archive, bool Function(String name) select) {
  try {
    final ByteData data = ByteData.sublistView(archive);
    // The end-of-central-directory record is at the tail, before an optional
    // comment of at most 65535 bytes.
    int eocd = -1;
    final int minStart = archive.length - 22 - 65535;
    for (int i = archive.length - 22; i >= 0 && i >= minStart; i--) {
      if (data.getUint32(i, Endian.little) == _endOfCentralDirectory) {
        eocd = i;
        break;
      }
    }
    if (eocd == -1) return null;
    final int entryCount = data.getUint16(eocd + 10, Endian.little);
    int offset = data.getUint32(eocd + 16, Endian.little);

    for (int n = 0; n < entryCount; n++) {
      if (data.getUint32(offset, Endian.little) != _centralDirectoryHeader) {
        return null;
      }
      final int method = data.getUint16(offset + 10, Endian.little);
      final int compressedSize = data.getUint32(offset + 20, Endian.little);
      final int nameLength = data.getUint16(offset + 28, Endian.little);
      final int extraLength = data.getUint16(offset + 30, Endian.little);
      final int commentLength = data.getUint16(offset + 32, Endian.little);
      final int localOffset = data.getUint32(offset + 42, Endian.little);
      final String name = utf8.decode(
        archive.sublist(offset + 46, offset + 46 + nameLength),
      );
      offset += 46 + nameLength + extraLength + commentLength;

      if (!select(name)) continue;
      if (data.getUint32(localOffset, Endian.little) != _localFileHeader) {
        return null;
      }
      final int localNameLength = data.getUint16(
        localOffset + 26,
        Endian.little,
      );
      final int localExtraLength = data.getUint16(
        localOffset + 28,
        Endian.little,
      );
      final int start = localOffset + 30 + localNameLength + localExtraLength;
      final Uint8List payload = archive.sublist(start, start + compressedSize);
      switch (method) {
        case 0:
          return payload;
        case 8:
          return Uint8List.fromList(ZLibDecoder(raw: true).convert(payload));
        default:
          return null;
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}
