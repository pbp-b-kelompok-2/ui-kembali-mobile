import 'item.dart';

/// One row of "Riwayat transaksi" from `GET /api/v1/transactions/`:
/// a request the user made (requester) or received (owner).
class Transaction {
  const Transaction({
    required this.id,
    required this.role,
    required this.counterpart,
    required this.status,
    required this.item,
    required this.updatedAt,
  });

  final String id;
  final String role; // requester | owner
  final String counterpart; // the other person
  final String status; // PENDING | DITERIMA | DITOLAK | DIBATALKAN | SELESAI
  final Item item;
  final DateTime updatedAt;

  bool get isRequester => role == 'requester';
  bool get isOpen => status == 'PENDING' || status == 'DITERIMA';

  String get statusLabel => switch (status) {
        'PENDING' => 'Menunggu balasan',
        'DITERIMA' => 'Menunggu temu',
        'SELESAI' => 'Selesai',
        'DITOLAK' => 'Ditolak',
        'DIBATALKAN' => 'Dibatalkan',
        _ => status,
      };

  /// "Membeli dari Raka · 1 Okt 2026", "Dijual kepada Bagas · 2 Sep 2026", …
  String get summary {
    final verb = switch ((isRequester, item.isFree)) {
      (true, false) => 'Membeli dari',
      (true, true) => 'Diadopsi dari',
      (false, false) => 'Dijual kepada',
      (false, true) => 'Diberikan kepada',
    };
    return '$verb $counterpart · ${formatDate(updatedAt)}';
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      role: json['role'] as String,
      counterpart: json['counterpart'] as String? ?? '',
      status: json['status'] as String,
      item: Item.fromJson(json['item'] as Map<String, dynamic>),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }
}

class TransactionPage {
  const TransactionPage({
    required this.page,
    required this.numPages,
    required this.results,
  });

  final int page;
  final int numPages;
  final List<Transaction> results;

  bool get hasMore => page < numPages;

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    return TransactionPage(
      page: json['page'] as int,
      numPages: json['num_pages'] as int,
      results: (json['results'] as List<dynamic>)
          .map((row) => Transaction.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// "1 Okt 2026"
String formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]} ${date.year}';
