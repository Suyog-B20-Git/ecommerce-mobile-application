import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../utils/text_styles.dart';
import '../../utils/theme_config.dart';
import '../../controller/theme_controller.dart';
import '../../controller/cart_controller.dart';
import '../../widgets/snackbar.dart' as CustomSnackBar;
import '../../widgets/dashboard_widgets/modern_product_card.dart';
import '../../routes/routes.dart';

class ViewAllProductsScreen extends StatelessWidget {
  const ViewAllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    // Get arguments passed from navigation
    final String sectionType = Get.arguments?['sectionType'] ?? 'featured';
    final List<dynamic> products = Get.arguments?['products'] ?? [];
    final String title = Get.arguments?['title'] ?? 'products.allProducts'.tr;

    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.charcoal
          : PremiumColors.softBackground,
      appBar: AppBar(
        backgroundColor: themeController.isDark
            ? PremiumColors.grey800
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: themeController.isDark ? Colors.white : PremiumColors.charcoal,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: TextHelper.size18(context).copyWith(
            fontWeight: FontWeight.bold,
            color: themeController.isDark ? Colors.white : PremiumColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: products.isEmpty
          ? _buildEmptyState(context, themeController)
          : _buildProductGrid(context, themeController, products, sectionType),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    ThemeController themeController,
    List<dynamic> products,
    String sectionType,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65, // Adjusted for product cards
        mainAxisSpacing: 3.w,
        crossAxisSpacing: 3.w,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ModernProductCard(
          product: product,
          cardType: sectionType == 'new' ? 'new' : 
                   sectionType == 'trending' ? 'trending' :
                   sectionType == 'bestseller' ? 'bestseller' : 'featured',
          onTap: () {
            Get.toNamed(
              Routes.PRODUCT_DETAIL_SCREEN,
              arguments: {
                'productId': product.id,
                'product': product,
              },
            );
          },
          onFavorite: () {
            // TODO: Toggle favorite
          },
          onAddToCart: () {
            _handleAddToCart(context, product);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeController themeController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: PremiumColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 15.w,
              color: PremiumColors.gold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'products.noProducts'.tr,
            style: TextHelper.size18(context).copyWith(
              fontWeight: FontWeight.w600,
              color: themeController.isDark
                  ? Colors.white70
                  : Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'products.checkBackLater'.tr,
            style: TextHelper.size14(context).copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart(BuildContext context, dynamic product) async {
    try {
      final cartController = Get.find<CartController>();

      String productId = product.id ?? product['_id'] ?? '';
      String? variantId;
      Map<String, dynamic>? variantAttributes;

      // Prefer first in-stock variant if available
      if (product.variants != null && product.variants.isNotEmpty) {
        final v = (product.variants as List).firstWhere(
          (vv) => (vv.stock ?? vv['stock'] ?? 0) > 0,
          orElse: () => product.variants.first,
        );
        variantId = v.sku ?? v['sku'];
        final color = v.color ?? v['color'];
        final size = v.size ?? v['size'];
        variantAttributes = {
          if (color != null) 'color': color,
          if (size != null) 'size': size,
        };
      }

      final ok = await cartController.addToCart(
        productId: productId,
        quantity: 1,
        variantId: variantId,
        variantAttributes: variantAttributes,
        context: context,
      );

      if (!ok) {
        CustomSnackBar.SnackBar.error(
          title: 'products.addToCart'.tr,
          message: 'products.failedToAdd'.tr,
        );
      }
    } catch (e) {
      CustomSnackBar.SnackBar.error(
        title: 'products.addToCart'.tr,
        message: 'error.generic'.tr,
      );
    }
  }
}

