import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui_kembali_mobile/models/chat.dart';
import 'package:ui_kembali_mobile/models/catalog_filter.dart';
import 'package:ui_kembali_mobile/models/item.dart';
import 'package:ui_kembali_mobile/models/transaction.dart';
import 'package:ui_kembali_mobile/screens/chat/chat_conversation_page.dart';
import 'package:ui_kembali_mobile/screens/chat/chat_inbox_page.dart';
import 'package:ui_kembali_mobile/screens/transactions/transaction_history_page.dart';
import 'package:ui_kembali_mobile/screens/home_page.dart';
import 'package:ui_kembali_mobile/screens/home_shell.dart';
import 'package:ui_kembali_mobile/screens/katalog/catalog_page.dart';
import 'package:ui_kembali_mobile/services/chat_api.dart';
import 'package:ui_kembali_mobile/services/katalog_api.dart';
import 'package:ui_kembali_mobile/theme.dart';

Map<String, dynamic> _row({String id = 'a1', String name = 'Buku Kalkulus', String type = 'JUAL', int? price = 150000}) => {'id': id, 'owner': 'Nadia', 'is_owner': false, 'name': name, 'description': 'Edisi 9, masih mulus.', 'category_label': 'Buku', 'condition_label': 'Baik', 'photo_url': '', 'location_name': 'Kampus UI', 'latitude': -6.36, 'longitude': 106.83, 'transaction_type': type, 'price': price, 'status': 'TERSEDIA'};

/// Records every requested Uri so tests can check the query string.
class _Recorder {
  final seen = <Uri>[];

  KatalogApi api(List<Map<String, dynamic>> rows, {int status = 200}) {
    return KatalogApi(
      baseUrl: 'http://test',
      client: MockClient((request) async {
        seen.add(request.url);
        final body = request.url.path.endsWith('/items/') ? {'count': rows.length, 'page': 1, 'num_pages': 1, 'results': rows} : rows.first;
        return http.Response(jsonEncode(body), status);
      }),
    );
  }
}

Widget _app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

