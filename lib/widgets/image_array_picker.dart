import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class ImageArrayPicker extends StatelessWidget {
  final RxList<String> selectedImages;
  final VoidCallback? onAddImages;
  final VoidCallback? onAddSingleImage;
  final Function(int)? onRemoveImage;
  final VoidCallback? onClearAll;
  final bool isLoading;
  final int maxImages;
  final double imageSize;
  final bool showAddButton;

  const ImageArrayPicker({
    Key? key,
    required this.selectedImages,
    this.onAddImages,
    this.onAddSingleImage,
    this.onRemoveImage,
    this.onClearAll,
    this.isLoading = false,
    this.maxImages = 10,
    this.imageSize = 80,
    this.showAddButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Student Images',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            if (showAddButton && selectedImages.isNotEmpty)
              TextButton.icon(
                onPressed: onClearAll,
                icon: Icon(Icons.clear_all, size: 16.sp),
                label: Text('Clear All', style: TextStyle(fontSize: 12.sp)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
        SizedBox(height: 1.h),

        // Image grid
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Images display area
              Container(
                constraints: BoxConstraints(
                  minHeight: imageSize + 20,
                  maxHeight: (imageSize + 20) * 3, // Max 3 rows
                ),
                child: selectedImages.isEmpty
                    ? _buildEmptyState()
                    : _buildImageGrid(),
              ),

              // Add buttons
              if (showAddButton && selectedImages.length < maxImages)
                _buildAddButtons(),
            ],
          ),
        ),

        // Image count and info
        if (selectedImages.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Row(
              children: [
                Icon(Icons.image, size: 14.sp, color: Colors.grey[600]),
                SizedBox(width: 0.5.w),
                Text(
                  '${selectedImages.length} image${selectedImages.length == 1 ? '' : 's'} selected',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                if (maxImages > 0) ...[
                  SizedBox(width: 1.w),
                  Text(
                    '(Max: $maxImages)',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    ));
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(3.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 8.h,
            color: Colors.grey[400],
          ),
          SizedBox(height: 1.h),
          Text(
            'No images selected',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Add student photos, documents, or certificates',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(2.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 1,
      ),
      itemCount: selectedImages.length,
      itemBuilder: (context, index) {
        return _buildImageItem(index);
      },
    );
  }

  Widget _buildImageItem(int index) {
    final imagePath = selectedImages[index];
    
    return Stack(
      children: [
        // Image container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: _buildImageWidget(imagePath),
          ),
        ),

        // Remove button
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: () => onRemoveImage?.call(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                size: 12.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Image number badge
        Positioned(
          bottom: -5,
          left: -5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imagePath) {
    // Check if it's a file path or network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // Local file
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 4.h,
            color: Colors.grey[400],
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButtons() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Add multiple images button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onAddImages,
              icon: isLoading
                  ? SizedBox(
                      width: 14.sp,
                      height: 14.sp,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.add_photo_alternate, size: 16.sp),
              label: Text(
                'Add Multiple',
                style: TextStyle(fontSize: 12.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          // Add single image button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onAddSingleImage,
              icon: isLoading
                  ? SizedBox(
                      width: 14.sp,
                      height: 14.sp,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.add_a_photo, size: 16.sp),
              label: Text(
                'Add Single',
                style: TextStyle(fontSize: 12.sp),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
