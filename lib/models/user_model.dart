class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? profileImage;
  final DateTime? dateOfBirth;
  final String gender;
  final String? referralCode;
  final String? referredBy;
  final UserPreferences preferences;
  final List<UserAddress> addresses;
  final String status;
  final DateTime? lastLoginAt;
  final int loginCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.profileImage,
    this.dateOfBirth,
    this.gender = 'other',
    this.referralCode,
    this.referredBy,
    required this.preferences,
    this.addresses = const [],
    this.status = 'active',
    this.lastLoginAt,
    this.loginCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      profileImage: json['profileImage'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      gender: json['gender'] ?? 'other',
      referralCode: json['referralCode'] ?? '',
      referredBy: json['referredBy'] ?? '',
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map((address) => UserAddress.fromJson(address))
              .toList() ??
          [],
      status: json['status'] ?? 'active',
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
      loginCount: json['loginCount'] ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'profileImage': profileImage,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'preferences': preferences.toJson(),
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'status': status,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'loginCount': loginCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? profileImage,
    DateTime? dateOfBirth,
    String? gender,
    String? referralCode,
    String? referredBy,
    UserPreferences? preferences,
    List<UserAddress>? addresses,
    String? status,
    DateTime? lastLoginAt,
    int? loginCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      preferences: preferences ?? this.preferences,
      addresses: addresses ?? this.addresses,
      status: status ?? this.status,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginCount: loginCount ?? this.loginCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserPreferences {
  final String theme;
  final bool notifications;
  final bool marketing;

  UserPreferences({
    this.theme = 'system',
    this.notifications = true,
    this.marketing = true,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] ?? 'system',
      notifications: json['notifications'] ?? true,
      marketing: json['marketing'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'notifications': notifications,
      'marketing': marketing,
    };
  }

  UserPreferences copyWith({
    String? theme,
    bool? notifications,
    bool? marketing,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      marketing: marketing ?? this.marketing,
    );
  }
}

class UserAddress {
  final String type;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final bool isDefault;

  UserAddress({
    this.type = 'home',
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
    this.isDefault = false,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      type: json['type'] ?? 'home',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? 'India',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  UserAddress copyWith({
    String? type,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? country,
    bool? isDefault,
  }) {
    return UserAddress(
      type: type ?? this.type,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
