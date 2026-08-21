package com.farhansadikgalib.any_image_view

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Android side of `any_image_view`.
 *
 * This package is Dart-only at runtime -- all image decoding happens in Dart or
 * inside the plugins it depends on. The Android module exists so the package is
 * registered as a Flutter plugin, which lets its `android/build.gradle` apply
 * the build-time fixes documented there (NDK version tracking and the
 * `flutter_avif_android` duplicate-class workaround) without the app author
 * having to edit any Gradle file by hand.
 */
class AnyImageViewPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // No platform channels: nothing to wire up.
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // No platform channels: nothing to tear down.
    }
}
