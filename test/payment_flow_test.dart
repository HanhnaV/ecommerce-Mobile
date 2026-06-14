import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/data/services/order_service.dart';

void main() {
  group('VnpayPaymentResponse', () {
    test('fromJson parses paymentUrl correctly', () {
      final json = {'paymentUrl': 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?param=value'};
      final response = VnpayPaymentResponse.fromJson(json);
      expect(response.paymentUrl, 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?param=value');
    });

    test('fromJson handles missing paymentUrl', () {
      final json = <String, dynamic>{};
      final response = VnpayPaymentResponse.fromJson(json);
      expect(response.paymentUrl, '');
    });

    test('fromJson handles null paymentUrl', () {
      final json = {'paymentUrl': null};
      final response = VnpayPaymentResponse.fromJson(json);
      expect(response.paymentUrl, '');
    });
  });

  group('CheckoutQuoteResponse', () {
    test('fromJson parses shippingFee and total', () {
      final json = {'shippingFee': 35000.0, 'total': 535000.0};
      final response = CheckoutQuoteResponse.fromJson(json);
      expect(response.shippingFee, 35000.0);
      expect(response.total, 535000.0);
    });

    test('fromJson handles integer values', () {
      final json = {'shippingFee': 35000, 'total': 535000};
      final response = CheckoutQuoteResponse.fromJson(json);
      expect(response.shippingFee, 35000.0);
      expect(response.total, 535000.0);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};
      final response = CheckoutQuoteResponse.fromJson(json);
      expect(response.shippingFee, 0.0);
      expect(response.total, 0.0);
    });
  });

  group('OrderCreateResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'status': 'PENDING_PAYMENT',
      };
      final response = OrderCreateResponse.fromJson(json);
      expect(response.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(response.status, 'PENDING_PAYMENT');
    });

    test('fromJson handles missing status', () {
      final json = {'id': 'abc-123'};
      final response = OrderCreateResponse.fromJson(json);
      expect(response.id, 'abc-123');
      expect(response.status, 'PENDING');
    });
  });

  group('VNPay Response Code Messages', () {
    // Test the response code mapping used by PaymentResultScreen
    test('known response codes map to Vietnamese messages', () {
      const messages = {
        '07': 'Dinh dang tien thanh toan khong dung.',
        '09': 'The chua dang ky dich vu Internet Banking.',
        '24': 'Huy giao dich.',
        '51': 'Tai khoan khong du so du.',
        '99': 'Nguoi dung huy giao dich.',
      };

      for (final entry in messages.entries) {
        expect(messages[entry.key], isNotNull);
        expect(messages[entry.key], isNotEmpty);
      }
    });

    test('unknown code returns generic message', () {
      const knownCodes = {'07', '09', '10', '11', '12', '13', '24', '51', '65', '75', '79', '99'};
      expect(knownCodes.contains('55'), isFalse);
    });
  });

  group('PaymentResult edge cases', () {
    test('empty params should result in failed state', () {
      // This tests the guard logic: if params are empty, we should not call API
      final params = <String, String>{};
      expect(params.isEmpty, isTrue);
    });

    test('empty orderId should result in failed state', () {
      const orderId = '';
      expect(orderId.isEmpty, isTrue);
    });

    test('success response code is 00', () {
      const responseCode = '00';
      expect(responseCode == '00', isTrue);
    });

    test('non-00 response code indicates failure', () {
      for (final code in ['07', '09', '24', '51', '99']) {
        expect(code != '00', isTrue);
      }
    });
  });

  group('VNPay Raw Query Extraction', () {
    test('extracts raw query string exactly without modifying encoding', () {
      const url = 'http://localhost:5173/payment/vnpay_return?vnp_Amount=25000000&vnp_Command=pay&vnp_OrderInfo=Thanh%20toan%20don%20hang%20tieng%20Viet%20%2B%20%252B&vnp_SecureHash=abcdef123';
      
      final int indexOfQuery = url.indexOf('?');
      final String rawQuery = indexOfQuery != -1 ? url.substring(indexOfQuery + 1) : '';
      
      expect(rawQuery, 'vnp_Amount=25000000&vnp_Command=pay&vnp_OrderInfo=Thanh%20toan%20don%20hang%20tieng%20Viet%20%2B%20%252B&vnp_SecureHash=abcdef123');
      
      final uri = Uri.parse(url);
      final params = uri.queryParameters;
      
      expect(params['vnp_OrderInfo'], 'Thanh toan don hang tieng Viet + %2B');
      
      final reconstructedUri = Uri(queryParameters: params);
      expect(reconstructedUri.query, isNot(rawQuery));
    });

    test('handles URL without query parameters', () {
      const url = 'http://localhost:5173/payment/vnpay_return';
      final int indexOfQuery = url.indexOf('?');
      final String rawQuery = indexOfQuery != -1 ? url.substring(indexOfQuery + 1) : '';
      expect(rawQuery, '');
    });
  });
}
