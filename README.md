# 🖼️ Any Image View

[![Pub Version](https://img.shields.io/pub/v/any_image_view.svg?style=flat-square)](https://pub.dev/packages/any_image_view)
[![Pub Points](https://img.shields.io/pub/points/any_image_view?style=flat-square)](https://pub.dev/packages/any_image_view/score)
[![Pub Likes](https://img.shields.io/pub/likes/any_image_view?style=flat-square)](https://pub.dev/packages/any_image_view)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<p align="center">
  <img src="https://raw.githubusercontent.com/farhansadikgalib/any_image_view/main/raw/banner.png" 
  alt="Any Image View Demo" width="600"/>
</p>

<p align="center"><strong>The Ultimate All-in-One Image Widget for Flutter</strong></p>

<p align="center">
One widget to display <strong>any image</strong> from <strong>any source</strong>.<br/>
Network, local, SVG, Lottie, XFile – it handles everything!<br/>
<strong>📱 Mobile • 🌐 Web • 💻 Desktop</strong>
</p>

---

## ✨ Features

- 🌐 **Network Images** - String URLs with auto-caching & fade animations
- 📁 **XFile Support** - Direct integration with image_picker (no conversion needed!)
- 📂 **File Paths** - Absolute & relative path strings (file://, /storage/, etc.)
- 🎨 **SVG & Lottie** - Both local assets and network URLs
- 🖼️ **All Formats** - PNG, JPG, WebP, GIF, TIFF, RAW, HEIC, HEIF, BMP, ICO, EXR, HDR
- 🔍 **Zoom Support** - Pinch-to-zoom & pan gestures
- ✨ **Smart Loading** - Beautiful shimmer loading effects
- 🛡️ **Error Handling** - Built-in fallback image (not_found.png)
- 🎯 **Custom Styling** - Borders, shadows, shapes (circle/rectangle)
- 🌍 **Full Web Support** - Works seamlessly on Flutter Web with CORS handling

---

## 🚀 Quick Start

### Installation

```yaml
dependencies:
  any_image_view: ^1.7.0
```

### Basic Usage

```dart
import 'package:any_image_view/any_image_view.dart';

AnyImageView(
  imagePath: 'https://picsum.photos/300/200',
  height: 200,
  width: 300,
  borderRadius: BorderRadius.circular(12),
)
```

**That's it!** Works with any image source automatically. 🎉

---

## 📖 Usage Examples

### Network Image (String URL)

```dart
AnyImageView(
  imagePath: 'https://example.com/image.jpg',
  height: 200,
  width: double.infinity,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(12),
)
```

### Local File Path (String)

```dart
AnyImageView(
  imagePath: '/storage/emulated/0/Pictures/photo.jpg',  // Absolute path
  height: 200,
  width: 200,
)

// Or relative path
AnyImageView(
  imagePath: 'file:///path/to/image.jpg',
  height: 200,
  width: 200,
)
```

### XFile (from image_picker)

```dart
import 'package:image_picker/image_picker.dart';

// Pick image
final XFile? image = await ImagePicker().pickImage(
  source: ImageSource.gallery,
);

// Display directly - no conversion needed!
AnyImageView(
  imagePath: image,  // ✨ Direct XFile support!
  height: 250,
  width: 250,
  borderRadius: BorderRadius.circular(15),
)
```

### File Object (dart:io)

```dart
import 'dart:io';

File imageFile = File('/path/to/image.jpg');

// Pass File path as String
AnyImageView(
  imagePath: imageFile.path,
  height: 200,
  width: 200,
)
```

### Asset Image

```dart
AnyImageView(
  imagePath: 'assets/images/banner.png',
  height: 200,
  width: double.infinity,
)
```

### SVG (Asset or Network)

```dart
// From assets
AnyImageView(
  imagePath: 'assets/icons/logo.svg',
  height: 50,
  width: 50,
)

// From network
AnyImageView(
  imagePath: 'https://example.com/icon.svg',
  height: 50,
  width: 50,
)
```

### Lottie Animation

```dart
// From network
AnyImageView(
  imagePath: 'https://example.com/animation.json',
  height: 150,
  width: 150,
)

// From assets
AnyImageView(
  imagePath: 'assets/animations/loading.json',
  height: 150,
  width: 150,
)
```

### Profile Avatar

```dart
AnyImageView(
  imagePath: user.avatarUrl,  // Can be URL, XFile, or path!
  height: 80,
  width: 80,
  shape: BoxShape.circle,
  border: Border.all(color: Colors.blue, width: 2),
)
```

### With Zoom

```dart
AnyImageView(
  imagePath: imageUrl,
  enableZoom: true,  // Pinch to zoom!
  height: 400,
  width: double.infinity,
)
```

### Custom Loading & Error

```dart
AnyImageView(
  imagePath: imageUrl,
  placeholderWidget: CircularProgressIndicator(),
  errorWidget: Icon(Icons.broken_image, size: 50),
)
```

---

## 🎨 Styling Options

```dart
AnyImageView(
  imagePath: imageUrl,
  height: 200,
  width: 200,
  
  // Shape & Border
  shape: BoxShape.circle,  // or BoxShape.rectangle
  border: Border.all(color: Colors.blue, width: 2),
  borderRadius: BorderRadius.circular(16),
  
  // Shadow
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ],
  
  // Spacing
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.all(8),
  
  // Image Fitting
  fit: BoxFit.cover,
  alignment: Alignment.center,
  
  // Animation
  fadeDuration: Duration(milliseconds: 500),
  
  // Interaction
  onTap: () => print('Tapped!'),
  enableZoom: true,
)
```

---

## 📋 API Reference

### Constructor Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `imagePath` | `Object?` | - | **String** (URL/path) or **XFile** object |
| `height` | `double?` | - | Image height |
| `width` | `double?` | - | Image width |
| `fit` | `BoxFit?` | `BoxFit.cover` | How image fits |
| `shape` | `BoxShape` | `rectangle` | Rectangle or circle |
| `border` | `BoxBorder?` | - | Border styling |
| `borderRadius` | `BorderRadius?` | - | Rounded corners |
| `boxShadow` | `List<BoxShadow>?` | - | Shadow effects |
| `margin` | `EdgeInsets?` | - | Outer spacing |
| `padding` | `EdgeInsets?` | - | Inner spacing |
| `enableZoom` | `bool` | `false` | Enable pinch-to-zoom |
| `fadeDuration` | `Duration` | `400ms` | Fade animation |
| `placeholderWidget` | `Widget?` | Shimmer | Custom loading |
| `errorWidget` | `Widget?` | Built-in | Custom error |
| `onTap` | `VoidCallback?` | - | Tap callback |

### imagePath Parameter Accepts:

| Type | Example | Description |
|------|---------|-------------|
| **Network URL** | `'https://example.com/image.jpg'` | HTTP/HTTPS URLs |
| **Asset Path** | `'assets/images/photo.png'` | Bundled assets |
| **Absolute Path** | `'/storage/emulated/0/pic.jpg'` | Full file system path |
| **File URI** | `'file:///path/to/image.jpg'` | File protocol URLs |
| **XFile** | `XFile('/path/to/image.jpg')` | From image_picker |
| **File.path** | `File('/path').path` | dart:io File path string |

### Supported Formats

| Type | Extensions | Sources |
|------|-----------|---------|
| **Images** | png, jpg, jpeg, webp, gif, tiff, raw | Network, Asset, File Path, XFile |
| **Advanced** | heic, heif, bmp, ico, exr, hdr | Network, Asset, File Path, XFile |
| **Vector** | svg | Network, Asset |
| **Animation** | json, zip (Lottie) | Network, Asset |

### Auto-Detection

The widget automatically detects the image type from:
- ✅ File extension (`.svg`, `.json`, `.png`, etc.)
- ✅ URL protocol (`http://`, `https://`)
- ✅ File path (`file://`, absolute paths)
- ✅ Object type (XFile)

---

## 💡 Pro Tips

### XFile & File Path Best Practices

1. **XFile from image_picker** - Use directly, no conversion:
   ```dart
   final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
   if (image != null) {
     AnyImageView(imagePath: image)  // ✅ Direct usage
   }
   ```

2. **File path from File object** - Extract path:
   ```dart
   import 'dart:io';
   
   File file = File('/path/to/image.jpg');
   AnyImageView(imagePath: file.path)  // ✅ Use file.path
   ```

3. **Check file existence** for local paths:
   ```dart
   if (await File(path).exists()) {
     AnyImageView(imagePath: path)
   }
   ```

### General Tips

4. **Always specify dimensions** for better performance:
   ```dart
   AnyImageView(imagePath: url, height: 200, width: 200)
   ```

5. **Use smaller placeholders** in lists for memory efficiency

6. **Add error widgets** for better UX:
   ```dart
   errorWidget: Icon(Icons.broken_image)
   ```

7. **Provide semantic labels** for accessibility:
   ```dart
   Semantics(label: 'Profile picture', child: AnyImageView(...))
   ```

---


## 📱 Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| 🤖 **Android** | ✅ Full | All features supported |
| 🍎 **iOS** | ✅ Full | All features supported |
| 🌐 **Web** | ✅ Full | CORS-compliant, all formats work |
| 💻 **macOS** | ✅ Full | All features supported |
| 🪟 **Windows** | ✅ Full | All features supported |
| 🐧 **Linux** | ✅ Full | All features supported |

### Web-Specific Features

**Flutter Web is fully supported!** All image types work seamlessly:

```dart
// Network images - CORS handled automatically
AnyImageView(imagePath: 'https://example.com/image.jpg')

// SVG from network - Perfect for web icons
AnyImageView(imagePath: 'https://example.com/logo.svg')

// Lottie animations - Smooth on web
AnyImageView(imagePath: 'https://example.com/animation.json')

// Asset images - Bundled with your web app
AnyImageView(imagePath: 'assets/images/banner.png')

// Base64 or Data URLs also supported
AnyImageView(imagePath: 'data:image/png;base64,...')
```

**Web Best Practices:**
- ✅ Use WebP format for better compression
- ✅ Specify dimensions for faster rendering
- ✅ Network images are automatically cached
- ✅ CORS is handled by cached_network_image package

### Testing on Web

```bash
# Run on Chrome
flutter run -d chrome

# Build for web
flutter build web

# Preview build
cd build/web && python3 -m http.server 8000
```

---

## 🔄 Migration from v1.6.0

No breaking changes! Just update your version:

```yaml
dependencies:
  any_image_view: ^1.7.0
```

---

## 🤝 Support & Contributing

- 🐛 [Report Issues](https://github.com/farhansadikgalib/any_image_view/issues)
- 💡 [Feature Requests](https://github.com/farhansadikgalib/any_image_view/discussions)
- 📧 Email: [farhansadikgalib@gmail.com](mailto:farhansadikgalib@gmail.com)

**Contributions are welcome!** Feel free to submit PRs.

---


<div align="center">

**Made with ❤️ by [Farhan Sadik Galib](https://farhansadikgalib.com)**

If this package helps you, please ⭐ it on [GitHub](https://github.com/farhansadikgalib/any_image_view) and 👍 on [Pub.dev](https://pub.dev/packages/any_image_view)

**Thank you!** 🙏

</div>
