class SearchSuggestion {
  final String type; // 'category' | 'subcategory' | 'product'
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String categoryId;
  final String subcategoryId;

  SearchSuggestion({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle = '',
    this.image = '',
    this.categoryId = '',
    this.subcategoryId = '',
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      type: (json['type'] ?? '').toString(),
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      image: (json['image'] ?? (json['images'] is List && (json['images'] as List).isNotEmpty ? (json['images'][0] ?? '') : '')).toString(),
      categoryId: (json['categoryId'] ?? json['category'] ?? '').toString(),
      subcategoryId: (json['subcategoryId'] ?? json['subcategory'] ?? '').toString(),
    );
  }
}



