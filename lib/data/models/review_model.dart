class ReviewModel {
  final int id;
  final int userId;
  final String? userFullName;
  final String? userAvatarUrl;
  final int rating;
  final String? comment;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final SellerReply? sellerReply;

  const ReviewModel({
    required this.id,
    required this.userId,
    this.userFullName,
    this.userAvatarUrl,
    required this.rating,
    this.comment,
    this.imageUrls = const [],
    this.createdAt,
    this.sellerReply,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userFullName: json['userFullName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      sellerReply: json['sellerReply'] != null
          ? SellerReply.fromJson(json['sellerReply'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SellerReply {
  final String reply;
  final DateTime? repliedAt;

  const SellerReply({
    required this.reply,
    this.repliedAt,
  });

  factory SellerReply.fromJson(Map<String, dynamic> json) {
    return SellerReply(
      reply: json['reply'] as String,
      repliedAt: json['repliedAt'] != null
          ? DateTime.tryParse(json['repliedAt'] as String)
          : null,
    );
  }
}

class ReviewPage {
  final List<ReviewModel> content;
  final int totalPages;
  final int totalElements;

  const ReviewPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
  });

  factory ReviewPage.fromJson(Map<String, dynamic> json) {
    return ReviewPage(
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
    );
  }
}

class ReviewStats {
  final double avgRating;
  final int totalReviews;
  final int star5;
  final int star4;
  final int star3;
  final int star2;
  final int star1;

  const ReviewStats({
    required this.avgRating,
    required this.totalReviews,
    required this.star5,
    required this.star4,
    required this.star3,
    required this.star2,
    required this.star1,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      avgRating: (json['avgRating'] is num)
          ? (json['avgRating'] as num).toDouble()
          : double.tryParse(json['avgRating']?.toString() ?? '0') ?? 0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      star5: json['star5'] as int? ?? 0,
      star4: json['star4'] as int? ?? 0,
      star3: json['star3'] as int? ?? 0,
      star2: json['star2'] as int? ?? 0,
      star1: json['star1'] as int? ?? 0,
    );
  }

  int getStarCount(int star) {
    switch (star) {
      case 5:
        return star5;
      case 4:
        return star4;
      case 3:
        return star3;
      case 2:
        return star2;
      case 1:
        return star1;
      default:
        return 0;
    }
  }
}
