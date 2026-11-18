import 'package:material_ui/material_ui.dart';

import '../models/item.dart';
import '../theme.dart';

/// Big photo card used by Beranda ("Pilihan untuk kamu") and Jelajahi.
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(aspectRatio: 16 / 10, child: _Photo(url: item.photoUrl)),
                Positioned(left: 12, top: 12, child: _Badge(label: item.isFree ? 'Gratis' : 'Dijual')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.conditionLabel} · ${item.locationName}',
                    style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(item.owner, style: const TextStyle(color: AppColors.inkSoft, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    item.priceLabel,
                    style: const TextStyle(color: AppColors.greenDark, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ],
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
      child: Center(child: Icon(Icons.image_outlined, color: AppColors.muted, size: 36)),
    );
    if (url.isEmpty) return placeholder;
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.greenTint, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(color: AppColors.greenDark, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
