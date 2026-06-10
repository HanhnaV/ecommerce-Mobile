import 'dart:convert';

Map<String, dynamic> _decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    String payload = parts[1];
    payload = payload.replaceAll('-', '+').replaceAll('_', '/');
    while (payload.length % 4 != 0) {
      payload += '=';
    }
    final decoded = utf8.decode(base64Decode(payload));
    return json.decode(decoded) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

bool getAccountVerified(String token) {
  final payload = _decodeJwtPayload(token);
  return payload['accountVerified'] == true;
}

String? getUserRole(String token) {
  final payload = _decodeJwtPayload(token);
  return payload['role'] as String?;
}

String? getUserId(String token) {
  final payload = _decodeJwtPayload(token);
  return payload['sub'] as String?;
}
