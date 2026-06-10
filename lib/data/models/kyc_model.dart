enum KycStatus {
  notSubmitted,
  pending,
  approved,
  rejected,
}

class KycModel {
  final int? id;
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
      id: json['id'] as int?,
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
