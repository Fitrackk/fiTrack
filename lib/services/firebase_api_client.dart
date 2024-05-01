import 'dart:convert';

import 'package:http/http.dart' as http;

class FirebaseApiClient {
  static const String _baseUrl = 'https://fitrack-7ee93.firebaseio.com';

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(Uri.parse('$_baseUrl$path.json'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data from Firebase');
    }
  }

  Future<void> post(String path, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path.json'),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to post data to Firebase');
    }
  }

  Future<void> put(String path, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$path.json'),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to put data to Firebase');
    }
  }

  Future<void> delete(String path) async {
    final response = await http.delete(Uri.parse('$_baseUrl$path.json'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete data from Firebase');
    }
  }
}
