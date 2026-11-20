import 'package:material_ui/material_ui.dart';

import '../../models/item.dart';
import '../chat/chat_conversation_page.dart';
import '../../services/chat_api.dart';
import '../../services/katalog_api.dart';
import '../../theme.dart';

/// Detail of one barang, loaded from `GET /api/v1/items/<id>/`.
class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.item, this.api, this.chatApi});

  final Item item;
  final KatalogApi? api;
  final ChatApi? chatApi;

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late final KatalogApi _api = widget.api ?? KatalogApi();
  late final ChatApi _chatApi = widget.chatApi ?? ChatApi();
  late Future<Item> _future = _api.fetchItem(widget.item.id);

  void _retry() => setState(() => _future = _api.fetchItem(widget.item.id));

  Future<void> _openChat(Item item) async {
    try {
      final conversation = await _chatApi.openConversation(item.id);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatConversationPage(conversation: conversation, item: item, chatApi: _chatApi, katalogApi: _api),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.needsLogin ? 'Masuk dulu untuk memulai chat.' : error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(icon: const Icon(Icons.chevron_left, size: 30), onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('Detail barang', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
      ),
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
          return _ItemDetail(item: snapshot.data!, onChat: () => _openChat(snapshot.data!));
        },
      ),
    );
  }
}

class _ItemDetail extends StatelessWidget {
  const _ItemDetail({required this.item, required this.onChat});

  final Item item;
  final VoidCallback onChat;

  // Requests and chat belong to other modules; keep the buttons visible like the design.
  void _comingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final canRequest = !item.isOwner && item.isAvailable;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: _Photo(url: item.photoUrl),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Pill(label: item.isFree ? 'Gratis' : 'Dijual', background: item.isFree ? AppColors.greenTint : AppColors.yellow, foreground: item.isFree ? AppColors.greenDark : AppColors.ink),
            if (item.conditionLabel.isNotEmpty) _Pill(label: item.conditionLabel, background: AppColors.infoTint, foreground: AppColors.info),
            if (!item.isAvailable) _Pill(label: item.status == 'DIPESAN' ? 'Dipesan' : 'Selesai', background: AppColors.line, foreground: AppColors.inkSoft),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          item.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.15),
        ),
        const SizedBox(height: 14),
        Text(
          item.priceLabel,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.greenDark),
        ),
        const SizedBox(height: 14),
        Text(item.categoryLabel, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        if (item.description.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Tentang barang',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 10),
          Text(item.description, style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.inkSoft)),
        ],
        const SizedBox(height: 18),
        _InfoCard(
          lines: [
            'Lokasi temu · ${item.locationName}',
            // The API only returns contact info to logged-in users.
            'Kontak · ${item.contact ?? 'Masuk untuk melihat kontak'}',
          ],
        ),
        const SizedBox(height: 14),
        _OwnerCard(name: item.owner),
        const SizedBox(height: 14),
        const Text('Utamakan titik temu publik di kampus dan konfirmasi kondisi barang melalui chat.', style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.inkSoft)),
        const SizedBox(height: 16),
        if (canRequest) ...[
          FilledButton(
            onPressed: () => _comingSoon(context, 'Pengajuan segera hadir.'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.ink,
              minimumSize: const Size.fromHeight(46),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Align(alignment: Alignment.centerLeft, child: Text(item.isFree ? 'Ajukan adopsi' : 'Ajukan pembelian')),
          ),
          const SizedBox(height: 12),
        ],
        if (!item.isOwner)
          OutlinedButton(
            onPressed: onChat,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Align(alignment: Alignment.centerLeft, child: Text('Chat pemilik')),
          ),
      ],
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
      child: Center(child: Icon(Icons.image_outlined, color: AppColors.muted, size: 40)),
    );
    if (url.isEmpty) return placeholder;
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++) ...[if (i > 0) const SizedBox(height: 14), Text(lines[i], style: const TextStyle(fontSize: 14, color: AppColors.ink))],
        ],
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          const Text('Pemilik barang', style: TextStyle(fontSize: 14, color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}
