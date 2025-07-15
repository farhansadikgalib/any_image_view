## 1.5.0 – Major Release
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

## 1.4.4 – Patch Release
- Improved: Network images now load at full resolution for maximum quality.
- Fixed: Resolved image resolution mismatch when loading from network.
- Updated: Ensured `memCacheWidth` and `memCacheHeight` are set to `null` for original image quality.
- Documentation: Enhanced comments and examples for better understanding of image loading behavior.

---

## 1.4.3 – Patch Release
- Added: Zoom feature.
- Added: Loader (shimmer effect) displayed while images are loading.
- Fixed: Improved error handling for image loading failures.
- Enhanced: Optimized shimmer loading effect for better performance.
- Updated: Refactored code for increased readability and maintainability.
- Compatibility: Ensured support for latest dependencies and Flutter versions.
- Documentation: Updated inline comments and API docs for clarity.

---

## 1.4.1 – Patch Release
- Fixed: Added version constraints to dependencies for better compatibility.
- Improved: Enhanced pub.dev score and package stability.
- Ready: Optimized for production release with proper dependency management.

---

## 1.4.0 – Minor Release
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

## 1.3.1 – Patch Release
- Fixed: Properly handle nullable `XFile.path` for compatibility with cross_file 0.3.0.
- Cleanup: No more analysis warnings; code is fully robust and clean.

---

## 1.3.0 – Robust & Reliable Release
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

## 1.2.0 – Big Update
- Full XFile support: seamless integration with image picker.
- New: `xFile` parameter added to `AnyImageView` constructor.
- Dependency: Added `cross_file` for XFile functionality.
- Detection: Improved file detection for absolute paths.
- Error handling: smarter fallback to error placeholder for file-based images.
- Safety: Assertion prevents using both `imagePath` and `xFile` together.
- Docs: Updated with XFile usage examples.

---

## 1.1.2 – Patch Release
- Bug fixes: Minor fixes for stability.
- Docs: Small documentation improvements.

---

## 1.1.1 – Patch Release
- Bug fixes: Addressed minor issues.
- Dependencies: Updated for compatibility.

---

## 1.1.0 – Initial Release
- First launch.
- Fixes: Minor bug fixes.
- UI: Elevation removed for cleaner look.
- Docs: Updated documentation.
- Dependencies: Fixed and updated.

---

## 1.0.0 – Stable Release
- Stable: Marked as stable for production use.
- Fixes: General improvements.

---

## 0.1.0 – Beta Release
- Beta: Added more image formats support.
- Fixes: Minor bug fixes.

---

## 0.0.2 – Early Patch
- Bug fixes: Addressed initial issues.

---

## 0.0.1 – Project Started
- Prototype: Initial widget implementation.
- Features: Basic image display support.
- Setup: Project scaffolding and configuration.