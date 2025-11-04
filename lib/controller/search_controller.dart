import 'package:get/get.dart';
import '../utils/storage_config.dart';
import '../utils/app_enums.dart';
import '../models/search_suggestion.dart';
import '../repository/product_repository.dart';

class SearchController extends GetxController {
  final RxList<String> recentSearches = <String>[].obs;
  final RxList<SearchSuggestion> suggestions = <SearchSuggestion>[].obs;
  final RxBool loadingSuggestions = false.obs;
  Worker? _debounceWorker;
  final RxList<SearchSuggestion> recommendations = <SearchSuggestion>[].obs;

  static const int maxHistory = 10;

  @override
  void onInit() {
    super.onInit();
    _loadRecent();
    _loadRecommendations();
  }

  @override
  void onClose() {
    _debounceWorker?.dispose();
    super.onClose();
  }

  Future<void> _loadRecommendations() async {
    try {
      final recs = await ProductRepository.getRecommendations(limit: 10);
      recommendations.assignAll(recs);
    } catch (_) {
      recommendations.clear();
    }
  }

  Future<void> _loadRecent() async {
    final dynamic stored = await LocalStorage.getValue(
      StorageKey.recentSearches,
    );
    if (stored is List) {
      recentSearches.assignAll(stored.map((e) => e.toString()));
    }
  }

  Future<void> addToRecent(String term) async {
    final String trimmed = term.trim();
    if (trimmed.isEmpty) return;

    final List<String> updated = List<String>.from(recentSearches);
    updated.removeWhere((e) => e.toLowerCase() == trimmed.toLowerCase());
    updated.insert(0, trimmed);
    if (updated.length > maxHistory) {
      updated.removeRange(maxHistory, updated.length);
    }
    recentSearches.assignAll(updated);
    await LocalStorage.storeValue(StorageKey.recentSearches, updated);
  }

  Future<void> clearRecent() async {
    recentSearches.clear();
    await LocalStorage.storeValue(StorageKey.recentSearches, <String>[]);
  }

  void setupDebouncedSuggestions(RxString query) {
    _debounceWorker?.dispose();
    _debounceWorker = debounce<String>(
      query,
      (value) => searchSuggestions(value),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> searchSuggestions(String query) async {
    final String q = query.trim();
    if (q.isEmpty) {
      suggestions.clear();
      return;
    }
    loadingSuggestions.value = true;
    try {
      List<SearchSuggestion> results = [];
      // Prefer backend suggestions endpoint (faster, tuned)
      results = await ProductRepository.getSearchSuggestions(
        query: q,
        limit: 8,
      );
      // Fallbacks if suggestions endpoint not available
      if (results.isEmpty) {
        try {
          final products = await ProductRepository.searchProducts(
            query: q,
            page: 1,
            limit: 8,
          );
          results = products
              .map(
                (p) => SearchSuggestion(
                  type: 'product',
                  id: p.id,
                  title: p.title.isNotEmpty ? p.title : p.name,
                  subtitle: p.categoryName ?? '',
                  image: p.primaryImage,
                  categoryId: p.categoryId,
                  subcategoryId: p.subcategoryId ?? '',
                ),
              )
              .toList();
        } catch (_) {
          final products = await ProductRepository.getProducts(
            page: 1,
            limit: 8,
            search: q,
          );
          results = products
              .map(
                (p) => SearchSuggestion(
                  type: 'product',
                  id: p.id,
                  title: p.title.isNotEmpty ? p.title : p.name,
                  subtitle: p.categoryName ?? '',
                  image: p.primaryImage,
                  categoryId: p.categoryId,
                  subcategoryId: p.subcategoryId ?? '',
                ),
              )
              .toList();
        }
      }

      // Optional client-side refinement - backend already filters, so this is just a safety check
      // Don't filter too aggressively to ensure categories/subcategories are shown
      final qLower = q.toLowerCase();
      if (qLower.length >= 2) {
        results = results.where((s) {
          final t = s.title.toLowerCase();
          final c = s.subtitle.toLowerCase();
          // Always show categories and subcategories, only filter products strictly
          if (s.type == 'category' || s.type == 'subcategory') {
            return t.contains(qLower) || c.contains(qLower) || qLower.contains(t) || qLower.contains(c);
          }
          // For products, be more strict
          return t.contains(qLower) || c.contains(qLower);
        }).toList();
      }

      suggestions.assignAll(results);
    } finally {
      loadingSuggestions.value = false;
    }
  }
}
