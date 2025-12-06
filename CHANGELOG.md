## 1.9.0
- Fixed: Network URL image loading for URLs with file extensions (e.g., Pexels, direct image URLs ending in .jpg, .jpeg, .png).
- Fixed: Image type detection now prioritizes URL protocol check before file extension check.
- Improved: Network images from any source (Pexels, direct URLs, etc.) now properly use cached network image loading.
- Improved: URL detection now checks for `http://` and `https://` prefixes before checking file extensions.
- Enhanced: Better reliability for loading images from various image hosting services and CDNs.

---

## 1.8.0
- Enhanced: Significantly improved `cached_network_image` implementation with advanced features.
- Added: Custom HTTP headers support for authenticated network image requests (`httpHeaders` parameter).
- Added: Automatic memory cache optimization - uses `height` and `width` for cache dimensions (no separate parameters needed).
- Added: Cache duration control with `cacheMaxAge` parameter for network images.
- Added: Automatic retry logic with `maxRetryAttempts` parameter (default: 3 attempts).
- Added: Memory cache toggle with `useMemoryCache` parameter for fine-grained control.
- Added: Advanced error logging with `errorListener` for better debugging.
- Added: Improved image quality control with `FilterQuality.medium` setting.
- Improved: Error placeholder now uses built-in `Icons.broken_image` instead of asset file for better reliability.
- Improved: Border radius handling - now properly clips content and applies to decoration.
- Improved: Image type detection logic - checks file extensions before URL protocol.
- Improved: Network image performance with automatic disk and memory cache optimization based on dimensions.
- Improved: Shimmer loading animation now properly fills the container without extra centering wrapper.
- Improved: XFile handling is now more robust and reliable.
- Improved: Simplified API - memory cache dimensions automatically derived from height/width.
- Improved: Documentation with comprehensive examples for all new features.
- Updated: All dependencies to latest versions (cached_network_image: ^3.4.1, flutter_svg: ^2.2.2, lottie: ^3.3.2).
- Updated: Android Gradle Plugin to 8.7.3 (stable) with Gradle 8.12 for better compatibility.
- Updated: Example app with showcase of all advanced features including memory optimization and error handling.
- Removed: `errorPlaceHolder` parameter (replaced with built-in broken_image icon).
- Removed: `memCacheWidth` and `memCacheHeight` parameters (now automatically derived from height/width).
- Removed: Network SVG and Lottie support (kept local assets only for better stability).
- Fixed: "Infinity or NaN toInt" error when using `double.infinity` for width or height with network images.
- Fixed: Better memory management for large network images.
- Fixed: File image loading now uses direct Image.file instead of FadeInImage for better performance.

---

## 1.7.0

### Fixed
- Package Assets: Fixed error placeholder image (`not_found.png`) not loading from package assets by adding `package` parameter
- SVG Network Loading: Fixed SVG images from network URLs not loading correctly (now uses `SvgPicture.network()`)
- Lottie Network Loading: Fixed Lottie animations from network URLs not loading (now uses `Lottie.network()`)
- BorderRadius Handling: Fixed double ClipRRect application causing incorrect rendering
- Shape Parameter: Fixed `BoxShape.circle` conflicting with `borderRadius` application
- Error Loop: Fixed potential infinite loop in error fallback with placeholder error builder
- Image Type Detection: Fixed extension detection priority (now checks extensions before URL protocol)

### Improved
- Error Handling: Enhanced error fallback to show built-in `not_found.png` placeholder image
- Code Structure: Centralized ClipRRect application at container level for better performance
- Type Detection: Improved image type detection logic (extensions checked first, then URL patterns)
- Shimmer Widget: Simplified borderRadius calculation in shimmer loading widget
- Performance: Optimized widget tree with single ClipRRect wrapper

### Updated
- lottie: Updated to ^3.3.2 (latest)
- flutter_svg: Updated to ^2.2.2 (latest)
- cached_network_image: Updated to ^3.4.1 (latest)
- cross_file: Updated to ^0.3.5+1 (latest)
- flutter_lints: Updated to ^6.0.0 (latest)
- Android Gradle Plugin: Updated to 8.9.1 for compatibility with latest dependencies

### Documentation
- README: Complete rewrite with better examples, clearer API documentation, and migration guide
- Examples: Enhanced example app with comprehensive demos for all image types
- Comments: Improved inline code documentation

---

