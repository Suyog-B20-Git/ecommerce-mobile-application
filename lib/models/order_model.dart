class OrderModel {
  final String id;
  final String userId;
  final String orderNumber;
  final String status;
  final List<OrderItem> items;
  final OrderAddress shippingAddress;
  final OrderAddress billingAddress;
  final double subtotal;
  final double shippingCost;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentId;
  final String? trackingNumber;
  final String? notes;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderNumber,
    this.status = 'pending',
    this.items = const [],
    required this.shippingAddress,
    required this.billingAddress,
    this.subtotal = 0.0,
    this.shippingCost = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.totalAmount = 0.0,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentId,
    this.trackingNumber,
    this.notes,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? 'pending',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      shippingAddress: OrderAddress.fromJson(json['shippingAddress'] ?? {}),
      billingAddress: OrderAddress.fromJson(json['billingAddress'] ?? {}),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      paymentId: json['paymentId'],
      trackingNumber: json['trackingNumber'],
      notes: json['notes'],
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      shippedAt: json['shippedAt'] != null
          ? DateTime.parse(json['shippedAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderNumber': orderNumber,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'billingAddress': billingAddress.toJson(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'shippedAt': shippedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isReturned => status == 'returned';

  OrderModel copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    String? status,
    List<OrderItem>? items,
    OrderAddress? shippingAddress,
    OrderAddress? billingAddress,
    double? subtotal,
    double? shippingCost,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? paymentId,
    String? trackingNumber,
    String? notes,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderItem {
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

  OrderItem({
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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Handle productId as either string or populated object
    String productId = '';
    if (json['productId'] != null) {
      if (json['productId'] is String) {
        productId = json['productId'];
      } else if (json['productId'] is Map<String, dynamic>) {
        productId = json['productId']['_id'] ?? json['productId']['id'] ?? '';
      }
    }

    return OrderItem(
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

  OrderItem copyWith({
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
    return OrderItem(
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

class OrderAddress {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String country;

  OrderAddress({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }

  OrderAddress copyWith({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? country,
  }) {
    return OrderAddress(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
    );
  }
}
