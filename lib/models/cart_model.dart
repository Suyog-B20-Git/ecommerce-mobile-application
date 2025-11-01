class CartModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    this.items = const [],
    this.totalAmount = 0.0,
    this.discountAmount = 0.0,
    this.finalAmount = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartModel copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    double? discountAmount,
    double? finalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double discount;
  final int quantity;
  final String? variantId;
  final Map<String, dynamic> variantAttributes;
  final double totalPrice;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.discount = 0.0,
    required this.quantity,
    this.variantId,
    this.variantAttributes = const {},
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Handle productId - it might be a string or an object
    String productId = '';
    if (json['productId'] is String) {
      productId = json['productId'];
    } else if (json['productId'] is Map<String, dynamic>) {
      productId = json['productId']['_id'] ?? json['productId']['id'] ?? '';
    }

    return CartItem(
      id: json['_id'] ?? json['id'] ?? '',
      productId: productId,
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      variantId: json['variantId'],
      variantAttributes: Map<String, dynamic>.from(
        json['variantAttributes'] ?? {},
      ),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'discount': discount,
      'quantity': quantity,
      'variantId': variantId,
      'variantAttributes': variantAttributes,
      'totalPrice': totalPrice,
    };
  }

  // Computed properties
  double get finalPrice => price - (price * discount / 100);
  double get itemTotal => finalPrice * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? discount,
    int? quantity,
    String? variantId,
    Map<String, dynamic>? variantAttributes,
    double? totalPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      quantity: quantity ?? this.quantity,
      variantId: variantId ?? this.variantId,
      variantAttributes: variantAttributes ?? this.variantAttributes,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
