import 'package:material_ui/material_ui.dart';

import '../../models/transaction.dart';
import '../../services/katalog_api.dart';
import '../../theme.dart';
import '../katalog/item_detail_page.dart';

/// "Riwayat transaksi": every request the user made or received.
class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key, this.api, this.onBack});

  final KatalogApi? api;
  final VoidCallback? onBack;

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  static const _filters = {'': 'Semua', 'JUAL': 'Pembelian', 'ADOPSI': 'Adopsi'};

  late final KatalogApi _api = widget.api ?? KatalogApi();
  final _scroll = ScrollController();

  String _type = '';
  List<Transaction> _rows = const [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  ApiException? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400 && _hasMore && !_loading) _load();
    });
    _load(reset: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _generation++;
      _page = 0;
      _hasMore = true;
      _rows = const [];
    }
    final generation = _generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.fetchTransactions(type: _type, page: _page + 1);
      if (!mounted || generation != _generation) return;
      setState(() {
        _rows = [..._rows, ...result.results];
        _page = result.page;
        _hasMore = result.hasMore;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _select(String type) {
    if (type == _type) return;
    _type = type;
    _load(reset: true);
  }

  void _openChat() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Chat transaksi segera hadir.')));
  }

  void _openDetail(Transaction row) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ItemDetailPage(item: row.item, api: _api)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.onBack == null
            ? null
            : IconButton(icon: const Icon(Icons.chevron_left, size: 30), onPressed: widget.onBack),
        title: const Text('Riwayat transaksi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const Text(
              'Perjalanan barangmu',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            const Text(
              'Setiap transaksi menjaga manfaat tetap berputar.',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final entry in _filters.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: InkWell(
                      onTap: () => _select(entry.key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                            decoration: entry.key == _type ? TextDecoration.underline : null,
                            decorationColor: AppColors.green,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ..._content(),
          ],
        ),
      ),
    );
  }

  List<Widget> _content() {
    if (_rows.isEmpty && _loading) {
      return const [Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))];
    }
    if (_rows.isEmpty && _error != null) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              _error!.needsLogin ? 'Masuk dulu untuk melihat riwayat transaksimu.' : _error!.message,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (!_error!.needsLogin)
          Center(child: TextButton(onPressed: () => _load(reset: true), child: const Text('Coba lagi'))),
      ];
    }
    if (_rows.isEmpty) {
      return const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Belum ada transaksi.')))];
    }
    return [
      for (final row in _rows)
        _TransactionCard(
          row: row,
          onAction: () => row.isOpen ? _openChat() : _openDetail(row),
        ),
      if (_loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
    ];
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.row, required this.onAction});

  final Transaction row;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(aspectRatio: 16 / 7, child: _Photo(url: row.item.photoUrl)),
            ),
            const SizedBox(height: 12),
            _StatusPill(status: row.status, label: row.statusLabel),
            const SizedBox(height: 10),
            Text(
              row.item.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text(row.summary, style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onAction,
                child: Text(row.isOpen ? 'Buka chat transaksi' : 'Lihat detail transaksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: AppColors.subtle,
      child: Center(child: Icon(Icons.image_outlined, color: AppColors.muted, size: 32)),
    );
    if (url.isEmpty) return placeholder;
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder);
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.label});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      'SELESAI' => (AppColors.greenTint, AppColors.greenDark),
      'DITOLAK' || 'DIBATALKAN' => (const Color(0xFFFBEAEA), const Color(0xFFB53D3D)),
      _ => (const Color(0xFFE7F1FA), const Color(0xFF2769A8)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
