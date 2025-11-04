import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/product_model.dart';
import 'product_details_screen.dart';
import 'settings_screen.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:material_new_shapes/material_new_shapes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Add state for border radius animation
  double _cameraButtonRadius = 50;
  double _galleryButtonRadius = 50;

  Future<void> _captureImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isLoading = true);

      // Upload and analyze
      final ProductResult result = await _apiService.analyzeProduct(File(image.path));

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Navigate to results
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(result: result),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _isLoading
            ? _buildLoadingState(colorScheme, textTheme)
            : _buildMainContent(colorScheme, textTheme),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: ExpressiveLoadingIndicator(
        color: colorScheme.primary,
        constraints: BoxConstraints(
          minWidth: 64.0,
          minHeight: 64.0,
          maxWidth: 64.0,
          maxHeight: 64.0,
        ),
        polygons: [
          MaterialShapes.softBurst,
          MaterialShapes.pentagon,
          MaterialShapes.pill,
        ],
        semanticsLabel: 'Loading',
        semanticsValue: 'In progress',
      ),
    );
  }

  Widget _buildMainContent(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        // App Bar
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 0.w),
                  child: Text(
                    'Revela',
                    style: textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 38.sp,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  tooltip: 'Settings',
                ),
              ],
            ),
          ),
        ),

        // Main Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 1),
                
                // Centered QR Icon Card
                _buildHeroSection(colorScheme, textTheme),
                
                SizedBox(height: 32.h),
                
                // Title and Description below the card
                Text(
                  'Scan Any Product',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Take a photo or upload an image to instantly identify products and analyze ingredients with AI',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                const Spacer(flex: 2),
                
                // Action Buttons
                _buildActionButtons(colorScheme, textTheme),
                
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          height: 410.h,
          child: Icon(
            Icons.qr_code_scanner_rounded,
            size: 200.sp,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _cameraButtonRadius = 12);
            },
            onTapUp: (_) {
              setState(() => _cameraButtonRadius = 50);
              _captureImage(ImageSource.camera);
            },
            onTapCancel: () {
              setState(() => _cameraButtonRadius = 50);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 0),
              curve: Curves.linear,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(_cameraButtonRadius),
              ),
              child: IconButton(
                onPressed: null, // Disabled to use GestureDetector
                icon: Icon(Icons.camera_alt_rounded, size: 32.sp, color: colorScheme.primary),
                tooltip: 'Take Photo',
                iconSize: 32.sp,
                padding: EdgeInsets.zero,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                disabledColor: colorScheme.primary,
                constraints: BoxConstraints(
                  minWidth: 64.w,
                  minHeight: 64.h,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 24.w),
        Expanded(
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _galleryButtonRadius = 12);
            },
            onTapUp: (_) {
              setState(() => _galleryButtonRadius = 50);
              _captureImage(ImageSource.gallery);
            },
            onTapCancel: () {
              setState(() => _galleryButtonRadius = 50);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 0),
              curve: Curves.linear,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(_galleryButtonRadius),
              ),
              child: IconButton(
                onPressed: null, // Disabled to use GestureDetector
                icon: Icon(Icons.photo_library_rounded, size: 32.sp, color: colorScheme.primary),
                tooltip: 'Choose from Gallery',
                iconSize: 32.sp,
                padding: EdgeInsets.zero,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                disabledColor: colorScheme.primary,
                constraints: BoxConstraints(
                  minWidth: 64.w,
                  minHeight: 64.h,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
