# any_image_view example

A gallery that exercises every source `AnyImageView` supports: a disk-cached
network image with fullscreen zoom, PNG and SVG assets, a tinted network SVG,
AVIF from an asset and from the network, a Lottie animation, a circular
avatar, a custom error widget, and an `XFile` picked from the gallery.

```sh
flutter run
```

## Integration test

Drives the gallery on a real device or simulator, asserts what each tile
rendered, opens the fullscreen viewer, checks the disk cache and saves
screenshots to `screenshots/`:

```sh
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart -d <device id>
```
