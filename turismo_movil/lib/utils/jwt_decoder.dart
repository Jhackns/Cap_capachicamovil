import 'dart:convert';

class JwtDecoder {
  /// Decode a JWT token and return its payload as a Map
  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid payload');
    }

    return payloadMap;
  }

  /// Decode Base64 string
  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }

    return utf8.decode(base64Url.decode(output));
  }

  /// Check if a token is expired
  static bool isExpired(String token) {
    final payload = decode(token);
    if (payload.containsKey('exp')) {
      final exp = payload['exp'];
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return now > exp;
    }
    return false;
  }

  /// Get the expiration date of a token
  static DateTime? getExpirationDate(String token) {
    final payload = decode(token);
    if (payload.containsKey('exp')) {
      final exp = payload['exp'];
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    }
    return null;
  }

  /// Get a specific claim from the token
  static dynamic getClaim(String token, String claimKey) {
    final payload = decode(token);
    return payload[claimKey];
  }
}
