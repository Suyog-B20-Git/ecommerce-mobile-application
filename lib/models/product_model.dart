class ProductModel {
  final String id;
  final String title;
  final String name; // Alias for title
  final String description;
  final String shortDescription;
  final String unit;
  final String upc;
  final List<String> images;
  final bool isActive;
  final bool isFeatured;
  final double rating;
  final int soldCount;
  final String status;
  final String categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final List<ProductAttribute> attributes;
  final int stock;
  final double price;
  final double discount;
  final List<ProductVariant> variants;
  final DateTime createdAt;
  final DateTime updatedAt;

  // New dashboard properties
  final bool? isNew;
  final bool? isTrending;
  final String? newBadge;
  final double? trendingScore;
  final int? ranking;
  final String? medalType;
  final int? viewCount;

  ProductModel({
    required this.id,
    required this.title,
    this.name = '',
    this.description = '',
    this.shortDescription = '',
    this.unit = '',
    this.upc = '',
    this.images = const [],
    this.isActive = true,
    this.isFeatured = false,
    this.rating = 0.0,
    this.soldCount = 0,
    this.status = 'active',
    required this.categoryId,
    this.categoryName,
    this.subcategoryId,
    this.attributes = const [],
    this.stock = 0,
    this.price = 0.0,
    this.discount = 0.0,
    this.variants = const [],
    required this.createdAt,
    required this.updatedAt,
    // New dashboard properties
    this.isNew,
    this.isTrending,
    this.newBadge,
    this.trendingScore,
    this.ranking,
    this.medalType,
    this.viewCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      unit: json['unit'] ?? '',
      upc: json['upc'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      soldCount: json['soldCount'] ?? 0,
      status: json['status'] ?? 'active',
      categoryId: json['category'] is Map
          ? (json['category']['_id'] ?? json['category']['id'] ?? '')
          : (json['category'] ?? ''),
      categoryName: json['category'] is Map
          ? (json['category']['name'] ?? '')
          : null,
      subcategoryId: json['subcategory'] is Map
          ? (json['subcategory']['_id'] ?? json['subcategory']['id'] ?? '')
          : (json['subcategory'] ?? ''),
      attributes:
          (json['attributes'] as List<dynamic>?)
              ?.map((attr) => ProductAttribute.fromJson(attr))
              .toList() ??
          [],
      stock: json['stock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((variant) => ProductVariant.fromJson(variant))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      // New dashboard properties
      isNew: json['isNew'],
      isTrending: json['isTrending'],
      newBadge: json['newBadge'],
      trendingScore: json['trendingScore']?.toDouble(),
      ranking: json['ranking'],
      medalType: json['medalType'],
      viewCount: json['viewCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'shortDescription': shortDescription,
      'unit': unit,
      'upc': upc,
      'images': images,
      'status': status,
      'category': categoryId,
      'categoryName': categoryName,
      'subcategory': subcategoryId,
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
      'stock': stock,
      'price': price,
      'discount': discount,
      'variants': variants.map((variant) => variant.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // New dashboard properties
      'isNew': isNew,
      'isTrending': isTrending,
      'newBadge': newBadge,
      'trendingScore': trendingScore,
      'ranking': ranking,
      'medalType': medalType,
      'viewCount': viewCount,
    };
  }

  // Computed properties
  double get finalPrice => price - (price * discount / 100);
  bool get isInStock =>
      stock > 0 || variants.any((variant) => variant.stock > 0);
  bool get hasVariants => variants.isNotEmpty;
  String get primaryImage => images.isNotEmpty ? images.first : '';

  // Dashboard computed properties
  bool get isNewProduct => isNew ?? false;
  bool get isTrendingProduct => isTrending ?? false;
  bool get hasNewBadge => newBadge != null && newBadge!.isNotEmpty;
  bool get hasRanking => ranking != null && ranking! > 0;
  bool get hasMedal => medalType != null && medalType!.isNotEmpty;
  String get displayBadge => newBadge ?? (isNewProduct ? 'NEW' : '');
  double get displayTrendingScore => trendingScore ?? 0.0;

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    String? shortDescription,
    String? unit,
    String? upc,
    List<String>? images,
    String? status,
    String? categoryId,
    String? subcategoryId,
    List<ProductAttribute>? attributes,
    int? stock,
    double? price,
    double? discount,
    List<ProductVariant>? variants,
    DateTime? createdAt,
    DateTime? updatedAt,
    // New dashboard properties
    bool? isNew,
    bool? isTrending,
    String? newBadge,
    double? trendingScore,
    int? ranking,
    String? medalType,
    int? viewCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      unit: unit ?? this.unit,
      upc: upc ?? this.upc,
      images: images ?? this.images,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      attributes: attributes ?? this.attributes,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      variants: variants ?? this.variants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // New dashboard properties
      isNew: isNew ?? this.isNew,
      isTrending: isTrending ?? this.isTrending,
      newBadge: newBadge ?? this.newBadge,
      trendingScore: trendingScore ?? this.trendingScore,
      ranking: ranking ?? this.ranking,
      medalType: medalType ?? this.medalType,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}

class ProductAttribute {
  final String name;
  final dynamic value;

  ProductAttribute({required this.name, required this.value});

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(name: json['name'] ?? '', value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'value': value};
  }

  ProductAttribute copyWith({String? name, dynamic value}) {
    return ProductAttribute(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }
}

class ProductVariant {
  final String? sku;
  final String? color;
  final String? size;
  final double price;
  final double discount;
  final int stock;
  final Map<String, dynamic> attributes;
  final List<String> images;

  ProductVariant({
    this.sku,
    this.color,
    this.size,
    required this.price,
    this.discount = 0.0,
    this.stock = 0,
    this.attributes = const {},
    this.images = const [],
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      sku: json['sku'],
      color: json['color'],
      size: json['size'],
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'color': color,
      'size': size,
      'price': price,
      'discount': discount,
      'stock': stock,
      'attributes': attributes,
      'images': images,
    };
  }

  // Computed properties
  double get finalPrice => price - (price * discount / 100);
  bool get isInStock => stock > 0;

  ProductVariant copyWith({
    String? sku,
    String? color,
    String? size,
    double? price,
    double? discount,
    int? stock,
    Map<String, dynamic>? attributes,
    List<String>? images,
  }) {
    return ProductVariant(
      sku: sku ?? this.sku,
      color: color ?? this.color,
      size: size ?? this.size,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      stock: stock ?? this.stock,
      attributes: attributes ?? this.attributes,
      images: images ?? this.images,
    );
  }
}