## 1.6.0
- Added: Support for more image formats, including HEIC, HEIF, BMP, ICO, EXR, HDR.
- Fixed: Zoom functionality was incorrectly applied to error placeholders and widgets.
- Fixed: An "Infinity or NaN toInt" error that occurred during image caching.
- Improved: The shimmer loader animation is now faster, smoother, and more visually appealing.
- Improved: Null safety by removing all force-unwrap (`!`) operators.
- Improved: Image loading logic is now more robust and simplified for better performance and readability.
- Improved: The file structure by merging `image_loader.dart` into the main `any_image_view.dart` file.

---

## 1.5.0
- Added: Support for PNG, JPG, WebP, GIF, TIFF, RAW, SVG, Lottie, XFile, and cached network images.
- Added: Pinch-to-zoom and pan support for images via `InteractiveViewer`.
- Added: Customizable border radius, border, box shadow, and shape for image containers.
- Added: Premium shimmer loading effect with adjustable border radius.
- Added: Error and placeholder widgets for all image types.
- Added: Fade-in animation for image loading.
- Added: Asset, network, and local file image support.
- Added: Extension to auto-detect image type from path or URL.
- Changed: Improved shimmer effect to allow border radius customization.
- Changed: Enhanced error handling for missing or invalid image paths.
- Fixed: Minor bug fixes and performance improvements.

---

## 1.4.4
- Improved: Network images now load at full resolution for maximum quality.
- Fixed: Resolved image resolution mismatch when loading from network.
- Updated: Ensured `memCacheWidth` and `memCacheHeight` are set to `null` for original image quality.
- Documentation: Enhanced comments and examples for better understanding of image loading behavior.

---

## 1.4.3
- Added: Zoom feature.
- Added: Loader (shimmer effect) displayed while images are loading.
- Fixed: Improved error handling for image loading failures.
- Enhanced: Optimized shimmer loading effect for better performance.
- Updated: Refactored code for increased readability and maintainability.
- Compatibility: Ensured support for latest dependencies and Flutter versions.
- Documentation: Updated inline comments and API docs for clarity.

---

## 1.4.1
- Fixed: Added version constraints to dependencies for better compatibility.
- Improved: Enhanced pub.dev score and package stability.
- Ready: Optimized for production release with proper dependency management.

---

## 1.4.0
- Enhanced error handling and null safety for all image types.
- Improved code quality with comprehensive analysis and linting.
- Fixed XFile path handling for better compatibility.
- Added robust file validation and existence checks.
- Unified error fallback system across all image types.
- Consistent loading states for all supported image formats.
- Memory management improvements for network images.
- Professional changelog formatting without emojis.
- Ready for production with maximum pub.dev compatibility.

---

## 1.3.1
- Fixed: Properly handle nullable `XFile.path` for compatibility with cross_file 0.3.0.
- Cleanup: No more analysis warnings; code is fully robust and clean.

---

## 1.3.0
- Enhanced error handling for all image types (file, SVG, Lottie, asset, network).
- Safe XFile support with proper null safety and validation.
- File validation: automatic file existence checks before loading.
- Unified error fallback: consistent error handling across all image types.
- Improved loading states: consistent loading widgets for all image types.
- Memory management: added memory cache hints for network images.
- Code quality: removed unused code and improved overall robustness.
- Linter fixes: updated analysis configuration for better compatibility.
- Bug fixes: fixed potential crashes and improved stability.
- Documentation: enhanced code comments and error handling examples.

---

## 1.2.0
- Full XFile support: seamless integration with image picker.
- New: `xFile` parameter added to `AnyImageView` constructor.
- Dependency: Added `cross_file` for XFile functionality.
- Detection: Improved file detection for absolute paths.
- Error handling: smarter fallback to error placeholder for file-based images.
- Safety: Assertion prevents using both `imagePath` and `xFile` together.
- Docs: Updated with XFile usage examples.

---

## 1.1.2
- Bug fixes: Minor fixes for stability.
- Docs: Small documentation improvements.

---

## 1.1.1
- Bug fixes: Addressed minor issues.
- Dependencies: Updated for compatibility.

---

## 1.1.0
- First launch.
- Fixes: Minor bug fixes.
- UI: Elevation removed for cleaner look.
- Docs: Updated documentation.
- Dependencies: Fixed and updated.

---

## 1.0.0
- Stable: Marked as stable for production use.
- Fixes: General improvements.

---

## 0.1.0
- Beta: Added more image formats support.
- Fixes: Minor bug fixes.

---

## 0.0.2
- Bug fixes: Addressed initial issues.

---

## 0.0.1
- Prototype: Initial widget implementation.
- Features: Basic image display support.
- Setup: Project scaffolding and configuration.