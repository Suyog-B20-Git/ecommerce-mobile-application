import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/theme_controller.dart';
import '../../repository/product_repository.dart';
import '../../models/category_model.dart';
import '../../utils/theme_config.dart';
import '../../utils/text_styles.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;
  final RxList<Map<String, dynamic>> _subcategories =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedCategoryId = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _isLoading.value = true;
    try {
      final cats = await ProductRepository.getCategories(context: context);
      _categories.value = cats;
      if (cats.isNotEmpty) {
        _selectedCategoryId.value = cats.first.id;
        await _loadSubcategories(cats.first.id);
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadSubcategories(String categoryId) async {
    _subcategories.clear();
    final subs = await ProductRepository.getSubcategories(
      categoryId: categoryId,
      context: context,
    );
    _subcategories.value = subs;
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    // final dashboardController = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: themeController.isDark
          ? PremiumColors.charcoal
          : PremiumColors.softBackground,
      appBar: AppBar(
        title: Text(
          'Categories',
          style: TextHelper.size18(context).copyWith(
            fontWeight: FontWeight.bold,
            color: themeController.isDark
                ? Colors.white
                : PremiumColors.charcoal,
          ),
        ),
        backgroundColor: themeController.isDark
            ? PremiumColors.charcoal
            : Colors.white,
        elevation: 0,
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(
          //     Icons.search,
          //     color: themeController.isDark
          //         ? Colors.white
          //         : PremiumColors.charcoal,
          //   ),
          // ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value && _categories.isEmpty) {
          return _buildShimmerGrid();
        }
        if (_categories.isEmpty) {
          return _buildEmptyState(context, themeController);
        }
        return Row(
          children: [
            // Left categories list
            Container(
              width: 28.w,
              color: themeController.isDark
                  ? PremiumColors.grey800
                  : Colors.white,
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final c = _categories[index];
                  final selected = c.id == _selectedCategoryId.value;
                  return GestureDetector(
                    onTap: () async {
                      _selectedCategoryId.value = c.id;
                      await _loadSubcategories(c.id);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.w,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 2.w,
                        horizontal: 2.w,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? PremiumColors.gold.withAlpha((0.1 * 255).toInt())
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 18.w,
                              height: 18.w,
                              color: Colors.grey[200],
                              child: (c.image != null && c.image!.isNotEmpty)
                                  ? Image.network(
                                      c.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                          Icon(
                                            Icons.category,
                                            color: selected
                                                ? PremiumColors.gold
                                                : Colors.grey[600],
                                            size: 20,
                                          ),
                                    )
                                  : Icon(
                                      Icons.category,
                                      color: selected
                                          ? PremiumColors.gold
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            c.name,
                            textAlign: TextAlign.center,
                            style: TextHelper.size14(context).copyWith(
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? PremiumColors.gold
                                  : (themeController.isDark
                                        ? Colors.white
                                        : PremiumColors.charcoal),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Right subcategories
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: _subcategories.length,
                      itemBuilder: (context, index) {
                        final s = _subcategories[index];
                        final sid = (s['_id'] ?? s['id'] ?? '').toString();
                        return Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: ChoiceChip(
                            label: Text(s['name'] ?? ''),
                            labelStyle: TextHelper.size16(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: themeController.isDark
                                  ? Colors.white
                                  : PremiumColors.charcoal,
                            ),
                            selected: false,
                            backgroundColor: themeController.isDark
                                ? PremiumColors.grey800
                                : Colors.white,
                            selectedColor: PremiumColors.gold.withAlpha(
                              (0.1 * 255).toInt(),
                            ),
                            side: BorderSide(
                              color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                            ),
                            shape: const StadiumBorder(),
                            onSelected: (val) {
                              Get.toNamed(
                                '/product_list_screen',
                                arguments: {
                                  'subcategoryId': sid,
                                  'title': s['name'] ?? 'Products',
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShimmerGrid() {
    return Center(child: CircularProgressIndicator(color: PremiumColors.gold));
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeController themeController,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 20.w, color: Colors.grey[400]),
          SizedBox(height: 4.h),
          Text(
            'No Categories Available',
            style: TextHelper.size16(context).copyWith(
              fontWeight: FontWeight.w600,
              color: themeController.isDark
                  ? Colors.white
                  : PremiumColors.charcoal,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Categories will appear here once they are added',
            textAlign: TextAlign.center,
            style: TextHelper.size14(context).copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
