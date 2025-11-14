import 'package:ecommerce/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../models/product_model.dart';
import '../../repository/product_repository.dart';
import '../../utils/text_styles.dart';
import '../../controller/wishlist_controller.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final RxList<ProductModel> _products = <ProductModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxInt _page = 1.obs;
  final int _limit = 10;

  String get subcategoryId =>
      (Get.arguments?['subcategoryId'] ?? '').toString();
  String get title => (Get.arguments?['title'] ?? 'Products').toString();
  String get searchTerm => (Get.arguments?['searchTerm'] ?? '').toString();
  String get categoryId => (Get.arguments?['categoryId'] ?? '').toString();
  bool get fromGlobalSearch =>
      (Get.arguments?['fromGlobalSearch'] ?? false) == true;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    _isLoading.value = true;
    try {
      final List<ProductModel> data;
      if (searchTerm.isNotEmpty) {
        data = await ProductRepository.searchProducts(
          query: searchTerm,
          page: 1,
          limit: _limit,
          context: context,
        );
      } else if (subcategoryId.isNotEmpty) {
        data = await ProductRepository.getSubcategoryProducts(
          subcategoryId: subcategoryId,
          page: 1,
          limit: _limit,
          context: context,
        );
      } else if (categoryId.isNotEmpty) {
        data = await ProductRepository.getCategoryProducts(
          categoryId: categoryId,
          page: 1,
          limit: _limit,
          context: context,
        );
      } else {
        data = await ProductRepository.getProducts(
          page: 1,
          limit: _limit,
          context: context,
        );
      }
      _products.value = data;
      _page.value = 2;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore.value) return;
    _isLoadingMore.value = true;
    try {
      final List<ProductModel> more = searchTerm.isNotEmpty
          ? await ProductRepository.searchProducts(
              query: searchTerm,
              page: _page.value,
              limit: _limit,
              context: context,
            )
          : subcategoryId.isNotEmpty
          ? await ProductRepository.getSubcategoryProducts(
              subcategoryId: subcategoryId,
              page: _page.value,
              limit: _limit,
              context: context,
            )
          : categoryId.isNotEmpty
          ? await ProductRepository.getCategoryProducts(
              categoryId: categoryId,
              page: _page.value,
              limit: _limit,
              context: context,
            )
          : await ProductRepository.getProducts(
              page: _page.value,
              limit: _limit,
              context: context,
            );
      if (more.isNotEmpty) {
        _products.addAll(more);
        _page.value++;
      }
    } finally {
      _isLoadingMore.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          title,
          style: TextHelper.size18(
            context,
          ).copyWith(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: (!fromGlobalSearch && searchTerm.isEmpty)
            ? PreferredSize(
                preferredSize: Size.fromHeight(5.h),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.w),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF0EA5E9,
                          ).withAlpha((0.3 * 255).toInt()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF0EA5E9),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 3.w),
                        const Icon(Icons.search, color: Color(0xFF0EA5E9)),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'products.searchHint'.tr,
                              border: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            style: TextHelper.size15(
                              context,
                            ).copyWith(color: Colors.black),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (q) {
                              // TODO: trigger server search within subcategory
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Obx(() {
        if (_isLoading.value && _products.isEmpty) {
          return _buildShimmerList();
        }
        if (_products.isEmpty) {
          return const Center(child: Text('No products found'));
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (sn) {
            if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 200) {
              _loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final p = _products[index];
              final image = p.images.isNotEmpty
                  ? p.images.first
                  : (p.variants.isNotEmpty && p.variants.first.images.isNotEmpty
                        ? p.variants.first.images.first
                        : '');

              final originalPrice = (p.variants.isNotEmpty
                  ? p.variants.first.price
                  : p.price);
              final discount = (p.variants.isNotEmpty
                  ? p.variants.first.discount
                  : p.discount);
              final price = (originalPrice - (originalPrice * discount / 100))
                  .clamp(0, double.infinity);
              final hasDiscount = (discount > 0);
              final previewAttrs = p.attributesPreview.isNotEmpty
                  ? p.attributesPreview
                  : p.attributes;

              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    Routes.PRODUCT_DETAIL_SCREEN,
                    arguments: {'productId': p.id, 'product': p},
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 3.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.07 * 255).toInt()),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha((0.03 * 255).toInt()),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.withAlpha((0.12 * 255).toInt()),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image left
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 28.w,
                                height: 28.w,
                                color: Colors.grey[200],
                                child: image.isNotEmpty
                                    ? Image.network(
                                        image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) =>
                                            Container(color: Colors.grey[300]),
                                      )
                                    : Icon(
                                        Icons.image,
                                        color: Colors.grey[500],
                                      ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            // Info right
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextHelper.size16(context).copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 0.8.h),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${price.toStringAsFixed(0)}',
                                        style: TextHelper.size16(context)
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0EA5E9),
                                            ),
                                      ),
                                      if (hasDiscount) ...[
                                        SizedBox(width: 2.w),
                                        Text(
                                          '₹${originalPrice.toStringAsFixed(0)}',
                                          style: TextHelper.size14(context)
                                              .copyWith(
                                                color: Colors.grey[600],
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                            vertical: 0.3.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFE11D48,
                                            ).withAlpha((0.1 * 255).toInt()),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '${discount.toInt()}% OFF',
                                            style: TextHelper.size12(context)
                                                .copyWith(
                                                  color: const Color(
                                                    0xFFE11D48,
                                                  ),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 0.6.h),
                                  if (previewAttrs.isNotEmpty)
                                    Wrap(
                                      spacing: 2.w,
                                      runSpacing: 0.8.h,
                                      children: previewAttrs
                                          .take(4)
                                          .map(
                                            (attr) => Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 2.w,
                                                vertical: 0.4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0EA5E9)
                                                    .withAlpha(
                                                      (0.08 * 255).toInt(),
                                                    ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: const Color(0xFF0EA5E9)
                                                      .withAlpha(
                                                        (0.2 * 255).toInt(),
                                                      ),
                                                ),
                                              ),
                                              child: Text(
                                                '${attr.name}: ${attr.value}',
                                                style:
                                                    TextHelper.size12(
                                                      context,
                                                    ).copyWith(
                                                      color: const Color(
                                                        0xFF0EA5E9,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Top-right like icon
                      Positioned(
                        top: 1.w,
                        right: 1.w,
                        child: Obx(() {
                          final wishlistController =
                              Get.find<WishlistController>();
                          final isFavorite = wishlistController.wishlistItems
                              .any((item) => item.id == p.id);
                          return GestureDetector(
                            onTap: () {
                              wishlistController.toggleWishlist(
                                product: p,
                                context: context,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: isFavorite
                                    ? Colors.red.withAlpha((0.1 * 255).toInt())
                                    : Colors.white.withAlpha(
                                        (0.8 * 255).toInt(),
                                      ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.red,
                                size: 4.w,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.only(bottom: 3.w),
        height: 26.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
