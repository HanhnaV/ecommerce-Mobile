import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/core/utils/jwt_utils.dart';

void main() {
  final validToken = _buildJwt({'sub': '123', 'role': 'USER', 'accountVerified': true});
  final unverifiedToken = _buildJwt({'sub': '456', 'role': 'BUSINESS', 'accountVerified': false});
  final adminToken = _buildJwt({'sub': '789', 'role': 'ADMIN', 'accountVerified': true});

  group('getAccountVerified', () {
    test('returns true when accountVerified claim is true', () {
      expect(getAccountVerified(validToken), true);
    });

    test('returns false when accountVerified claim is false', () {
      expect(getAccountVerified(unverifiedToken), false);
    });

    test('returns false for invalid token', () {
      expect(getAccountVerified('invalid.token'), false);
      expect(getAccountVerified(''), false);
    });
  });

  group('getUserRole', () {
    test('returns USER role from valid token', () {
      expect(getUserRole(validToken), 'USER');
    });

    test('returns BUSINESS role from valid token', () {
      expect(getUserRole(unverifiedToken), 'BUSINESS');
    });

    test('returns ADMIN role from valid token', () {
      expect(getUserRole(adminToken), 'ADMIN');
    });

    test('returns null for invalid token', () {
      expect(getUserRole('bad.token'), null);
      expect(getUserRole(''), null);
    });
  });

  group('getUserId', () {
    test('returns sub claim from valid token', () {
      expect(getUserId(validToken), '123');
    });

    test('returns sub claim for unverified token', () {
      expect(getUserId(unverifiedToken), '456');
    });

    test('returns null for invalid token', () {
      expect(getUserId('invalid'), null);
      expect(getUserId(''), null);
    });
  });
}

String _buildJwt(Map<String, dynamic> payload) {
  final jsonStr = json.encode(payload);
  final encoded = base64Url.encode(utf8.encode(jsonStr)).replaceAll('=', '');
  return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$encoded.fake_signature';
}
