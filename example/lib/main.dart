import 'package:any_image_view/any_image_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Any Image View Example',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue),
      body: ListView(
        children: <Widget>[
          //Local Asset Image

          //Lottie Animation
          AnyImageView(
            imagePath: "assets/lottie/flutter_mobile.json",
            height: 200,
            width: 300,
          ),
          //Lottie Animation

          AnyImageView(
            padding: const EdgeInsets.all(30),
            imagePath: "assets/png/flutter_banner.png",
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 100,
            height: 300,
            borderRadius: BorderRadius.circular(30),
            boxFit: BoxFit.cover,
            onTap: () {
              print('image tapped');
            },
          ),
          //Local Asset Image

          //SVG Image

          AnyImageView(
            imagePath: 'assets/svg/flutter.svg',
            height: 100,
            width: 100,
            onTap: () {
              print('image tapped');
            },
            errorPlaceHolder: 'assets/png/not_found.png',
          ),

          //SVG Image

          //Network Image with CachedNetworkImage
          AnyImageView(
            padding: const EdgeInsets.only(top: 15),
            imagePath:
                'https://assets-global.website-files.com/6270e8022b05abb840d27d6f/6308d1ab615e60c9047c9d06_AppDev_Flutter-tools.png',
            height: 150,
            width: 300,
            borderRadius: BorderRadius.circular(15),
            boxFit: BoxFit.cover,
            alignment: Alignment.center,
            onTap: () {
              print('image tapped');
            },
            errorPlaceHolder: 'assets/png/not_found.png',
          ),

          //Network Image with CachedNetworkImage
        ],
      ),
    );
  }
}
