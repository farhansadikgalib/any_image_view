# 🖼️ Any Image View

[![Pub Version](https://img.shields.io/pub/v/any_image_view.svg?style=flat-square)](https://pub.dev/packages/any_image_view)
[![Pub Points](https://img.shields.io/pub/points/any_image_view?style=flat-square)](https://pub.dev/packages/any_image_view/score)
[![Pub Likes](https://img.shields.io/pub/likes/any_image_view?style=flat-square)](https://pub.dev/packages/any_image_view)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<p align="center">
  <img src="https://raw.githubusercontent.com/farhansadikgalib/any_image_view/main/raw/banner.png" alt="Any Image View Demo"/>
</p>

**One widget to display them all!** Network images, local files, SVGs, Lottie animations, and more — with built-in loading states, error handling, and smooth animations.

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🌐 **Network Images** | Best resolution with fade animations & HTTP headers support |
| 📁 **Local Files** | XFile & String paths from device |
| 🎨 **SVG & Lottie** | Vector graphics and animations (local assets) |
| 🖼️ **All Formats** | PNG, JPG, WebP, GIF, TIFF, RAW, HEIC, BMP, ICO |
| ⏳ **Shimmer Loading** | Built-in animated placeholder |
| 🛡️ **Error Handling** | Auto broken_image icon or custom widget |
| 🔍 **Pinch-to-Zoom** | Optional zoom & pan support |

---

## 🚀 Quick Start

```yaml
dependencies:
  any_image_view: ^1.9.5
```

```dart
import 'package:any_image_view/any_image_view.dart';

AnyImageView(
  imagePath: 'https://picsum.photos/300/200',
  height: 200,
  width: 300,
  borderRadius: BorderRadius.circular(12),
)
```

---

## 📖 Usage Examples

### Network Image
```dart
AnyImageView(
  imagePath: 'https://example.com/image.jpg',
  height: 200,
  width: double.infinity,
  fit: BoxFit.cover,
)
```

### Circular Avatar
```dart
AnyImageView(
  imagePath: user.avatarUrl,
  height: 80,
  width: 80,
  shape: BoxShape.circle,
  border: Border.all(color: Colors.blue, width: 2),
)
```

### SVG Icon
```dart
AnyImageView(
  imagePath: 'assets/icons/logo.svg',
  height: 40,
  width: 40,
)
```

### Lottie Animation
```dart
AnyImageView(
  imagePath: 'assets/animations/loading.json',
  height: 100,
  width: 100,
)
```

### XFile (Image Picker)
```dart
AnyImageView(
  imagePath: pickedXFile, // XFile object directly
  height: 250,
  width: 250,
  borderRadius: BorderRadius.circular(15),
)
```

### With Custom Loading & Error
```dart
AnyImageView(
  imagePath: imageUrl,
  height: 200,
  width: 200,
  placeholderWidget: CircularProgressIndicator(),
  errorWidget: Icon(Icons.error, color: Colors.red),
)
```

### Authenticated Network Image
```dart
AnyImageView(
  imagePath: 'https://api.example.com/private/image.jpg',
  httpHeaders: {'Authorization': 'Bearer $token'},
  height: 200,
  width: 200,
)
```

### Zoomable Image
```dart
AnyImageView(
  imagePath: 'assets/images/photo.jpg',
  height: 300,
  width: double.infinity,
  enableZoom: true,
)
```

---

## 🔧 API Reference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `imagePath` | `Object?` | — | URL, asset path, file path, or XFile |
| `height` | `double?` | — | Container height |
| `width` | `double?` | — | Container width |
| `fit` | `BoxFit?` | `cover` | How image fits in container |
| `shape` | `BoxShape` | `rectangle` | `rectangle` or `circle` |
| `borderRadius` | `BorderRadius?` | — | Rounded corners |
| `border` | `BoxBorder?` | — | Border styling |
| `boxShadow` | `List<BoxShadow>?` | — | Shadow effects |
| `margin` | `EdgeInsets?` | — | Outer spacing |
| `padding` | `EdgeInsets?` | — | Inner spacing |
| `onTap` | `VoidCallback?` | — | Tap callback |
| `placeholderWidget` | `Widget?` | Shimmer | Custom loading widget |
| `errorWidget` | `Widget?` | broken_image | Custom error widget |
| `fadeDuration` | `Duration` | `400ms` | Fade animation duration |
| `enableZoom` | `bool` | `false` | Pinch-to-zoom support |
| `httpHeaders` | `Map<String, String>?` | — | HTTP headers for network images |
| `maxRetryAttempts` | `int` | `3` | Retry attempts for failed requests |

---

## 📱 Platform Support

| Android | iOS | Web | macOS | Windows | Linux |
|:-------:|:---:|:---:|:-----:|:-------:|:-----:|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 🔄 Migration from Multiple Widgets

**Before:**
```dart
// Network
CachedNetworkImage(imageUrl: url, ...)
// File
Image.file(File(path), ...)
// SVG
SvgPicture.asset('icon.svg', ...)
```

**After:**
```dart
// All in one!
AnyImageView(imagePath: source, ...)
```

---

## 🤝 Support

- 🐛 [Report Bug](https://github.com/farhansadikgalib/any_image_view/issues)
- 💡 [Request Feature](https://github.com/farhansadikgalib/any_image_view/issues)
- 📧 [farhansadikgalib@gmail.com](mailto:farhansadikgalib@gmail.com)

---

<div align="center">
  <b>Made with ❤️ by <a href="https://farhansadikgalib.com">Farhan Sadik Galib</a></b>
  <br/>
  <sub>If this helps you, give it a ⭐ on <a href="https://pub.dev/packages/any_image_view">pub.dev</a></sub>
</div>
