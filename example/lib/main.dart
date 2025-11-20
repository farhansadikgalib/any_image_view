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
      title: 'Any Image View Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ImageGalleryScreen(),
    );
  }
}

class ImageGalleryScreen extends StatelessWidget {
  const ImageGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Any Image View - Advanced Features'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Network Image with Caching',
            AnyImageView(
              imagePath: 'https://picsum.photos/400/300',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Memory-Optimized Network Image',
            AnyImageView(
              imagePath: 'https://picsum.photos/800/600',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(12),
              memCacheWidth: 800,
              memCacheHeight: 600,
              useMemoryCache: true,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Local Asset Image',
            AnyImageView(
              imagePath: 'assets/png/flutter_banner.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'SVG Image',
            AnyImageView(
              imagePath: 'assets/svg/flutter.svg',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Lottie Animation',
            AnyImageView(
              imagePath: 'assets/lottie/flutter_mobile.json',
              height: 150,
              width: 150,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Circular Avatar with Zoom',
            AnyImageView(
              imagePath: 'https://picsum.photos/200',
              height: 120,
              width: 120,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
              enableZoom: true,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Image with Custom Error Handler',
            AnyImageView(
              imagePath: 'https://invalid-url.com/image.jpg',
              height: 200,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
              errorWidget: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 8),
                    Text(
                      'Image not available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Card Style Image',
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnyImageView(
                    imagePath: 'https://picsum.photos/400/250',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    fadeDuration: const Duration(milliseconds: 600),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beautiful Card Image',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'With smooth fade-in animation',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