/// A tall phone screen, so lazily built list items are on screen.
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(412, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('Item', () {
    test('parses the API row and formats the price', () {
      final item = Item.fromJson(_row());
      expect(item.priceLabel, 'Rp150.000');
      expect(item.contact, isNull); // guests get no contact
    });

    test('free items show "Gratis"', () {
      final item = Item.fromJson(_row(type: 'ADOPSI', price: null));
      expect(item.priceLabel, 'Gratis');
    });
  });

  group('KatalogApi', () {
    test('sends every filter as a query parameter', () async {
      final recorder = _Recorder();
      await recorder
          .api([])
          .fetchItems(
            filter: const CatalogFilter(query: 'buku', category: 'BUKU', type: 'ADOPSI', condition: 'BAIK', location: 'FMIPA', sort: 'price_asc'),
            page: 2,
          );
      expect(recorder.seen.single.path, '/api/v1/items/');
      expect(recorder.seen.single.queryParameters, {'q': 'buku', 'category': 'BUKU', 'type': 'ADOPSI', 'condition': 'BAIK', 'location': 'FMIPA', 'sort': 'price_asc', 'page': '2'});
    });

    test('maps a server error to ApiException', () {
      expect(_Recorder().api([_row()], status: 500).fetchItems(), throwsA(isA<ApiException>()));
    });
  });

  group('ChatApi', () {
    final conversationJson = {'id': 'conversation-1', 'item_id': 'item-1', 'item_name': 'Kipas meja', 'buyer': 'Axel', 'seller': 'Nadia', 'latest_message': 'Masih tersedia?', 'unread_count': 2, 'updated_at': '2026-10-01T05:00:00Z'};

    final messageJson = {'id': 'message-1', 'sender_id': 1, 'sender_name': 'Nadia', 'body': 'Masih tersedia?', 'sent_at': '2026-10-01T05:12:00Z', 'read_at': null, 'is_read': false};

    test('calls list, create, message history, and send endpoints', () async {
      final requests = <http.Request>[];
      final api = ChatApi(
        baseUrl: 'http://test',
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'POST' && request.url.path.endsWith('/messages/')) {
            return http.Response(
              jsonEncode({
                'message': {...messageJson, 'id': 'message-2'},
              }),
              201,
            );
          }
          if (request.method == 'POST') {
            return http.Response(jsonEncode(conversationJson), 201);
          }
          if (request.url.path.endsWith('/messages/')) {
            return http.Response(
              jsonEncode({
                'messages': [messageJson],
              }),
              200,
            );
          }
          return http.Response(jsonEncode([conversationJson]), 200);
        }),
      );

      expect((await api.fetchConversations()).single.unreadCount, 2);
      expect((await api.openConversation('item-1')).id, 'conversation-1');
      expect((await api.fetchMessages('conversation-1')).single.body, 'Masih tersedia?');
      expect((await api.sendMessage('conversation-1', 'Halo')).id, 'message-2');

      expect(requests.map((request) => '${request.method} ${request.url.path}'), ['GET /api/v1/chat/conversations/', 'POST /api/v1/chat/conversations/', 'GET /api/v1/chat/conversations/conversation-1/messages/', 'POST /api/v1/chat/conversations/conversation-1/messages/']);
      expect(jsonDecode(requests[1].body), {'item': 'item-1'});
      expect(jsonDecode(requests[3].body), {'body': 'Halo'});
    });

    test('reports unauthenticated responses as requiring login', () async {
      final api = ChatApi(baseUrl: 'http://test', client: MockClient((_) async => http.Response('{}', 403)));
      await expectLater(api.fetchConversations(), throwsA(isA<ApiException>().having((e) => e.needsLogin, 'needsLogin', true)));
    });

    testWidgets('inbox shows conversations returned by the API', (tester) async {
      final api = ChatApi(baseUrl: 'http://test', client: MockClient((_) async => http.Response(jsonEncode([conversationJson]), 200)));
      await tester.pumpWidget(_app(ChatInboxPage(api: api)));
      await tester.pumpAndSettle();

      expect(find.text('Pesan'), findsOneWidget);
      expect(find.text('Kipas meja'), findsOneWidget);
      expect(find.text('Axel · Nadia'), findsOneWidget);
      expect(find.text('Masih tersedia?'), findsOneWidget);
    });

    testWidgets('renders messages and sends from the conversation page', (tester) async {
      _phone(tester);
      final requests = <http.Request>[];
      final api = ChatApi(
        baseUrl: 'http://test',
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'POST') {
            return http.Response(
              jsonEncode({
                'message': {...messageJson, 'id': 'message-2', 'sender_id': 2, 'sender_name': 'Axel', 'body': 'Saya ambil besok.', 'is_read': false},
              }),
              201,
            );
          }
          return http.Response(
            jsonEncode({
              'messages': [messageJson],
            }),
            200,
          );
        }),
      );
      final conversation = ChatConversation.fromJson(conversationJson);
      final item = Item.fromJson({..._row(name: 'Kipas meja'), 'owner': 'Nadia'});
      await tester.pumpWidget(_app(ChatConversationPage(conversation: conversation, item: item, chatApi: api, autoRefresh: false)));
      await tester.pumpAndSettle();

      expect(find.text('Nadia'), findsOneWidget);
      expect(find.text('Masih tersedia?'), findsOneWidget);
      expect(find.text('1 Oktober 2026'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Saya ambil besok.');
      await tester.tap(find.text('Kirim pesan'));
      await tester.pumpAndSettle();

      expect(find.text('Saya ambil besok.'), findsOneWidget);
      expect(jsonDecode(requests.last.body), {'body': 'Saya ambil besok.'});
    });
  });

  group('Jelajahi', () {
    testWidgets('lists items with badge and price', (tester) async {
      await tester.pumpWidget(_app(CatalogPage(api: _Recorder().api([_row()]))));
      await tester.pumpAndSettle();
      expect(find.text('Buku Kalkulus'), findsOneWidget);
      expect(find.text('Dijual'), findsWidgets);
      expect(find.text('Rp150.000'), findsOneWidget);
      expect(find.text('Baik · Kampus UI'), findsOneWidget);
    });

    testWidgets('Gratis chip refetches with type=ADOPSI', (tester) async {
      final recorder = _Recorder();
      await tester.pumpWidget(_app(CatalogPage(api: recorder.api([_row()]))));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Gratis'));
      await tester.pumpAndSettle();
      expect(recorder.seen.last.queryParameters['type'], 'ADOPSI');
    });

    testWidgets('"Terapkan filter" sends the panel values', (tester) async {
      final recorder = _Recorder();
      await tester.pumpWidget(_app(CatalogPage(api: recorder.api([_row()]))));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Lokasi'), 'FMIPA');
      await tester.tap(find.text('Terapkan filter'));
      await tester.pumpAndSettle();
      expect(recorder.seen.last.queryParameters['location'], 'FMIPA');
    });

    testWidgets('applies a filter sent from Beranda', (tester) async {
      final recorder = _Recorder();
      final api = recorder.api([_row()]);
      await tester.pumpWidget(_app(CatalogPage(api: api, request: const CatalogFilter())));
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        _app(
          CatalogPage(
            api: api,
            request: const CatalogFilter(category: 'BUKU', id: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(recorder.seen.last.queryParameters['category'], 'BUKU');
    });

    testWidgets('shows the empty state', (tester) async {
      await tester.pumpWidget(_app(CatalogPage(api: _Recorder().api([]))));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada barang yang cocok.'), findsOneWidget);
    });

    testWidgets('shows an error with a retry button', (tester) async {
      await tester.pumpWidget(_app(CatalogPage(api: _Recorder().api([], status: 500))));
      await tester.pumpAndSettle();
      expect(find.text('Coba lagi'), findsOneWidget);
    });

    testWidgets('opens the detail page', (tester) async {
      _phone(tester);
      await tester.pumpWidget(_app(CatalogPage(api: _Recorder().api([_row()]))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buku Kalkulus'));
      await tester.pumpAndSettle();
      expect(find.text('Detail barang'), findsOneWidget);
      expect(find.text('Kontak · Masuk untuk melihat kontak'), findsOneWidget);
      expect(find.text('Lokasi temu · Kampus UI'), findsOneWidget);
      expect(find.text('Ajukan pembelian'), findsOneWidget);
      expect(find.text('Chat pemilik'), findsOneWidget);
    });

    testWidgets('starts a conversation from item detail', (tester) async {
      _phone(tester);
      final chatApi = ChatApi(
        baseUrl: 'http://test',
        client: MockClient((request) async {
          if (request.method == 'POST') {
            return http.Response(jsonEncode({'id': 'conversation-1', 'item_id': 'a1', 'item_name': 'Buku Kalkulus', 'buyer': 'Axel', 'seller': 'Nadia', 'latest_message': null, 'unread_count': 0, 'updated_at': '2026-10-01T05:00:00Z'}), 201);
          }
          return http.Response(jsonEncode({'messages': []}), 200);
        }),
      );
      await tester.pumpWidget(_app(CatalogPage(api: _Recorder().api([_row()]), chatApi: chatApi)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buku Kalkulus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chat pemilik'));
      await tester.pumpAndSettle();

      expect(find.text('Chat barang'), findsOneWidget);
      expect(find.text('Tulis pesan...'), findsOneWidget);
      expect(find.text('Buku Kalkulus'), findsOneWidget);
    });
  });

  group('Beranda', () {
    testWidgets('shows hero, shortcuts and featured items', (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: HomePage(onExplore: (_) {}, api: _Recorder().api([_row()])),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Temukan kebutuhan kuliah tanpa mulai dari baru.'), findsOneWidget);
      expect(find.text('Buku kuliah'), findsOneWidget);
      expect(find.text('Pilihan untuk kamu'), findsOneWidget);
      expect(find.text('Buku Kalkulus'), findsOneWidget);
    });

    testWidgets('shortcut chip hands its filter to Jelajahi', (tester) async {
      _phone(tester);
      CatalogFilter? received;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: HomePage(onExplore: (f) => received = f, api: _Recorder().api([_row()])),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gratis diambil'));
      expect(received?.type, 'ADOPSI');
    });
  });

  group('Riwayat transaksi', () {
    Map<String, dynamic> txRow({String status = 'DITERIMA', String role = 'requester', String type = 'JUAL', String name = 'Kipas Meja Cosmos 9 inci'}) => {'id': 't-$name', 'role': role, 'counterpart': 'Raka Adiputra', 'status': status, 'updated_at': '2026-10-01T05:00:00Z', 'item': _row(name: name, type: type, price: type == 'JUAL' ? 85000 : null)};

    KatalogApi txApi(_Recorder recorder, List<Map<String, dynamic>> rows, {int status = 200}) {
      return KatalogApi(
        baseUrl: 'http://test',
        client: MockClient((request) async {
          recorder.seen.add(request.url);
          final body = {'count': rows.length, 'page': 1, 'num_pages': 1, 'results': rows};
          return http.Response(jsonEncode(body), status);
        }),
      );
    }

    test('summary reads like the design', () {
      final bought = Transaction.fromJson(txRow());
      expect(bought.summary, 'Membeli dari Raka Adiputra · 1 Okt 2026');
      expect(bought.statusLabel, 'Menunggu temu');
      expect(Transaction.fromJson(txRow(type: 'ADOPSI')).summary, startsWith('Diadopsi dari'));
      expect(Transaction.fromJson(txRow(role: 'owner')).summary, startsWith('Dijual kepada'));
      expect(Transaction.fromJson(txRow(role: 'owner', type: 'ADOPSI')).summary, startsWith('Diberikan kepada'));
    });

    testWidgets('lists transactions with the right button per status', (tester) async {
      _phone(tester);
      final api = txApi(_Recorder(), [txRow(), txRow(status: 'SELESAI', name: 'Buku Psikologi Sosial')]);
      await tester.pumpWidget(_app(TransactionHistoryPage(api: api)));
      await tester.pumpAndSettle();
      expect(find.text('Perjalanan barangmu'), findsOneWidget);
      expect(find.text('Menunggu temu'), findsOneWidget);
      expect(find.text('Buka chat transaksi'), findsOneWidget);
      expect(find.text('Lihat detail transaksi'), findsOneWidget);
    });

    testWidgets('Adopsi filter refetches with type=ADOPSI', (tester) async {
      _phone(tester);
      final recorder = _Recorder();
      await tester.pumpWidget(_app(TransactionHistoryPage(api: txApi(recorder, [txRow()]))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adopsi'));
      await tester.pumpAndSettle();
      expect(recorder.seen.last.path, '/api/v1/transactions/');
      expect(recorder.seen.last.queryParameters['type'], 'ADOPSI');
    });

    testWidgets('asks guests to log in', (tester) async {
      await tester.pumpWidget(_app(TransactionHistoryPage(api: txApi(_Recorder(), [], status: 403))));
      await tester.pumpAndSettle();
      expect(find.text('Masuk dulu untuk melihat riwayat transaksimu.'), findsOneWidget);
    });

    testWidgets('opens the conversation from an active transaction', (tester) async {
      _phone(tester);
      final conversation = {'id': 'conversation-1', 'item_id': 'a1', 'item_name': 'Kipas Meja Cosmos 9 inci', 'buyer': 'Axel', 'seller': 'Raka Adiputra', 'latest_message': 'Masih tersedia?', 'unread_count': 0, 'updated_at': '2026-10-01T05:00:00Z'};
      final chatApi = ChatApi(
        baseUrl: 'http://test',
        client: MockClient((request) async {
          if (request.method == 'POST') {
            return http.Response(jsonEncode(conversation), 201);
          }
          return http.Response(jsonEncode({'messages': []}), 200);
        }),
      );
      await tester.pumpWidget(_app(TransactionHistoryPage(api: txApi(_Recorder(), [txRow()]), chatApi: chatApi)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buka chat transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Chat barang'), findsOneWidget);
      expect(find.text('Tulis pesan...'), findsOneWidget);
    });
  });

  testWidgets('shell: nav reaches every tab', (tester) async {
    await tester.pumpWidget(_app(const HomeShell()));
    // No real server in tests: pages fall into their error state, which is fine here.
    await tester.pump();
    for (final label in ['Jelajahi', 'Transaksi', 'Forum', 'Profil']) {
      await tester.tap(find.text(label).last);
      await tester.pump();
    }
    expect(find.text('Dikerjakan oleh Elvis Sestomi'), findsOneWidget);
  });
}
