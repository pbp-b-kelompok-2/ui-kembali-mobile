import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/catalog_filter.dart';
import '../models/item.dart';
import '../models/transaction.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.needsLogin = false});
  final String message;

  /// The server answered 401/403: the user has to log in first.
  final bool needsLogin;

  @override
  String toString() => message;
}

/// Calls the Django REST Framework endpoints of the katalog module.
class KatalogApi {
  KatalogApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query);

  /// `GET /api/v1/items/` with the same filters as the website catalog.
  Future<ItemPage> fetchItems({
    CatalogFilter filter = const CatalogFilter(),
    int page = 1,
  }) async {
    final params = {
      if (filter.query.isNotEmpty) 'q': filter.query,
      if (filter.category.isNotEmpty) 'category': filter.category,
      if (filter.type.isNotEmpty) 'type': filter.type,
      if (filter.condition.isNotEmpty) 'condition': filter.condition,
      if (filter.location.isNotEmpty) 'location': filter.location,
      if (filter.sort.isNotEmpty) 'sort': filter.sort,
      'page': '$page',
    };
    final json = await _get(_uri('/api/v1/items/', params));
    return ItemPage.fromJson(json);
  }

  /// `GET /api/v1/transactions/` (login required). [type] is ADOPSI or JUAL.
  Future<TransactionPage> fetchTransactions({String type = '', int page = 1}) async {
    final params = {if (type.isNotEmpty) 'type': type, 'page': '$page'};
    final json = await _get(_uri('/api/v1/transactions/', params));
    return TransactionPage.fromJson(json);
  }

  /// `GET /api/v1/items/<id>/`
  Future<Item> fetchItem(String id) async {
    final json = await _get(_uri('/api/v1/items/$id/'));
    return Item.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ApiException('Masuk dulu untuk melanjutkan.', needsLogin: true);
      }
      if (response.statusCode == 404) {
        throw const ApiException('Barang tidak ditemukan.');
      }
      if (response.statusCode != 200) {
        throw ApiException('Server membalas HTTP ${response.statusCode}.');
      }
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Respons server tidak valid.');
    } catch (_) {
      throw const ApiException('Tidak bisa terhubung ke server.');
    }
  }
}
