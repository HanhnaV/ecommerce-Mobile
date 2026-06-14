import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum OrderStatus {
  pendingPayment('PENDING_PAYMENT', 'Chờ thanh toán', AppColors.warning),
  pending('PENDING', 'Chờ xác nhận', AppColors.pending),
  confirmed('CONFIRMED', 'Đã xác nhận', AppColors.confirmed),
  shipping('SHIPPING', 'Đang giao', AppColors.shipping),
  delivered('DELIVERED', 'Đã giao', AppColors.delivered),
  cancelled('CANCELLED', 'Đã hủy', AppColors.cancelled),
  refundRequested('REFUND_REQUESTED', 'Yêu cầu hoàn tiền', AppColors.warning),
  refunded('REFUNDED', 'Đã hoàn tiền', AppColors.info);

  final String code;
  final String displayText;
  final Color color;

  const OrderStatus(this.code, this.displayText, this.color);

  static OrderStatus fromCode(String code) {
    return OrderStatus.values.firstWhere(
      (s) => s.code == code,
      orElse: () => OrderStatus.pending,
    );
  }
}
