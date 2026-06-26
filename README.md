# 🖼️ Any Image View

[![Pub Version](https://img.shields.io/pub/v/any_image_view.svg)](https://pub.dev/packages/any_image_view)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<p align="center">
  <img src="https://raw.githubusercontent.com/farhansadikgalib/any_image_view/main/raw/banner.png" alt="Any Image View"/>
</p>

**One widget for all image types** — Network, Assets, SVG, Lottie, XFile with built-in shimmer loading & error handling.

## Installation

```yaml
dependencies:
  any_image_view: ^2.3.0
```

### Android NDK version

This package depends on native plugins (the `jni` library, pulled in transitively
via `path_provider`) that require the NDK shipped with your Flutter SDK. Apps
created with an older Flutter template may omit the `ndkVersion` line and show
this warning on every Android build:

```
Your project is configured with Android NDK <x>, but the following plugin(s)
depend on a different Android NDK version:
- jni requires Android NDK 28.2.13676358
```

Recent `flutter create` templates already include the fix below, so most apps
never see this. If yours does, add this one line to `android/app/build.gradle.kts`:

```kotlin
android {
    ndkVersion = flutter.ndkVersion
    // ...
}
```

(or `ndkVersion = flutter.ndkVersion` in `android/app/build.gradle` for the Groovy DSL).

Using `flutter.ndkVersion` rather than a hardcoded value means it always tracks
your own Flutter SDK — it never goes stale and pins no dependency, so it won't
conflict with other packages.

## Usage

```dart
import 'package:any_image_view/any_image_view.dart';

// Network
AnyImageView(imagePath: 'https://example.com/image.jpg', height: 200, width: 200)

// Asset
AnyImageView(imagePath: 'assets/image.png', height: 200, width: 200)

// SVG (asset or network)
AnyImageView(imagePath: 'assets/icon.svg', height: 40, width: 40)
AnyImageView(imagePath: 'https://example.com/icon.svg', height: 40, width: 40, svgColor: Colors.blue)

// Lottie
AnyImageView(imagePath: 'assets/animation.json', height: 100, width: 100)

// AVIF (asset, network, or file — animated AVIFs auto-play)
AnyImageView(imagePath: 'assets/photo.avif', height: 200, width: 200)
AnyImageView(imagePath: 'https://example.com/photo.avif', height: 200, width: 200)

// XFile (Image Picker)
AnyImageView(imagePath: xFile, height: 200, width: 200)

// Circular Avatar
AnyImageView(imagePath: url, height: 80, width: 80, shape: BoxShape.circle)

// With Options
AnyImageView(
  imagePath: url,
  height: 200,
  width: 200,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(12),
  enableZoom: true,
  placeholderWidget: CircularProgressIndicator(),
  errorWidget: Icon(Icons.error),
)
```

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `imagePath` | `Object?` | URL, asset path, or XFile |
| `height` / `width` | `double?` | Dimensions |
| `fit` | `BoxFit?` | Image fit (default: cover) |
| `shape` | `BoxShape` | rectangle or circle |
| `borderRadius` | `BorderRadius?` | Rounded corners |
| `enableZoom` | `bool` | Pinch-to-zoom (default: false) |
| `placeholderWidget` | `Widget?` | Custom loader |
| `errorWidget` | `Widget?` | Custom error |
| `httpHeaders` | `Map?` | Auth headers for network/SVG |
| `svgColor` | `Color?` | Tint color for SVG (asset & network) |
| `svgColorFilter` | `ColorFilter?` | Custom color filter for SVG |

## Supported Formats

PNG, JPG, WebP, GIF, AVIF, SVG, Lottie (.json), TIFF, RAW, HEIC, BMP, ICO

## Platform Support

✅ Android · ✅ iOS · ✅ Web · ✅ macOS · ✅ Windows · ✅ Linux

---

