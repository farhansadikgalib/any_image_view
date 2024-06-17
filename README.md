## Any Image View

A special Flutter package for displaying all kinds of images, including jpg, png, SVG, lottie, and
XFile, including network images with caching.
Customizing options for image properties and interaction makes it simple to integrate into your
Flutter projects.

## Features

- Display images from different sources: network, local files [XFile, File], Lottie, SVGs etc.
- Customization options for image properties such as height, width, fit, border radius etc.
- Placeholder image support for cases where the image is not available.
- Support for onTap callback for user interaction.
- Additional features like margin, border radius, and border styles.

## Preview

<img src="https://raw.githubusercontent.com/farhansadikgalib/any_image_view/main/raw/gif.gif" width="300"/>

## Getting Started

Add the latest version of package to your `pubspec.yaml` (and run `flutter pub get`):

```yaml
dependencies:
  any_image_view: ^1.0.6
```

Import the package and use it in your Flutter App.

```import
import 'package:any_image_view/any_image_view.dart';
```

<hr>

## Example usage

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
            onTap: () {
              print('image tapped');
            },
            errorPlaceHolder: 'assets/png/not_found.png',
          ));
  }
}
```

## Properties

| Property                   |       Default/Type       |
|----------------------------|:------------------------:|
| network                    | 'https://photos/25.JPG'  |
| png                        |   'assets/png/car.png'   |
| svg                        |  'assets/svg/book.svg'   |
| lottie                     | 'assets/lottie/hot.json' |
| height                     |           50.0           |
| width                      |           50.0           |
| margin                     |    EdgeInsetsGeometry    |
| padding                    |    EdgeInsetsGeometry    |
| alignment                  |        Alignment         |
| borderRadius               |       BorderRadius       |
| boxFit                     |          BoxFit          |
| alignment                  |        Alignment         |
| border                     |          Border          |
| borderRadius               |       BorderRadius       |
| onTap                      |         Function         |
| errorPlaceHolder           |  'assets/png/error.png'  |
| cachedNetPlaceholderHeight |            25            |
| cachedNetPlaceholderWidth  |            25            |

Use any of the available properties to customize your image as you see fit.

``` dart
          AnyImageView(
            imagePath:
                'https://assets-global.website-files.com/6270e8022b05abb840d27d6f/6308d1ab615e60c9047c9d06_AppDev_Flutter-tools.png',
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.all(30),
            width: 100,
            height: 300,
            alignment: Alignment.centerLeft,
            shape: BoxShape.rectangle,
            errorPlaceHolder: 'assets/png/not_found.png',
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade50,
                blurRadius: 10,
                spreadRadius: 5,
                offset: const Offset(0, 0),
              )
            ],
            cachedNetPlaceholderHeight: 100,
            cachedNetPlaceholderWidth: 100,
            borderRadius: BorderRadius.circular(30),
            boxFit: BoxFit.cover,
            border: Border.all(color: Colors.blue, width: 2),
            onTap: () {
              print('image tapped');
            },
          ),

```

## Additional information

`any_image_view` supports -

- SVG images using `flutter_svg` package.
- Lottie animations using `lottie` package.
- Network images using `cached_network_image` package.
- Local images using `XFile` and `File` objects.
- Placeholder images using `errorPlaceHolder` parameter.
- Custom border styles using `borderRadius` parameter.
- Custom onTap callback using `onTap` parameter.
- Custom image properties using `height`, `width`, `fit`, `alignment`, `padding`, `margin`
  parameters.
- Custom image properties using `cachedNetPlaceholderHeight`, `cachedNetPlaceholderWidth`
  parameters.

[//]: # (## Screenshot)

[//]: # ()
[//]: # (<table align="left" style="margin: 0px auto;">)

[//]: # (  <tr>)

[//]: # (    <td>)

[//]: # (        <div style="text-align: center;">)

[//]: # (            <img src="https://raw.githubusercontent.com/farhansadikgalib/any_image_view/main/raw/gif.gif" height="250px"/>)

[//]: # (        </div>)

[//]: # (    </td>)

[//]: # (    <td>)

[//]: # (        <div style="text-align: center;">)

[//]: # (            <img src="https://raw.githubusercontent.com/farhansadikgalib/any_image_view/main/raw/ss.png" height="250px"/>)

[//]: # (        </div>)

[//]: # (    </td>)

[//]: # ()
[//]: # (</table>)


