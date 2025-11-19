# Changelog

All notable changes to this project will be documented in this file.

## [1.7.0] - 2025-11-19

### 🔧 Fixed
- **Package Assets**: Fixed error placeholder image (`not_found.png`) not loading from package assets by adding `package` parameter
- **SVG Network Loading**: Fixed SVG images from network URLs not loading correctly (now uses `SvgPicture.network()`)
- **Lottie Network Loading**: Fixed Lottie animations from network URLs not loading (now uses `Lottie.network()`)
- **BorderRadius Handling**: Fixed double ClipRRect application causing incorrect rendering
- **Shape Parameter**: Fixed `BoxShape.circle` conflicting with `borderRadius` application
- **Error Loop**: Fixed potential infinite loop in error fallback with placeholder error builder
- **Image Type Detection**: Fixed extension detection priority (now checks extensions before URL protocol)

### ✨ Improved
- **Error Handling**: Enhanced error fallback to show built-in `not_found.png` placeholder image
- **Code Structure**: Centralized ClipRRect application at container level for better performance
- **Type Detection**: Improved image type detection logic (extensions checked first, then URL patterns)
- **Shimmer Widget**: Simplified borderRadius calculation in shimmer loading widget
- **Performance**: Optimized widget tree with single ClipRRect wrapper

### 📦 Updated Dependencies
- `lottie`: Updated to ^3.3.2 (latest)
- `flutter_svg`: Updated to ^2.2.2 (latest)
- `cached_network_image`: Updated to ^3.4.1 (latest)
- `cross_file`: Updated to ^0.3.5+1 (latest)
- `flutter_lints`: Updated to ^6.0.0 (latest)

### 🎯 Android
- **Gradle Plugin**: Updated Android Gradle Plugin to 8.9.1 for compatibility with latest dependencies
- **Compatibility**: Improved compatibility with `androidx.activity:activity:1.11.0+`

### 📚 Documentation
- **README**: Complete rewrite with better examples, clearer API documentation, and migration guide
- **Examples**: Enhanced example app with comprehensive demos for all image types
- **Comments**: Improved inline code documentation

---

## [1.6.0] - 2024-XX-XX

### Added
- Support for more image formats: HEIC, HEIF, BMP, ICO, EXR, HDR
- Enhanced null safety by removing all force-unwrap (`!`) operators

### Fixed
- Zoom functionality incorrectly applied to error placeholders and widgets
- "Infinity or NaN toInt" error during image caching

### Improved
- Shimmer loader animation is now faster, smoother, and more visually appealing
- Image loading logic is more robust and simplified
- File structure by merging `image_loader.dart` into main file

---

## [1.5.0] - 2024-XX-XX

### Added
- Support for PNG, JPG, WebP, GIF, TIFF, RAW, SVG, Lottie, XFile, and cached network images
- Pinch-to-zoom and pan support via `InteractiveViewer`
- Customizable border radius, border, box shadow, and shape
- Premium shimmer loading effect with adjustable border radius
- Error and placeholder widgets for all image types
- Fade-in animation for image loading
- Asset, network, and local file image support
- Extension to auto-detect image type from path or URL

### Changed
- Improved shimmer effect with border radius customization
- Enhanced error handling for missing or invalid image paths

### Fixed
- Minor bug fixes and performance improvements

---

## [1.4.4] - 2024-XX-XX

### Improved
- Network images now load at full resolution for maximum quality

### Fixed
- Resolved image resolution mismatch when loading from network

### Updated
- Ensured `memCacheWidth` and `memCacheHeight` are set to `null` for original image quality

---

## [1.4.3] - 2024-XX-XX

### Added
- Zoom feature for images
- Loader (shimmer effect) displayed while images are loading

### Fixed
- Improved error handling for image loading failures

### Enhanced
- Optimized shimmer loading effect for better performance
- Refactored code for increased readability and maintainability

---

## [1.4.1] - 2024-XX-XX

### Fixed
- Added version constraints to dependencies for better compatibility

### Improved
- Enhanced pub.dev score and package stability

---

## [1.4.0] - 2024-XX-XX

### Enhanced
- Error handling and null safety for all image types
- Code quality with comprehensive analysis and linting
- XFile path handling for better compatibility
- Robust file validation and existence checks
- Unified error fallback system across all image types
- Consistent loading states for all supported image formats
- Memory management improvements for network images

---

## [1.3.1] - 2024-XX-XX

### Fixed
- Properly handle nullable `XFile.path` for compatibility with cross_file 0.3.0

### Cleanup
- Removed all analysis warnings

---

## [1.3.0] - 2024-XX-XX

### Enhanced
- Error handling for all image types (file, SVG, Lottie, asset, network)
- Safe XFile support with proper null safety and validation
- File validation with automatic existence checks
- Unified error fallback with consistent handling
- Improved loading states across all image types
- Memory management with cache hints for network images

### Improved
- Code quality by removing unused code
- Linter configuration for better compatibility

### Fixed
- Potential crashes and improved stability

---

## [1.2.0] - 2024-XX-XX

### Added
- Full XFile support with seamless image picker integration
- New `xFile` parameter in constructor
- `cross_file` dependency for XFile functionality

### Improved
- File detection for absolute paths
- Error handling with smarter fallback

---

## [1.1.2] - 2024-XX-XX

### Fixed
- Minor bug fixes for stability

---

## [1.1.1] - 2024-XX-XX

### Fixed
- Minor issues addressed

### Updated
- Dependencies for compatibility

---

## [1.1.0] - 2024-XX-XX

### Fixed
- Minor bug fixes

### UI
- Removed elevation for cleaner look

---

## [1.0.0] - 2024-XX-XX

### Stable
- Marked as stable for production use

---

## [0.1.0] - 2024-XX-XX

### Beta
- Added support for more image formats

---

## [0.0.2] - 2024-XX-XX

### Fixed
- Initial bug fixes

---

## [0.0.1] - 2024-XX-XX

### Initial
- Project started
- Basic image display support
- Project scaffolding and configuration
