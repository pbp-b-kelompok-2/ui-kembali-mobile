import 'package:material_ui/material_ui.dart';

import '../models/catalog_filter.dart';
import 'home_page.dart';
import 'katalog/catalog_page.dart';
import 'placeholder_page.dart';
import 'transactions/transaction_history_page.dart';

/// Bottom navigation: Beranda, Jelajahi, Transaksi, Forum, Profil.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _beranda = 0;
  static const _jelajahi = 1;

  int _index = _beranda;
  CatalogFilter _request = const CatalogFilter();

  /// Beranda shortcuts: open Jelajahi with a filter already applied.
  void _explore(CatalogFilter filter) {
    setState(() {
      _request = _request.copyWith(
        query: filter.query,
        category: filter.category,
        type: filter.type,
        condition: filter.condition,
        location: filter.location,
        sort: filter.sort,
      ).explore();
      _index = _jelajahi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(onExplore: _explore),
          CatalogPage(request: _request, onBack: () => setState(() => _index = _beranda)),
          TransactionHistoryPage(onBack: () => setState(() => _index = _beranda)),
          const PlaceholderPage(title: 'Forum', owner: 'Dimas Bayu Nugroho', icon: Icons.forum_outlined),
          const PlaceholderPage(title: 'Profil', owner: 'Elvis Sestomi', icon: Icons.person_outline),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.recycling), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Jelajahi'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Forum'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
