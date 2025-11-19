import 'package:flutter/material.dart';
import 'package:any_image_view/any_image_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Any Image View Demo'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Valid network image
              const Text(
                'Valid Network Image:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const AnyImageView(
                imagePath: 'https://picsum.photos/400/310',
                height: 200,
                width: double.infinity,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(height: 24),

              // Invalid network image (will show not_found.png)
              const Text(
                'Invalid Network Image (shows error placeholder):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const AnyImageView(
                imagePath:
                    'https://invalid-url-that-does-not-exist.com/image.jpg',
                height: 200,
                width: double.infinity,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(height: 24),

              // Local asset image
              const Text(
                'Local Asset Image:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const AnyImageView(
                imagePath: 'assets/png/flutter_banner.png',
                height: 200,
                width: double.infinity,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(height: 24),

              // SVG image
              const Text(
                'SVG Image:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const AnyImageView(
                imagePath: 'assets/svg/flutter.svg',
                height: 150,
                width: double.infinity,
              ),
              const SizedBox(height: 24),

              // Lottie animation
              const Text(
                'Lottie Animation:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const AnyImageView(
                imagePath: 'assets/lottie/flutter_mobile.json',
                height: 200,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
