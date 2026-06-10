class Report {
  final int id;
  final String reportType;
  final String reason;
  final String? description;
  final String status;
  final int? targetId;
  final String? targetType;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminNote;

  const Report({
    required this.id,
    required this.reportType,
    required this.reason,
    this.description,
    required this.status,
    this.targetId,
    this.targetType,
    required this.createdAt,
    this.resolvedAt,
    this.adminNote,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      reportType: json['reportType'] as String? ?? 'ORDER',
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      targetId: json['targetId'] as int?,
      targetType: json['targetType'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      adminNote: json['adminNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportType': reportType,
      'reason': reason,
      'description': description,
      'status': status,
      'targetId': targetId,
      'targetType': targetType,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'adminNote': adminNote,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'Dang xu ly';
      case 'RESOLVED':
        return 'Da giai quyet';
      case 'REJECTED':
        return 'Tu choi';
      default:
        return status;
    }
  }

  String get typeLabel {
    switch (reportType) {
      case 'ORDER':
        return 'Don hang';
      case 'PRODUCT':
        return 'San pham';
      case 'SELLER':
        return 'Nguoi ban';
      case 'REVIEW':
        return 'Danh gia';
      case 'OTHER':
        return 'Khac';
      default:
        return reportType;
    }
  }
}

class ReportSubmitBody {
  final String reportType;
  final String reason;
  final String? description;
  final int? targetId;
  final String? targetType;

  const ReportSubmitBody({
    required this.reportType,
    required this.reason,
    this.description,
    this.targetId,
    this.targetType,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportType': reportType,
      'reason': reason,
      if (description != null) 'description': description,
      if (targetId != null) 'targetId': targetId,
      if (targetType != null) 'targetType': targetType,
    };
  }
}
