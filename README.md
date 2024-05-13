
# ANYIMAGEVIEW

A special Flutter package for displaying all kinds of images, including jpg, png, SVG, lottie, and XFile, including network images with caching. 
Customizing options for image properties and interaction make it simple to integrate into your Flutter projects.

## Features

- Display images from different sources: network, local files[XFile, File], Lottie, SVGs etc.
  - Customization options for image properties such as height, width, color, fit, border radius etc.
  - Placeholder image support for cases where the image is not available.
  - Support for onTap callback for user interaction.
  - Additional features like margin, border radius, and border styles.
  - Blend mode for applying color filters to SVG images.
  - Efficient network image loading using `CachedNetworkImage` widget.
  - Custom error widget with `errorWidget` parameter.

## Getting Started

To use this package, add `any_image_view` as a dependency in your `pubspec.yaml` file.


```yaml
dependencies:
  any_image_view: ^1.0.0
```    

``` dart
class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: AnyImageView(
            imagePath: 'https://picsum.photos/250?image=0',
            height: 200,
            width: 300,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(10),
            cachedNetHeight: 30,
            cachedNetWidth: 30,
            boxFit: BoxFit.contain,
            alignment: Alignment.center,
            onTap: () {
              print('image tapped');
            },
            errorPlaceHolder: 'assets/png/car.png',
          ));
  }
}
```

## Usage
imagePath: The path of the image to be displayed. It can be a network URL, local file path, or an asset path.
Example: 'https://picsum.photos/250?image=0', 'assets/png/car.png', 'assets/svg/book.svg','assets/lottie/heart.json'  
height: The height of the image.
Example: 200
width: The width of the image.
Example: 300
onTap: A callback function that is called when the image is tapped.
Example: () { print('image tapped'); }
padding: The padding around the image.
Example: const EdgeInsets.all(10)
margin: The margin around the image.
Example: const EdgeInsets.all(10)
alignment: The alignment of the image within its container.
Example: Alignment.center
borderRadius: The border radius of the image.
Example: BorderRadius.circular(10)
boxFit: The fit of the image within its container.
Example: BoxFit.contain
errorPlaceHolder: The placeholder image to be displayed if the main image fails to load.
Example: 'assets/png/error.png'



    

## Additional information
`any_image_view` supports -
- SVG images using `flutter_svg` package.
- Lottie animations using `lottie` package.
- Network images using `cached_network_image` package.
- Local images using `XFile` and `File` objects.
- Placeholder images using `errorPlaceHolder` parameter.
- Custom border styles using `borderRadius` parameter.
- Custom onTap callback using `onTap` parameter.
- Custom blend mode using `colorBlendMode` parameter.
- Custom error message using `errorText` parameter.
- Custom image properties using `height`, `width`, `fit`, `alignment`, `padding`, `margin` parameters.
- Custom image properties using `cachedNetHeight`, `cachedNetWidth` parameters.
  