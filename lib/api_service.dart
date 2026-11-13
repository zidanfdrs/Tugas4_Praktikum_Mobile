import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tugas4_praktikum/article_model.dart';

class ApiService {
  Future<List<ArticleModel>> fetchArticles() async {
    final uri = Uri.https('api.gdeltproject.org', '/api/v2/doc/doc', {
      'query': 'food OR restaurant OR recipe',
      'mode': 'ArtList',
      'format': 'json',
      'maxrecords': '30',
      'sort': 'HybridRel',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const FormatException('Respons berita tidak valid.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format data berita tidak dikenali.');
    }

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat berita (HTTP ${response.statusCode}).');
    }

    final rawArticles = decoded['articles'];
    if (rawArticles is! List<dynamic>) {
      throw const FormatException('Daftar berita tidak ditemukan.');
    }

    return rawArticles.whereType<Map<String, dynamic>>().map((article) {
      final domain = article['domain'];
      return ArticleModel(
        judul: article['title'] is String &&
                (article['title'] as String).trim().isNotEmpty
            ? article['title'] as String
            : 'Judul tidak tersedia',
        deskripsi: domain is String && domain.isNotEmpty
            ? 'Sumber: $domain'
            : null,
        urlToImage: article['socialimage'] is String
            ? article['socialimage'] as String
            : null,
      );
    }).toList();
  }
}
