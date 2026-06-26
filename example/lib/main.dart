import 'package:flutter/material.dart';
import 'package:any_image_view/any_image_view.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Any Image View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      ),
      home: const GalleryScreen(),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  XFile? _picked;

  Future<void> _pick() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _picked = image);
    } catch (e) {
      debugPrint('pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 280;
    const double tileWidth = 320;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: theme.colorScheme.primary,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Any Image View',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'One widget for every format',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pick,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Pick image'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: tileWidth + 32),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              if (_picked != null)
                _Tile(
                  title: 'Picked image (XFile)',
                  child: AnyImageView(
                    imagePath: _picked,
                    height: 200,
                    width: imageWidth,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              _Tile(
                title: 'Network image · tap for fullscreen',
                child: AnyImageView(
                  imagePath:
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600',
                  height: 200,
                  width: imageWidth,
                  fit: BoxFit.cover,
                  enableFullscreen: true,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              _Tile(
                title: 'PNG asset',
                child: AnyImageView(
                  imagePath: 'assets/png/flutter_banner.png',
                  height: 160,
                  width: imageWidth,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              _Tile(
                title: 'SVG asset',
                child: AnyImageView(
                  imagePath: 'assets/svg/flutter.svg',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
              _Tile(
                title: 'Network SVG · color filter',
                child: AnyImageView(
                  imagePath:
                      'https://www.svgrepo.com/show/530641/telephone.svg',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                  svgColor: Colors.indigo,
                ),
              ),
              _Tile(
                title: 'AVIF asset',
                child: AnyImageView(
                  imagePath: 'assets/avif/boat.avif',
                  height: 200,
                  width: imageWidth,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              _Tile(
                title: 'AVIF network',
                child: AnyImageView(
                  imagePath:
                      'https://raw.githubusercontent.com/link-u/avif-sample-images/master/fox.profile0.10bpc.yuv420.odd-width.odd-height.avif',
                  height: 200,
                  width: imageWidth,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              _Tile(
                title: 'Lottie animation',
                child: AnyImageView(
                  imagePath: 'assets/lottie/flutter_mobile.json',
                  height: 160,
                  width: 160,
                  fit: BoxFit.contain,
                ),
              ),
              _Tile(
                title: 'Circular avatar',
                child: AnyImageView(
                  imagePath:
                      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
                  height: 130,
                  width: 130,
                  fit: BoxFit.cover,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.indigo, width: 3),
                ),
              ),
              _Tile(
                title: 'Custom error widget',
                child: AnyImageView(
                  imagePath: 'https://invalid-url.com/image.jpg',
                  height: 150,
                  width: imageWidth,
                  borderRadius: BorderRadius.circular(12),
                  errorWidget: Container(
                    height: 150,
                    width: imageWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('Image not available')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
