class ApiResponse {
  const ApiResponse({required this.success, this.data, this.meta});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'],
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  final bool success;
  final dynamic data;
  final Map<String, dynamic>? meta;
}
