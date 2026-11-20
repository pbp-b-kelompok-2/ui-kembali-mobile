/// One barang from `GET /api/v1/items/` (see katalog/serializers.py).
class Item {
  const Item({
    required this.id,
    required this.owner,
    required this.isOwner,
    required this.name,
    required this.description,
    required this.categoryLabel,
    required this.conditionLabel,
    required this.photoUrl,
    required this.locationName,
    required this.transactionType,
    required this.status,
    this.price,
    this.contact,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String owner;
  final bool isOwner;
  final String name;
  final String description;
  final String categoryLabel;
  final String conditionLabel;
  final String photoUrl;
  final String locationName;
  final String transactionType; // ADOPSI | JUAL
  final String status; // TERSEDIA | DIPESAN | SELESAI
  final int? price;
  final String? contact; // only sent to logged-in users
  final double? latitude;
  final double? longitude;

  bool get isFree => transactionType == 'ADOPSI';
  bool get isAvailable => status == 'TERSEDIA';

  String get priceLabel {
    if (isFree || price == null) return 'Gratis';
    final grouped = price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
        );
    return 'Rp$grouped';
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      owner: json['owner'] as String? ?? '',
      isOwner: json['is_owner'] as bool? ?? false,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      categoryLabel: json['category_label'] as String? ?? '',
      conditionLabel: json['condition_label'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
      locationName: json['location_name'] as String? ?? '',
      transactionType: json['transaction_type'] as String? ?? 'ADOPSI',
      status: json['status'] as String? ?? 'TERSEDIA',
      price: (json['price'] as num?)?.toInt(),
      contact: json['contact'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

/// The paginated envelope: `{count, page, num_pages, results}`.
class ItemPage {
  const ItemPage({
    required this.count,
    required this.page,
    required this.numPages,
    required this.results,
  });

  final int count;
  final int page;
  final int numPages;
  final List<Item> results;

  bool get hasMore => page < numPages;

  factory ItemPage.fromJson(Map<String, dynamic> json) {
    return ItemPage(
      count: json['count'] as int,
      page: json['page'] as int,
      numPages: json['num_pages'] as int,
      results: (json['results'] as List<dynamic>)
          .map((row) => Item.fromJson(row as Map<String, dynamic>))
          .toList(),
    );
  }
}
