import 'user_model.dart';

class LoginResponseModel {
  final int status;
  final String message;
  final String accessToken;
  final String refreshToken;
  final String accessExpires;
  final String refreshExpires;
  final UserModel user;

  LoginResponseModel({
    required this.status,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpires,
    required this.refreshExpires,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle nested tokens structure like Smartle Pro
    final tokens = json["tokens"] ?? {};
    final access = tokens["access"] ?? {};
    final refresh = tokens["refresh"] ?? {};

    // Fallback to direct token fields if nested structure doesn't exist
    final accessToken =
        access["token"] ?? json["accessToken"] ?? json["token"] ?? "";
    final refreshToken = refresh["token"] ?? json["refreshToken"] ?? "";
    final accessExpires = access["expires"] ?? json["accessExpires"] ?? "";
    final refreshExpires = refresh["expires"] ?? json["refreshExpires"] ?? "";

    return LoginResponseModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpires: accessExpires,
      refreshExpires: refreshExpires,
      user: UserModel.fromJson(json["user"] ?? json["data"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'tokens': {
        'access': {'token': accessToken, 'expires': accessExpires},
        'refresh': {'token': refreshToken, 'expires': refreshExpires},
      },
      'user': user.toJson(),
    };
  }

  // Helper getter to check if response is successful
  bool get isSuccess => status == 1;
}
