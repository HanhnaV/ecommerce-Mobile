class AdminRequestModel {
  final String requestId;
  final String accountId;
  final String type;
  final String status;
  final DateTime? createdAt;

  AdminRequestModel({
    required this.requestId,
    required this.accountId,
    required this.type,
    required this.status,
    this.createdAt,
  });

  factory AdminRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminRequestModel(
      requestId: json['requestId'].toString(),
      accountId: json['accountId'].toString(),
      type: json['type'] as String? ?? 'UNKNOWN',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}

class AdminRequestPage {
  final List<AdminRequestModel> content;
  final int totalPages;
  final int totalElements;

  AdminRequestPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
  });

  factory AdminRequestPage.fromJson(Map<String, dynamic> json) {
    return AdminRequestPage(
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => AdminRequestModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
    );
  }
}
