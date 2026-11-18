/// Immutable set of filters for Jelajahi, sent to `GET /api/v1/items/`.
///
/// `id` changes on every [explore] so a page can tell "a new request from
/// Beranda" apart from its own state.
class CatalogFilter {
  const CatalogFilter({
    this.query = '',
    this.category = '',
    this.type = '',
    this.condition = '',
    this.location = '',
    this.sort = '',
    this.id = 0,
  });

  final String query;
  final String category; // PERABOT, ELEKTRONIK, BUKU, ...
  final String type; // ADOPSI (Gratis) | JUAL (Dijual)
  final String condition; // SEPERTI_BARU, BAIK, CUKUP_BAIK, LAYAK_PAKAI
  final String location;
  final String sort; // newest, oldest, price_asc, price_desc, name
  final int id;

  CatalogFilter copyWith({
    String? query,
    String? category,
    String? type,
    String? condition,
    String? location,
    String? sort,
  }) {
    return CatalogFilter(
      query: query ?? this.query,
      category: category ?? this.category,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      sort: sort ?? this.sort,
      id: id,
    );
  }

  /// A filter handed from another tab (e.g. a category chip on Beranda).
  CatalogFilter explore() => CatalogFilter(
        query: query,
        category: category,
        type: type,
        condition: condition,
        location: location,
        sort: sort,
        id: id + 1,
      );
}

const categoryLabels = <String, String>{
  '': 'Semua',
  'PERABOT': 'Perabot',
  'ELEKTRONIK': 'Elektronik',
  'BUKU': 'Buku',
  'PAKAIAN': 'Pakaian',
  'ALAT_TULIS': 'Alat tulis',
  'DAPUR': 'Dapur',
  'LAINNYA': 'Lainnya',
};

const conditionLabels = <String, String>{
  '': 'Semua',
  'SEPERTI_BARU': 'Seperti baru',
  'BAIK': 'Baik',
  'CUKUP_BAIK': 'Cukup baik',
  'LAYAK_PAKAI': 'Layak pakai',
};

const sortLabels = <String, String>{
  '': 'Terbaru',
  'oldest': 'Terlama',
  'price_asc': 'Harga terendah',
  'price_desc': 'Harga tertinggi',
  'name': 'Nama A–Z',
};
