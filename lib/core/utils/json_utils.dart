import 'dart:convert';

class JsonUtils {
  JsonUtils._();

  static String encodeList(List<String> list) {
    return jsonEncode(list);
  }

  static List<String> decodeList(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Map<String, dynamic>? tryDecode(String json) {
    try {
      return jsonDecode(json) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  static String prettyEncode(dynamic data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }
}
