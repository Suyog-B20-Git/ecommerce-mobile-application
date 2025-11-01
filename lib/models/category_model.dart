class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? image;
  final String? icon;
  final String? color;
  final bool isActive;
  final String status;
  final int sortOrder;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.image,
    this.icon,
    this.color,
    this.isActive = true,
    this.status = 'active',
    this.sortOrder = 0,
    this.productCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      icon: json['icon'],
      color: json['color'],
      isActive: json['isActive'] ?? true,
      status: json['status'] ?? 'active',
      sortOrder: json['sortOrder'] ?? 0,
      productCount: json['productCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'status': status,
      'sortOrder': sortOrder,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? status,
    int? sortOrder,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
