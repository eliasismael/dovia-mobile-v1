// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom functions
import '/core/network_image_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/shared_components/carousel_arrow/carousel_arrow_button.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class PhotoCategory {
  final String name;
  final List<String> imagePaths;

  const PhotoCategory({
    required this.name,
    required this.imagePaths,
  });
}

class AllPhotosWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final VoidCallback? onClose;
  final List<PhotoCategory>? categories;

  const AllPhotosWidget({
    super.key,
    this.width,
    this.height,
    this.onClose,
    this.categories,
  });

  @override
  State<AllPhotosWidget> createState() => _AllPhotosWidgetState();
}

class _AllPhotosWidgetState extends State<AllPhotosWidget> {
  static const Color primaryColor = Color(0xFF007376);
  static const Color textColor = Color(0xFF00444B);
  // Transparente: el fondo con gradiente lo pone la pantalla.
  static const Color backgroundColor = Colors.transparent;
  static const Color overlayColor = Colors.black87;

  bool _isViewerOpen = false;
  List<String> _currentViewerImages = [];
  int _currentViewerIndex = 0;
  late PageController _pageController;

  // Default room categories with sample images
  List<PhotoCategory> get _categories =>
      widget.categories ??
      const [
        PhotoCategory(
          name: 'Sala',
          imagePaths: [
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
          ],
        ),
        PhotoCategory(
          name: 'Comedor',
          imagePaths: [
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
          ],
        ),
        PhotoCategory(
          name: 'Cocina',
          imagePaths: [
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
          ],
        ),
        PhotoCategory(
          name: 'Cuarto principal',
          imagePaths: [
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
            'assets/images/c51a5fb2adf6151abf8a754f7ac53c60baebb0f8.png',
          ],
        ),
      ];

  // Scroll controllers for each category
  final Map<String, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize scroll controllers for each category
    for (final category in _categories) {
      _scrollControllers[category.name] = ScrollController();
    }
    _pageController = PageController();
  }

  @override
  void dispose() {
    // Dispose all scroll controllers
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _scrollLeft(String categoryName) {
    final controller = _scrollControllers[categoryName];
    if (controller != null && controller.hasClients) {
      final newOffset = (controller.offset - 276).clamp(
        0.0,
        controller.position.maxScrollExtent,
      );
      controller.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight(String categoryName) {
    final controller = _scrollControllers[categoryName];
    if (controller != null && controller.hasClients) {
      final newOffset = (controller.offset + 276).clamp(
        0.0,
        controller.position.maxScrollExtent,
      );
      controller.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openPhotoViewer(List<String> images, int initialIndex) {
    setState(() {
      _isViewerOpen = true;
      _currentViewerImages = images;
      _currentViewerIndex = initialIndex;
      _pageController = PageController(initialPage: initialIndex);
    });
  }

  void _closePhotoViewer() {
    setState(() {
      _isViewerOpen = false;
    });
  }

  void _navigateViewerLeft() {
    if (_currentViewerIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateViewerRight() {
    if (_currentViewerIndex < _currentViewerImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main content
        Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          decoration: const BoxDecoration(color: backgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        ..._categories
                            .map((category) => _buildCategorySection(category)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Photo viewer overlay
        if (_isViewerOpen) _buildPhotoViewerOverlay(),
      ],
    );
  }

  Widget _buildPhotoViewerOverlay() {
    return Positioned.fill(
      child: Material(
        color: overlayColor,
        child: Stack(
          children: [
            // PageView for images
            PageView.builder(
              controller: _pageController,
              itemCount: _currentViewerImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentViewerIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final imagePath = _currentViewerImages[index];
                final isNetwork = imagePath.startsWith('http') ||
                    imagePath.startsWith('https');
                return Center(
                  child: InteractiveViewer(
                    child: isNetwork
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    size: 100, color: Colors.white54),
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 100,
                                  color: Colors.white54,
                                ),
                              );
                            },
                          ),
                  ),
                );
              },
            ),

            // Top close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 20,
              child: GestureDetector(
                onTap: _closePhotoViewer,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Left navigation arrow (Web/Desktop)
            if (_currentViewerIndex > 0)
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildViewerNavigationArrow(
                    isLeft: true,
                    onTap: _navigateViewerLeft,
                    enabled: true,
                  ),
                ),
              ),

            // Right navigation arrow (Web/Desktop)
            if (_currentViewerIndex < _currentViewerImages.length - 1)
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildViewerNavigationArrow(
                    isLeft: false,
                    onTap: _navigateViewerRight,
                    enabled: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewerNavigationArrow({
    required bool isLeft,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white38,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        // Misma altura de header que el resto de las pantallas.
        top: MediaQuery.of(context).padding.top + 42,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: SizedBox(
        height: 44, // Match standard AppBar height
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left side (Back and Logo)
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F7F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_left,
                          size: 24,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/images/D-verde.svg',
                    width: 28,
                    height: 36,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.home, color: primaryColor),
                  ),
                ],
              ),
            ),
            // Center (Title)
            const Center(
              child: Text(
                'Imágenes',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(PhotoCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 29),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header row
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category name
                Text(
                  category.name,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: 0.28,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fotos grandes; las flechas van juntas debajo para no taparlas.
          SizedBox(
            height: 200,
            child: ListView.separated(
              controller: _scrollControllers[category.name],
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: category.imagePaths.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildImageThumbnail(
                  category.imagePaths[index],
                  onTap: () => _openPhotoViewer(category.imagePaths, index),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavigationArrow(
                  isLeft: true,
                  onTap: () => _scrollLeft(category.name),
                ),
                const SizedBox(width: 16),
                _buildNavigationArrow(
                  isLeft: false,
                  onTap: () => _scrollRight(category.name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(String imagePath, {VoidCallback? onTap}) {
    final isNetwork =
        imagePath.startsWith('http') || imagePath.startsWith('https');
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 260,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: isNetwork
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  width: 260,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey),
                  cacheWidth: networkImageCacheWidth(width: 260, height: 200),
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: 260,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 260,
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrow({
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    return CarouselArrowButton(isLeft: isLeft, onTap: onTap);
  }
}
