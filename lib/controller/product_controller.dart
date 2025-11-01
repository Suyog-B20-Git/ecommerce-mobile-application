import 'package:get/get.dart';

import '../repository/product_repository.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductController extends GetxController {
  // Observable variables
  final products = <ProductModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final featuredProducts = <ProductModel>[].obs;
  final trendingProducts = <ProductModel>[].obs;
  final searchResults = <ProductModel>[].obs;

  final isLoading = false.obs;
  final isSearching = false.obs;
  final currentPage = 1.obs;
  final hasMoreData = true.obs;

  // Search and filter variables
  final searchQuery = ''.obs;
  final selectedCategory = Rxn<CategoryModel>();
  final sortBy = 'name'.obs;
  final sortOrder = 'asc'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadFeaturedProducts();
    loadTrendingProducts();
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      final categoriesList = await ProductRepository.getCategories();
      categories.value = categoriesList;
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  // Load featured products
  Future<void> loadFeaturedProducts() async {
    try {
      isLoading.value = true;
      final productsList = await ProductRepository.getProducts(
        limit: 10,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );
      featuredProducts.value = productsList;
    } catch (e) {
      print('Error loading featured products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load trending products
  Future<void> loadTrendingProducts() async {
    try {
      final productsList = await ProductRepository.getProducts(
        limit: 10,
        sortBy: 'price',
        sortOrder: 'asc',
      );
      trendingProducts.value = productsList;
    } catch (e) {
      print('Error loading trending products: $e');
    }
  }

  // Load products with pagination
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      products.clear();
    }

    if (!hasMoreData.value) return;

    try {
      isLoading.value = true;
      final productsList = await ProductRepository.getProducts(
        page: currentPage.value,
        limit: 20,
        category: selectedCategory.value?.id,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
      );

      if (refresh) {
        products.value = productsList;
      } else {
        products.addAll(productsList);
      }

      if (productsList.length < 20) {
        hasMoreData.value = false;
      } else {
        currentPage.value++;
      }
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      searchQuery.value = query;

      final results = await ProductRepository.searchProducts(
        query: query,
        category: selectedCategory.value?.id,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
      );

      searchResults.value = results;
    } catch (e) {
      print('Error searching products: $e');
    } finally {
      isSearching.value = false;
    }
  }

  // Get product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      return await ProductRepository.getProduct(productId: productId);
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Filter by category
  void filterByCategory(CategoryModel? category) {
    selectedCategory.value = category;
    loadProducts(refresh: true);
  }

  // Sort products
  void sortProducts(String field, String order) {
    sortBy.value = field;
    sortOrder.value = order;
    loadProducts(refresh: true);
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  // Get products by category
  Future<void> getProductsByCategory(String categoryId) async {
    try {
      isLoading.value = true;
      final productsList = await ProductRepository.getCategoryProducts(
        categoryId: categoryId,
      );
      products.value = productsList;
    } catch (e) {
      print('Error loading products by category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadCategories(),
      loadFeaturedProducts(),
      loadTrendingProducts(),
      loadProducts(refresh: true),
    ]);
  }
}
