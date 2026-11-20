import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../models/catalog_filter.dart';
import '../../models/item.dart';
import '../../services/chat_api.dart';
import '../../services/katalog_api.dart';
import '../../theme.dart';
import '../../widgets/item_card.dart';
import 'item_detail_page.dart';

const _searchDebounce = Duration(milliseconds: 400);

/// "Jelajahi & filter": search, Semua/Gratis/Dijual chips, filter panel, results.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, this.api, this.chatApi, this.request, this.onBack});

  final KatalogApi? api;
  final ChatApi? chatApi;

  /// A filter sent from another tab; applied whenever its `id` changes.
  final CatalogFilter? request;
  final VoidCallback? onBack;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final KatalogApi _api = widget.api ?? KatalogApi();
  final _scroll = ScrollController();
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  Timer? _debounce;

  CatalogFilter _filter = const CatalogFilter(); // what the list shows
  CatalogFilter _draft = const CatalogFilter(); // panel values, until "Terapkan"
  List<Item> _items = const [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;
  int _generation = 0; // drops responses of superseded requests

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _adopt(widget.request ?? const CatalogFilter());
  }

  @override
  void didUpdateWidget(CatalogPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final request = widget.request;
    if (request != null && request.id != oldWidget.request?.id) _adopt(request);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Replaces the whole filter (initial state or a request from Beranda).
  void _adopt(CatalogFilter filter) {
    _filter = filter;
    _draft = filter;
    _searchController.text = filter.query;
    _locationController.text = filter.location;
    _load(reset: true);
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 400 && _hasMore && !_loading) _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _generation++;
      _page = 0;
      _hasMore = true;
      _items = const [];
    }
    final generation = _generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.fetchItems(filter: _filter, page: _page + 1);
      if (!mounted || generation != _generation) return;
      setState(() {
        _items = [..._items, ...result.results];
        _page = result.page;
        _hasMore = result.hasMore;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  void _apply(CatalogFilter filter) {
    _filter = filter;
    _draft = filter;
    _load(reset: true);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () => _apply(_filter.copyWith(query: value.trim())));
  }

  void _applyPanel() {
    FocusScope.of(context).unfocus();
    _apply(_filter.copyWith(category: _draft.category, condition: _draft.condition, sort: _draft.sort, location: _locationController.text.trim()));
  }

  void _openItem(Item item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailPage(item: item, api: _api, chatApi: widget.chatApi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.onBack == null ? null : IconButton(icon: const Icon(Icons.chevron_left, size: 30), onPressed: widget.onBack),
        title: const Text('Jelajahi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Semua barang',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            _TypeChips(
              selected: _filter.type,
              onSelected: (type) => _apply(_filter.copyWith(type: type)),
            ),
            const SizedBox(height: 16),
            _FilterPanel(draft: _draft, locationController: _locationController, onChanged: (draft) => setState(() => _draft = draft), onApply: _applyPanel),
            const SizedBox(height: 20),
            const Text(
              'Hasil pencarian',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 12),
            ..._results(),
          ],
        ),
      ),
    );
  }

  List<Widget> _results() {
    if (_items.isEmpty && _loading) {
      return const [
        Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_items.isEmpty && _error != null) {
      return [
        Center(child: Text(_error!)),
        Center(
          child: TextButton(onPressed: () => _load(reset: true), child: const Text('Coba lagi')),
        ),
      ];
    }
    if (_items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Belum ada barang yang cocok.')),
        ),
      ];
    }
    return [
      for (final item in _items) ItemCard(item: item, onTap: () => _openItem(item)),
      if (_loading)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (_error != null) TextButton(onPressed: _load, child: Text('$_error Ketuk untuk mencoba lagi.')),
    ];
  }
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  static const _options = {'': 'Semua', 'ADOPSI': 'Gratis', 'JUAL': 'Dijual'};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final entry in _options.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: selected == entry.key,
            onSelected: (_) => onSelected(entry.key),
            showCheckmark: false,
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.green,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            labelStyle: TextStyle(fontWeight: FontWeight.w800, color: selected == entry.key ? Colors.white : AppColors.ink),
          ),
      ],
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.draft, required this.locationController, required this.onChanged, required this.onApply});

  final CatalogFilter draft;
  final TextEditingController locationController;
  final ValueChanged<CatalogFilter> onChanged;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter pencarian',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Dropdown(
                  label: 'Kategori',
                  value: draft.category,
                  options: categoryLabels,
                  onChanged: (v) => onChanged(draft.copyWith(category: v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: locationController,
                  decoration: _fieldDecoration('Lokasi', hint: 'Semua'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Dropdown(
                  label: 'Kondisi',
                  value: draft.condition,
                  options: conditionLabels,
                  onChanged: (v) => onChanged(draft.copyWith(condition: v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Dropdown(
                  label: 'Urutkan',
                  value: draft.sort,
                  options: sortLabels,
                  onChanged: (v) => onChanged(draft.copyWith(sort: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.line),
                ),
              ),
              child: const Text('Terapkan filter'),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label, {String? hint}) => InputDecoration(
  labelText: label,
  hintText: hint,
  isDense: true,
  filled: true,
  fillColor: AppColors.surface,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
);

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.label, required this.value, required this.options, required this.onChanged});

  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _fieldDecoration(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: [
            for (final entry in options.entries)
              DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => onChanged(v ?? ''),
        ),
      ),
    );
  }
}
