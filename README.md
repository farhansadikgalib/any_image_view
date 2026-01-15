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
  any_image_view: ^1.9.5
```

## Usage

```dart
import 'package:any_image_view/any_image_view.dart';

// Network
AnyImageView(imagePath: 'https://example.com/image.jpg', height: 200, width: 200)

// Asset
AnyImageView(imagePath: 'assets/image.png', height: 200, width: 200)

// SVG
AnyImageView(imagePath: 'assets/icon.svg', height: 40, width: 40)

// Lottie
AnyImageView(imagePath: 'assets/animation.json', height: 100, width: 100)

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
| `httpHeaders` | `Map?` | Auth headers |

## Supported Formats

PNG, JPG, WebP, GIF, SVG, Lottie (.json), TIFF, RAW, HEIC, BMP, ICO

## Platform Support

✅ Android · ✅ iOS · ✅ Web · ✅ macOS · ✅ Windows · ✅ Linux

---

<p align="center">
  Made with ❤️ by <a href="https://farhansadikgalib.com">Farhan Sadik Galib</a>
</p>
