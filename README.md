# 🖼️ Any Image View

[![Pub Version](https://img.shields.io/pub/v/any_image_view.svg?style=flat-square)](https://pub.dev/packages/any_image_view)
[![Pub Points](https://img.shields.io/pub/points/any_image_view?style=flat-square)](https://pub.dev/packages/any_image_view/score)
[![Pub Likes](https://img.shields.io/pub/likes/any_image_view?style=flat-square)](https://pub.dev/packages/any_image_view)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.4.3+-blue.svg)](https://flutter.dev)

<div align="center">

</div>
<p align="center">
  <img src="https://raw.githubusercontent.com/farhansadikgalib/any_image_view/main/raw/banner.png" 
  alt="Any Image View Demo"/>
</p>

## 🎯 **Why Choose Any Image View?**

Tired of juggling multiple image widgets? Say goodbye to complex image handling! This package gives you **one widget that handles everything**:

- ✅ **Network images** with automatic caching and fade animations
- ✅ **Local files** from your device (XFile & String paths)
- ✅ **SVG graphics** with perfect scaling and custom placeholders
- ✅ **Lottie animations** for engaging content (JSON/ZIP)
- ✅ **All image formats** (PNG, JPG, JPEG, WebP, GIF, TIFF, RAW)
- ✅ **Asset images** from your app bundle
- ✅ **Advanced error handling** with custom widgets
- ✅ **Smooth animations** with configurable fade duration
- 🛡️ **Robust & Reliable** - Comprehensive error handling and validation

**No more headaches, just beautiful images!** ✨

---

## ⚡ **Quick Start (30 seconds)**

### 1️⃣ **Add to pubspec.yaml**
```yaml
dependencies:
  any_image_view: ^1.4.0
```

### 2️⃣ **Run this command**
```bash
flutter pub get
```

### 3️⃣ **Copy & Paste this code**
```dart
import 'package:any_image_view/any_image_view.dart';

// Replace your existing Image widgets with this:
AnyImageView(
imagePath: 'https://picsum.photos/300/200',
height: 200,
width: 300,
borderRadius: BorderRadius.circular(12),
onTap: () => print('Image tapped!'),
)
```

**That's it! You're ready to go! 🎉**

---

## 🚀 **Popular Use Cases**

### 📱 **Profile Pictures**
```dart
AnyImageView(
imagePath: user.profileImageUrl,
height: 80,
width: 80,
shape: BoxShape.circle,
border: Border.all(color: Colors.blue, width: 2),
onTap: () => _showProfileDetails(),
)
```

### 🖼️ **Gallery Images with Custom Loading**
```dart
AnyImageView(
imagePath: galleryItem.url,
height: 200,
width: double.infinity,
boxFit: BoxFit.cover,
borderRadius: BorderRadius.circular(8),
placeholderWidget: Center(
child: CircularProgressIndicator(),
),
errorWidget: Center(
child: Icon(Icons.error, color: Colors.red),
),
)
```

### 🎨 **SVG Icons & Logos**
```dart
AnyImageView(
imagePath: 'assets/icons/app_logo.svg',
height: 40,
width: 40,
fit: BoxFit.contain,
placeholderWidget: SizedBox(
height: 40,
width: 40,
child: LinearProgressIndicator(),
),
)
```

### 🎬 **Lottie Animations**
```dart
AnyImageView(
imagePath: 'assets/animations/loading.json',
height: 100,
width: 100,
fit: BoxFit.contain,
)
```

### 📸 **XFile from Image Picker**
```dart
AnyImageView(
imagePath: pickedFile, // XFile object
height: 250,
width: 250,
borderRadius: BorderRadius.circular(15),
fadeDuration: Duration(milliseconds: 300),
)
```

---

## 📸 **Complete Image Picker Integration**

**Want to let users pick images? Here's the complete solution:**

```dart
import 'package:image_picker/image_picker.dart';
import 'package:any_image_view/any_image_view.dart';

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  XFile? selectedImage;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickImage,
            child: Text('📷 Pick Image'),
          ),
          SizedBox(height: 20),
          if (selectedImage != null)
            AnyImageView(
              imagePath: selectedImage,
              height: 250,
              width: 250,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
              fadeDuration: Duration(milliseconds: 500),
              onTap: () => print('Selected image tapped!'),
            ),
        ],
      ),
    );
  }
}
```

---

## 🎨 **Advanced Styling Examples**

### **Card-Style Image with Custom Loading**
```dart
AnyImageView(
imagePath: 'https://example.com/image.jpg',
height: 200,
width: double.infinity,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.1),
blurRadius: 8,
offset: Offset(0, 4),
),
],
margin: EdgeInsets.all(16),
placeholderWidget: Container(
height: 200,
width: double.infinity,
decoration: BoxDecoration(
color: Colors.grey[200],
borderRadius: BorderRadius.circular(16),
),
child: Center(
child: CircularProgressIndicator(),
),
),
onTap: () => _openImageDetails(),
)
```

### **Circular Avatar with Error Handling**
```dart
AnyImageView(
imagePath: user.avatarUrl,
height: 60,
width: 60,
shape: BoxShape.circle,
border: Border.all(color: Colors.white, width: 3),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.2),
blurRadius: 6,
offset: Offset(0, 2),
),
],
errorWidget: Container(
height: 60,
width: 60,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: Colors.grey[300],
),
child: Icon(Icons.person, color: Colors.grey[600]),
),
)
```

### **Hero Image with Gradient Overlay**
```dart
Stack(
children: [
AnyImageView(
imagePath: 'assets/images/hero.jpg',
height: 300,
width: double.infinity,
fit: BoxFit.cover,
fadeDuration: Duration(milliseconds: 800),
),
Positioned(
bottom: 0,
left: 0,
right: 0,
child: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
),
),
padding: EdgeInsets.all(16),
child: Text(
'Beautiful Hero Image',
style: TextStyle(color: Colors.white, fontSize: 18),
),
),
),
],
)
```

---

## 🔧 **Complete API Reference**

### **Constructor Parameters**

| Parameter | Type | Default | Description |
|-----------|------|---------|--------------|
| `imagePath` | `Object?` | `null` | String path/URL or XFile object |
| `height` | `double?` | `null` | Image container height |
| `width` | `double?` | `null` | Image container width |
| `fit` | `BoxFit?` | `BoxFit.cover` | How image fits in container |
| `alignment` | `Alignment?` | `null` | Image alignment within container |
| `borderRadius` | `BorderRadius?` | `null` | Rounded corners |
| `shape` | `BoxShape` | `BoxShape.rectangle` | Rectangle or circle |
| `border` | `BoxBorder?` | `null` | Border styling |
| `boxShadow` | `List<BoxShadow>?` | `null` | Shadow effects |
| `margin` | `EdgeInsetsGeometry?` | `null` | Outer spacing |
| `padding` | `EdgeInsetsGeometry?` | `null` | Inner spacing |
| `onTap` | `VoidCallback?` | `null` | Tap callback function |
| `errorPlaceHolder` | `String?` | `'assets/images/not_found.png'` | Fallback image path |
| `placeholderWidget` | `Widget?` | `null` | Custom loading widget |
| `errorWidget` | `Widget?` | `null` | Custom error widget |
| `fadeDuration` | `Duration` | `400ms` | Fade animation duration |

### **Supported Image Formats**

| Format | Extension | Description | Example |
|--------|-----------|-------------|---------|
| **PNG** | `.png` | Portable Network Graphics | `'assets/images/logo.png'` |
| **JPG/JPEG** | `.jpg`, `.jpeg` | Joint Photographic Experts Group | `'assets/photos/image.jpg'` |
| **WebP** | `.webp` | Web Picture format | `'assets/images/photo.webp'` |
| **GIF** | `.gif` | Graphics Interchange Format | `'assets/animations/loading.gif'` |
| **TIFF** | `.tiff` | Tagged Image File Format | `'assets/images/document.tiff'` |
| **RAW** | `.raw` | Raw image format | `'assets/images/photo.raw'` |
| **SVG** | `.svg` | Scalable Vector Graphics | `'assets/icons/icon.svg'` |
| **Lottie** | `.json`, `.zip` | Lottie animations | `'assets/animations/animation.json'` |
| **Network** | `http://`, `https://` | HTTP/HTTPS URLs | `'https://example.com/image.jpg'` |
| **XFile** | `XFile object` | Cross-platform file objects | `pickedFile` |

---

## 🛡️ **Advanced Error Handling**

### **Custom Error Widget**
```dart
AnyImageView(
imagePath: 'https://broken-link.com/image.jpg',
height: 200,
width: 200,
errorWidget: Container(
height: 200,
width: 200,
decoration: BoxDecoration(
color: Colors.grey[200],
borderRadius: BorderRadius.circular(8),
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.error_outline, size: 48, color: Colors.red),
SizedBox(height: 8),
Text('Image not available', style: TextStyle(color: Colors.grey[600])),
],
),
),
)
```

### **Custom Loading Widget**
```dart
AnyImageView(
imagePath: 'https://slow-server.com/large-image.jpg',
height: 300,
width: 300,
placeholderWidget: Container(
height: 300,
width: 300,
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [Colors.grey[300]!, Colors.grey[200]!],
),
),
child: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
CircularProgressIndicator(),
SizedBox(height: 8),
Text('Loading...', style: TextStyle(color: Colors.grey[600])),
],
),
),
),
)
```

### **Smooth Fade Animations**
```dart
AnyImageView(
imagePath: 'https://example.com/image.jpg',
height: 200,
width: 200,
fadeDuration: Duration(milliseconds: 800), // Custom fade duration
onTap: () => print('Image with smooth fade animation'),
)
```

---

## 📱 **Platform Support**

| Platform | Status | Features |
|----------|--------|----------|
| **Android** | ✅ Perfect | All formats & features supported |
| **iOS** | ✅ Perfect | All formats & features supported |
| **Web** | ✅ Perfect | All formats & features supported |
| **macOS** | ✅ Perfect | All formats & features supported |
| **Windows** | ✅ Perfect | All formats & features supported |
| **Linux** | ✅ Perfect | All formats & features supported |

---

## 🔄 **Migration Guide**

### **Before (Multiple widgets needed):**
```dart
// Network images
CachedNetworkImage(
imageUrl: imageUrl,
height: 200,
width: 200,
placeholder: (context, url) => CircularProgressIndicator(),
errorWidget: (context, url, error) => Icon(Icons.error),
)

// Local files
Image.file(
File(filePath),
height: 200,
width: 200,
errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
)

// SVG files
SvgPicture.asset(
'assets/icon.svg',
height: 200,
width: 200,
placeholderBuilder: (context) => CircularProgressIndicator(),
)
```

### **After (One widget for all):**
```dart
// All image types with one widget!
AnyImageView(
imagePath: imageUrl, // or filePath, or asset path, or XFile
height: 200,
width: 200,
placeholderWidget: CircularProgressIndicator(),
errorWidget: Icon(Icons.error),
)
```

---

## 🎯 **Pro Tips & Best Practices**

### **1. Performance Optimization**
```dart
// Always specify dimensions for better performance
AnyImageView(
imagePath: imageUrl,
height: 200,
width: 200, // Specific dimensions improve performance
fit: BoxFit.cover,
)
```

### **2. Memory Management**
```dart
// Use appropriate placeholder sizes for large galleries
AnyImageView(
imagePath: imageUrl,
placeholderWidget: SizedBox(
height: 30,
width: 30,
child: CircularProgressIndicator(strokeWidth: 2),
),
)
```

### **3. Accessibility**
```dart
// Add semantic labels for screen readers
AnyImageView(
imagePath: imageUrl,
onTap: () => _handleTap(),
).semanticsLabel('User profile picture'),
)
```

### **4. Custom Animations**
```dart
// Use longer fade duration for hero images
AnyImageView(
imagePath: heroImageUrl,
fadeDuration: Duration(milliseconds: 1000), // Smooth transition
)
```

### **5. Error Recovery**
```dart
// Provide fallback images for better UX
AnyImageView(
imagePath: userAvatarUrl,
errorPlaceHolder: 'assets/images/default_avatar.png',
errorWidget: Container(
decoration: BoxDecoration(
shape: BoxShape.circle,
color: Colors.grey[300],
),
child: Icon(Icons.person),
),
)
```

---

## 🤝 **Need Help?**

- 🐛 **Found a bug?** [Report it here](https://github.com/farhansadikgalib/any_image_view/issues)
- 💡 **Have a feature request?** [Let me know](https://github.com/farhansadikgalib/any_image_view/issues)
- 📧 **Direct contact:** [farhansadikgalib@gmail.com](mailto:farhansadikgalib@gmail.com)
---

<div align="center">
  <h3>Made with ❤️ by <a href="https://farhansadikgalib.com">Farhan Sadik Galib</a></h3>
  <p>If this package helps you, please consider giving it a ⭐ on <a href="https://pub.dev/packages/any_image_view">Pub.dev</a></p>
</div>
