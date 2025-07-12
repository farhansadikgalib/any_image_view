import 'package:flutter/material.dart';
import 'package:any_image_view/any_image_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: AnyImageView(
            imagePath: 'assets/png/flutter_banner.png',
            height: 100,
            width: 300,
            errorPlaceHolder: 'assets/png/error.png',
            placeholderWidget: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
