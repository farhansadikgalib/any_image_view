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