import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/chat.dart';
import 'katalog_api.dart';

/// Calls the Django REST Framework endpoints of the chat module.
class ChatApi {
  ChatApi({http.Client? client, String? baseUrl}) : _client = client ?? http.Client(), _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  /// `GET /api/v1/chat/conversations/` (login required).
  Future<List<ChatConversation>> fetchConversations() async {
    final json = await _request(_uri('/api/v1/chat/conversations/'));
    return (json as List<dynamic>).map((row) => ChatConversation.fromJson(row as Map<String, dynamic>)).toList();
  }

  /// `POST /api/v1/chat/conversations/`; the backend reuses an existing chat.
  Future<ChatConversation> openConversation(String itemId) async {
    final json = await _request(_uri('/api/v1/chat/conversations/'), method: 'POST', body: {'item': itemId});
    return ChatConversation.fromJson(json as Map<String, dynamic>);
  }

  /// `GET /api/v1/chat/conversations/<id>/messages/` marks incoming messages read.
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final json = await _request(_uri('/api/v1/chat/conversations/$conversationId/messages/')) as Map<String, dynamic>;
    return (json['messages'] as List<dynamic>).map((row) => ChatMessage.fromJson(row as Map<String, dynamic>)).toList();
  }

  /// `POST /api/v1/chat/conversations/<id>/messages/`.
  Future<ChatMessage> sendMessage(String conversationId, String body) async {
    final json = await _request(
      _uri('/api/v1/chat/conversations/$conversationId/messages/'),
      method: 'POST',
      body: {'body': body},
    ) as Map<String, dynamic>;
    return ChatMessage.fromJson(json['message'] as Map<String, dynamic>);
  }

  Future<dynamic> _request(Uri uri, {String method = 'GET', Map<String, String>? body}) async {
    try {
      final response = method == 'POST'
          ? await _client.post(
              uri,
              headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
          : await _client.get(uri, headers: const {'Accept': 'application/json'});
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ApiException('Masuk dulu untuk menggunakan chat.', needsLogin: true);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(_serverError(response));
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Respons server tidak valid.');
    } on Exception {
      throw const ApiException('Tidak bisa terhubung ke server.');
    }
  }

  String _serverError(http.Response response) {
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is Map<String, dynamic>) {
        final detail = payload['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
        for (final value in payload.values) {
          if (value is List && value.isNotEmpty) return value.first.toString();
          if (value is String && value.isNotEmpty) return value;
        }
      }
    } on FormatException {
      // Fall through to the HTTP status when the server does not return JSON.
    }
    return 'Server membalas HTTP ${response.statusCode}.';
  }
}
