import 'package:material_ui/material_ui.dart';

/// Stand-in for modules owned by other members until their pages land.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.owner,
    required this.icon,
  });

  final String title;
  final String owner;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text('Modul $title', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Dikerjakan oleh $owner', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
