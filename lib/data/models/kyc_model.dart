enum KycStatus {
  notSubmitted,
  pending,
  approved,
  rejected,
}

class KycModel {
  final String? id;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? selfieImageUrl;
  final String? idCardNumber;
  final String? status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  const KycModel({
    this.id,
    this.frontImageUrl,
    this.backImageUrl,
    this.selfieImageUrl,
    this.idCardNumber,
    this.status,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  factory KycModel.fromJson(Map<String, dynamic> json) {
    return KycModel(
      id: json['id']?.toString(),
      frontImageUrl: json['frontImageUrl'] as String?,
      backImageUrl: json['backImageUrl'] as String?,
      selfieImageUrl: json['selfieImageUrl'] as String?,
      idCardNumber: json['idCardNumber'] as String?,
      status: json['status'] as String?,
      submittedAt: json['submittedAt'] != null ? DateTime.tryParse(json['submittedAt'] as String) : null,
      reviewedAt: json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt'] as String) : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  KycStatus get statusEnum {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return KycStatus.pending;
      case 'APPROVED':
        return KycStatus.approved;
      case 'REJECTED':
        return KycStatus.rejected;
      default:
        return KycStatus.notSubmitted;
    }
  }

  bool get isVerified => statusEnum == KycStatus.approved;
  bool get isPending => statusEnum == KycStatus.pending;
  bool get isRejected => statusEnum == KycStatus.rejected;
}

// ─── API Response Models ───────────────────────────────────────────────────────

class KycStartResponse {
  final String sessionId;
  final String status;

  KycStartResponse({required this.sessionId, required this.status});

  factory KycStartResponse.fromJson(Map<String, dynamic> json) {
    return KycStartResponse(
      sessionId: json['sessionId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class KycUploadResponse {
  final String fileHash;
  final String type;
  final String sessionId;

  KycUploadResponse({
    required this.fileHash,
    required this.type,
    required this.sessionId,
  });

  factory KycUploadResponse.fromJson(Map<String, dynamic> json) {
    return KycUploadResponse(
      fileHash: json['fileHash']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
    );
  }
}

class KycSessionResponse {
  final bool success;
  final KycSessionData? session;

  KycSessionResponse({required this.success, this.session});

  factory KycSessionResponse.fromJson(Map<String, dynamic> json) {
    final sess = json['session'] as Map<String, dynamic>?;
    return KycSessionResponse(
      success: json['success'] as bool? ?? false,
      session: sess != null ? KycSessionData.fromJson(sess) : null,
    );
  }
}

class KycSessionData {
  final String? id;
  final String? accountId;
  final String? status;
  final String? frontHash;
  final String? backHash;
  final String? selfieHash;

  KycSessionData({
    this.id,
    this.accountId,
    this.status,
    this.frontHash,
    this.backHash,
    this.selfieHash,
  });

  factory KycSessionData.fromJson(Map<String, dynamic> json) {
    return KycSessionData(
      id: json['id']?.toString(),
      accountId: json['accountId']?.toString(),
      status: json['status']?.toString(),
      frontHash: json['frontHash'] as String?,
      backHash: json['backHash'] as String?,
      selfieHash: json['selfieHash'] as String?,
    );
  }

  bool get hasFront   => frontHash  != null && frontHash!.isNotEmpty;
  bool get hasBack    => backHash    != null && backHash!.isNotEmpty;
  bool get hasSelfie  => selfieHash  != null && selfieHash!.isNotEmpty;
}

class KycCompareResponse {
  final bool isMatch;
  final double matchScore;
  final String status;
  final DateTime? verifiedAt;

  KycCompareResponse({
    required this.isMatch,
    required this.matchScore,
    required this.status,
    this.verifiedAt,
  });

  factory KycCompareResponse.fromJson(Map<String, dynamic> json) {
    return KycCompareResponse(
      isMatch: json['isMatch'] as bool? ?? false,
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'].toString())
          : null,
    );
  }

  bool get isVerified => status.toUpperCase() == 'VERIFIED';
}
