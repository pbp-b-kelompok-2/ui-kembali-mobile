import 'package:material_ui/material_ui.dart';

import '../models/catalog_filter.dart';
import '../models/item.dart';
import '../services/katalog_api.dart';
import '../theme.dart';
import '../widgets/item_card.dart';
import 'katalog/item_detail_page.dart';

const _featuredCount = 5;

/// "Beranda": greeting, search, hero, category shortcuts, and featured items.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onExplore, this.api});

  /// Switches to the Jelajahi tab with the given filter applied.
  final ValueChanged<CatalogFilter> onExplore;
  final KatalogApi? api;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final KatalogApi _api = widget.api ?? KatalogApi();
  late Future<ItemPage> _future = _api.fetchItems();

  void _reload() => setState(() => _future = _api.fetchItems());

  void _openItem(Item item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ItemDetailPage(item: item, api: _api)),
    );
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Fitur pasang barang segera hadir.')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future.then((_) {}, onError: (_) {});
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  const _Brand(),
                  const SizedBox(height: 20),
                  const Text('Halo!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  const Text('Ada yang kamu butuhkan hari ini?', style: TextStyle(color: AppColors.inkSoft)),
                  const SizedBox(height: 16),
                  _SearchField(onSubmitted: (q) => widget.onExplore(CatalogFilter(query: q.trim()))),
                  const SizedBox(height: 16),
                  _Hero(onTap: () => widget.onExplore(const CatalogFilter())),
                  const SizedBox(height: 16),
                  _Shortcuts(onExplore: widget.onExplore),
                  const SizedBox(height: 24),
                  const Text('Pilihan untuk kamu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 12),
                  _Featured(future: _future, onRetry: _reload, onOpen: _openItem),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _comingSoon,
                icon: const Icon(Icons.add),
                label: const Text('Pasang barang'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.recycling, color: AppColors.ink),
        ),
        const SizedBox(width: 10),
        const Text('UIKembali', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onSubmitted});

  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Cari buku, elektronik, furnitur kos…',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SEMESTER BARU, PILIH YANG SUDAH ADA',
            style: TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Temukan kebutuhan kuliah tanpa mulai dari baru.',
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.15),
          ),
          const SizedBox(height: 10),
          const Text(
            'Dari buku wajib sampai isi kamar kos, semuanya dari dan untuk warga UI.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.ink,
              ),
              child: const Text('Jelajahi semua barang'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts({required this.onExplore});

  final ValueChanged<CatalogFilter> onExplore;

  @override
  Widget build(BuildContext context) {
    final shortcuts = <(String, CatalogFilter)>[
      ('Buku kuliah', const CatalogFilter(category: 'BUKU')),
      ('Elektronik', const CatalogFilter(category: 'ELEKTRONIK')),
      ('Kebutuhan kos', const CatalogFilter(category: 'PERABOT')),
      ('Gratis diambil', const CatalogFilter(type: 'ADOPSI')),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (label, filter) in shortcuts)
          ActionChip(
            label: Text(label),
            onPressed: () => onExplore(filter),
            backgroundColor: AppColors.surface,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
      ],
    );
  }
}

class _Featured extends StatelessWidget {
  const _Featured({required this.future, required this.onRetry, required this.onOpen});

  final Future<ItemPage> future;
  final VoidCallback onRetry;
  final ValueChanged<Item> onOpen;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ItemPage>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            children: [
              Text('${snapshot.error}'),
              TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
            ],
          );
        }
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
        }
        final items = snapshot.data!.results.take(_featuredCount).toList();
        if (items.isEmpty) {
          return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Belum ada barang.')));
        }
        return Column(
          children: [for (final item in items) ItemCard(item: item, onTap: () => onOpen(item))],
        );
      },
    );
  }
}
