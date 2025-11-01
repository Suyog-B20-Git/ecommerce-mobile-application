class ApiResponse {
  final int status;
  final String message;
  final Map<String, dynamic>? data;

  ApiResponse({required this.status, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"],
    );
  }

  // Helper getter to check if response is successful
  bool get isSuccess => status == 1;

  // Helper getter to get data safely
  Map<String, dynamic>? get responseData => data;
}
