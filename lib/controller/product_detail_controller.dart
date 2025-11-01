import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product_model.dart';
import '../../repository/product_repository.dart';
import '../../widgets/snackbar.dart' as CustomSnackBar;

// Extension for firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class ProductDetailController extends GetxController {
  final String productId;
  final ProductModel? product;

  ProductDetailController({required this.productId, this.product});

  // Observable variables
  var isLoading = true.obs;
  var productData = Rxn<ProductModel>();
  var currentImageIndex = 0.obs;
  var selectedVariant = Rxn<ProductVariant>();
  var quantity = 1.obs;
  var relatedProducts = <ProductModel>[].obs;
  var fadeAnimation = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProductDetails();
  }

  Future<void> loadProductDetails() async {
    try {
      isLoading.value = true;

      ProductModel? fetchedProduct;

      // If product is already passed, use it directly without API call
      if (product != null) {
        print('Using passed product: ${product!.id}');
        fetchedProduct = product;
      } else {
        // Only fetch from API if no product is passed
        print('No product passed, fetching from API: $productId');
        fetchedProduct = await ProductRepository.getProduct(
          productId: productId,
          context: Get.context,
        );
      }

      if (fetchedProduct != null) {
        productData.value = fetchedProduct;
        // Set first variant as default if available
        if (fetchedProduct.variants.isNotEmpty) {
          selectedVariant.value = fetchedProduct.variants.first;
        }

        // Load related products only if we have a valid product
        await _loadRelatedProducts();
      } else {
        print('No product available - neither passed nor fetched from API');
        CustomSnackBar.SnackBar.error(message: 'Product not found');
        Get.back();
      }
    } catch (e) {
      print('Error loading product details: $e');
      // If we have a passed product, use it as fallback even if there's an error
      if (product != null) {
        print('Using passed product as fallback due to error');
        productData.value = product;
        if (product!.variants.isNotEmpty) {
          selectedVariant.value = product!.variants.first;
        }
      } else {
        CustomSnackBar.SnackBar.error(
          message: 'Failed to load product details: ${e.toString()}',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadRelatedProducts() async {
    try {
      // Only load related products if we have a valid product
      if (productData.value != null) {
        final related = await ProductRepository.getRelatedProducts(
          productId: productId,
          limit: 5,
          context: Get.context,
        );
        relatedProducts.value = related;
      }
    } catch (e) {
      // Silently fail for related products
      print('Failed to load related products: $e');
    }
  }

  void selectVariant(ProductVariant variant) {
    // If we already have a selected variant, try to find a combination
    if (selectedVariant.value != null) {
      final currentColor = selectedVariant.value!.color;
      final currentSize = selectedVariant.value!.size;
      final newColor = variant.color;
      final newSize = variant.size;

      // If selecting a color (newColor != null and newSize == null)
      if (newColor != null && newSize == null) {
        // Try to keep current size with new color
        if (currentSize != null) {
          final colorSizeMatch = productData.value!.variants.firstWhereOrNull(
            (v) => v.color == newColor && v.size == currentSize,
          );
          if (colorSizeMatch != null) {
            selectedVariant.value = colorSizeMatch;
            return;
          }
        }
        // If can't keep current size, select first available size for this color
        final firstSizeForColor = productData.value!.variants.firstWhereOrNull(
          (v) => v.color == newColor,
        );
        if (firstSizeForColor != null) {
          selectedVariant.value = firstSizeForColor;
          return;
        }
      }

      // If selecting a size (newSize != null and newColor == null)
      if (newSize != null && newColor == null) {
        // Try to keep current color with new size
        if (currentColor != null) {
          final sizeColorMatch = productData.value!.variants.firstWhereOrNull(
            (v) => v.size == newSize && v.color == currentColor,
          );
          if (sizeColorMatch != null) {
            selectedVariant.value = sizeColorMatch;
            return;
          }
        }
        // If can't keep current color, select first available color for this size
        final firstColorForSize = productData.value!.variants.firstWhereOrNull(
          (v) => v.size == newSize,
        );
        if (firstColorForSize != null) {
          selectedVariant.value = firstColorForSize;
          return;
        }
      }

      // If selecting both color and size
      if (newColor != null && newSize != null) {
        final exactMatch = productData.value!.variants.firstWhereOrNull(
          (v) => v.color == newColor && v.size == newSize,
        );
        if (exactMatch != null) {
          selectedVariant.value = exactMatch;
          return;
        }
      }
    }

    // Fallback to the selected variant
    selectedVariant.value = variant;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void changeImageIndex(int index) {
    currentImageIndex.value = index;
  }

  Map<String, dynamic> getCurrentPrice() {
    if (selectedVariant.value != null) {
      return getVariantPrice(selectedVariant.value!);
    }
    return _getProductPrice();
  }

  Map<String, dynamic> _getProductPrice() {
    final product = productData.value!;
    final originalPrice = product.price;
    final discount = product.discount;
    final price = discount > 0
        ? originalPrice - (originalPrice * discount / 100)
        : originalPrice;

    return {'price': price, 'originalPrice': originalPrice};
  }

  Map<String, dynamic> getVariantPrice(ProductVariant variant) {
    final originalPrice = variant.price;
    final discount = variant.discount;
    final price = discount > 0
        ? originalPrice - (originalPrice * discount / 100)
        : originalPrice;

    return {'price': price, 'originalPrice': originalPrice};
  }

  int getDiscountPercentage() {
    final priceInfo = getCurrentPrice();
    final originalPrice = priceInfo['originalPrice'];
    final price = priceInfo['price'];

    if (originalPrice > price) {
      return ((originalPrice - price) / originalPrice * 100).round();
    }
    return 0;
  }

  String getVariantTitle(ProductVariant variant) {
    List<String> parts = [];
    if (variant.color != null) {
      // Convert hex color to readable name if it's a hex code
      String colorName = _getColorNameFromHex(variant.color!);
      parts.add(colorName);
    }
    if (variant.size != null) parts.add(variant.size!);
    return parts.join(' - ');
  }

  String _getColorNameFromHex(String colorValue) {
    // If it's already a readable name, return it
    if (!colorValue.startsWith('#')) {
      return colorValue;
    }

    // Convert hex to readable color name
    switch (colorValue.toUpperCase()) {
      case '#FF0000':
      case '#FF5733':
        return 'Red';
      case '#0000FF':
      case '#3498DB':
        return 'Blue';
      case '#00FF00':
      case '#2ECC71':
        return 'Green';
      case '#FFFF00':
      case '#F1C40F':
        return 'Yellow';
      case '#FFA500':
      case '#E67E22':
        return 'Orange';
      case '#800080':
      case '#9B59B6':
        return 'Purple';
      case '#FFC0CB':
      case '#E91E63':
        return 'Pink';
      case '#000000':
        return 'Black';
      case '#FFFFFF':
        return 'White';
      case '#808080':
      case '#95A5A6':
        return 'Grey';
      default:
        return colorValue; // Return original if not recognized
    }
  }

  Color getColorFromString(String colorName) {
    // Handle hex codes
    if (colorName.startsWith('#')) {
      try {
        return Color(int.parse(colorName.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.grey[300]!;
      }
    }

    // Handle color names
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey[300]!;
    }
  }

  bool get isVariantInStock {
    if (selectedVariant.value != null) {
      return selectedVariant.value!.isInStock;
    }
    // If no variants, check main product stock
    return productData.value?.isInStock ?? false;
  }

  int get currentStock {
    if (selectedVariant.value != null) {
      return selectedVariant.value!.stock;
    }
    return productData.value?.stock ?? 0;
  }
}
