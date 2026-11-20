import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/forum_post.dart';

class ForumApiException implements Exception {
  const ForumApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ForumApi {
  ForumApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query);

  Future<List<ForumPost>> fetchPosts({String search = ''}) async {
    final query = <String, String>{
      if (search.trim().isNotEmpty) 'search': search.trim(),
    };
    final data = await _get(_uri('/api/forum/posts/', query));
    return _asList(data)
        .map((item) => ForumPost.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ForumPost> fetchPost(int id) async {
    final data = await _get(_uri('/api/forum/posts/$id/'));
    return ForumPost.fromJson(data);
  }

  Future<ForumPost> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    try {
      final response = await _client.post(
        _uri('/api/forum/posts/'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'category': category,
        }),
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ForumApiException(
          'Silakan masuk terlebih dahulu untuk membuat postingan.',
        );
      }
      if (response.statusCode != 201) {
        throw ForumApiException('Postingan gagal dibuat (HTTP ${response.statusCode}).');
      }
      return ForumPost.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on ForumApiException {
      rethrow;
    } on FormatException {
      throw const ForumApiException('Respons server bukan JSON yang valid.');
    } catch (_) {
      throw const ForumApiException('Tidak bisa terhubung ke server Forum.');
    }
  }

  Future<List<ForumComment>> fetchComments(int postId) async {
    final data = await _get(
      _uri('/api/forum/comments/', {'post': '$postId'}),
    );
    return _asList(data)
        .map((item) => ForumComment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic> && data['results'] is List<dynamic>) {
      return data['results'] as List<dynamic>;
    }
    throw const ForumApiException('Format respons Forum tidak dikenali.');
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );
      if (response.statusCode == 404) {
        throw const ForumApiException('Diskusi tidak ditemukan.');
      }
      if (response.statusCode != 200) {
        throw ForumApiException('Server membalas HTTP ${response.statusCode}.');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
      // List responses are wrapped so callers can share the same JSON parser.
      if (decoded is List<dynamic>) return {'results': decoded};
      throw const ForumApiException('Format respons Forum tidak dikenali.');
    } on ForumApiException {
      rethrow;
    } on FormatException {
      throw const ForumApiException('Respons server bukan JSON yang valid.');
    } catch (_) {
      throw const ForumApiException('Tidak bisa terhubung ke server Forum.');
    }
  }
}
