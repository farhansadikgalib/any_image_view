/// Supported image types for `AnyImageView`.
enum ImageType {
  /// Scalable Vector Graphics format.
  svg,

  /// Portable Network Graphics format.
  png,

  /// JPEG format (alternative extension).
  jpg,

  /// JPEG format.
  jpeg,

  /// Tagged Image File Format.
  tiff,

  /// Raw image format.
  raw,

  /// WebP image format.
  webp,

  /// Graphics Interchange Format.
  gif,

  /// High Efficiency Image Container format.
  heic,

  /// High Efficiency Image File format.
  heif,

  /// Bitmap image format.
  bmp,

  /// AV1 Image File Format. Decoded by the platform where supported
  /// (Android 12+, iOS 16+, macOS 13+, web browsers).
  avif,

  /// Icon file format.
  ico,

  /// OpenEXR format.
  exr,

  /// High Dynamic Range format.
  hdr,

  /// Network URL (HTTP/HTTPS).
  network,

  /// Lottie JSON animation.
  json,

  /// Lottie ZIP / dotLottie animation.
  zip,

  /// Local file path.
  file,
}

/// Extension to detect image type from a string path.
extension ImageTypeExtension on String {
  /// Returns the [ImageType] based on the string content.
  ///
  /// Checks the URL protocol first, then file path prefixes, then the
  /// lower-cased file extension (ignoring any query string or fragment).
  ImageType get imageType {
    if (isHttpUrl(this)) return ImageType.network;
    if (startsWith('file://') || startsWith('/')) return ImageType.file;

    switch (extensionOf(this)) {
      case 'svg':
        return ImageType.svg;
      case 'json':
        return ImageType.json;
      case 'zip':
      case 'lottie':
        return ImageType.zip;
      case 'webp':
        return ImageType.webp;
      case 'gif':
        return ImageType.gif;
      case 'jpg':
      case 'jpeg':
        return ImageType.jpeg;
      case 'tif':
      case 'tiff':
        return ImageType.tiff;
      case 'raw':
        return ImageType.raw;
      case 'heic':
        return ImageType.heic;
      case 'heif':
        return ImageType.heif;
      case 'bmp':
        return ImageType.bmp;
      case 'avif':
        return ImageType.avif;
      case 'ico':
        return ImageType.ico;
      case 'exr':
        return ImageType.exr;
      case 'hdr':
        return ImageType.hdr;
      default:
        // Default to PNG for asset paths.
        return ImageType.png;
    }
  }
}

/// True if [path] is an HTTP(S) URL (case-insensitive scheme).
bool isHttpUrl(String path) {
  final String lower = path.toLowerCase();
  return lower.startsWith('http://') || lower.startsWith('https://');
}

/// Extracts the lower-cased file extension from [path], stripping any query
/// string or fragment first.
///
/// Returns an empty string when the path has no extension, or when the only
/// dot belongs to a directory segment (`assets/v1.2/photo`).
String extensionOf(String path) {
  int end = path.length;
  final int queryIndex = path.indexOf('?');
  if (queryIndex != -1) end = queryIndex;
  final int fragmentIndex = path.indexOf('#');
  if (fragmentIndex != -1 && fragmentIndex < end) end = fragmentIndex;
  if (end == 0) return '';

  final int dotIndex = path.lastIndexOf('.', end - 1);
  if (dotIndex == -1 || dotIndex < path.lastIndexOf('/', end - 1)) return '';
  return path.substring(dotIndex + 1, end).toLowerCase();
}
