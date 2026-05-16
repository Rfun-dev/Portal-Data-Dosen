import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dosen.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<Dosen>> fetchDosen() async {
    final uri = Uri.parse('$_baseUrl/users');
    final response = await http.get(uri).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Koneksi timeout. Periksa jaringan Anda.'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Dosen.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat data (HTTP ${response.statusCode})');
    }
  }
}
