
## Any Image View

A special Flutter package for displaying all kinds of images, including jpg, png, SVG, lottie, and XFile, including network images with caching. 
Customizing options for image properties and interaction makes it simple to integrate into your Flutter projects.

## Features

  - Display images from different sources: network, local files [XFile, File], Lottie, SVGs etc.
  - Customization options for image properties such as height, width, fit, border radius etc.
  - Placeholder image support for cases where the image is not available.
  - Support for onTap callback for user interaction.
  - Additional features like margin, border radius, and border styles.

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
            elevation: 5,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              print('image tapped');
            },
            errorPlaceHolder: 'assets/png/car.png',
          ));
  }
}
```

## Properties


| Property         |       Default/Type       |
|------------------|:------------------------:|
| network          | 'https://photos/25.JPG', |
| png              |  'assets/png/car.png',   |
| svg              |  'assets/svg/book.svg',  |
| lottie           | 'assets/lottie/hot.json' |
| height           |           60.0           |
| width            |           60.0           |
| elevation        |            5             |
| margin           |    EdgeInsetsGeometry    |
| padding          |    EdgeInsetsGeometry    |
| alignment        |        Alignment         |
| borderRadius     |       BorderRadius       |
| boxFit           |          BoxFit          |
| errorPlaceHolder |  'assets/png/error.png'  |

## Additional information
`any_image_view` supports -
- SVG images using `flutter_svg` package.
- Lottie animations using `lottie` package.
- Network images using `cached_network_image` package.
- Local images using `XFile` and `File` objects.
- Placeholder images using `errorPlaceHolder` parameter.
- Custom border styles using `borderRadius` parameter.
- Custom onTap callback using `onTap` parameter.
- Custom elevation using `elevation` parameter.
- Custom blend mode using `colorBlendMode` parameter.
- Custom error message using `errorText` parameter.
- Custom image properties using `height`, `width`, `fit`, `alignment`, `padding`, `margin` parameters.
- Custom image properties using `cachedNetHeight`, `cachedNetWidth` parameters.

## Screenshot

<img  src="https://github.com/farhansadikgalib/any_image_view/blob/main/raw/ss.png" height="400"></img>


