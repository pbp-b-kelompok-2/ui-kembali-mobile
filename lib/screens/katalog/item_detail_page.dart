import 'package:material_ui/material_ui.dart';

import '../../models/item.dart';
import '../../services/katalog_api.dart';

/// Detail of one barang, loaded from `GET /api/v1/items/<id>/`.
class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.item, this.api});

  final Item item;
  final KatalogApi? api;

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late final KatalogApi _api = widget.api ?? KatalogApi();
  late Future<Item> _future = _api.fetchItem(widget.item.id);

  void _retry() => setState(() => _future = _api.fetchItem(widget.item.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail barang')),
      body: FutureBuilder<Item>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${snapshot.error}'),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: _retry, child: const Text('Coba lagi')),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _ItemDetail(item: snapshot.data!);
        },
      ),
    );
  }
}

class _ItemDetail extends StatelessWidget {
  const _ItemDetail({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (item.photoUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                item.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Colors.black12,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(item.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          item.priceLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(item.categoryLabel)),
            Chip(label: Text(item.conditionLabel)),
            Chip(label: Text(item.isAvailable ? 'Tersedia' : item.status)),
          ],
        ),
        const SizedBox(height: 12),
        Text(item.description),
        const Divider(height: 32),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.place_outlined),
          title: Text(item.locationName),
          subtitle: const Text('Lokasi temu'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: Text(item.owner),
          subtitle: const Text('Pemilik'),
        ),
        // The API only returns contact info to logged-in users.
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.phone_outlined),
          title: Text(item.contact ?? 'Masuk untuk melihat kontak'),
          subtitle: const Text('Kontak'),
        ),
      ],
    );
  }
}
