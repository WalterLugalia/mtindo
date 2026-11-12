// lib/features/feed/models/product.dart
class Product {
  final int id;
  final String name;
  final String brandName;
  final String colour;
  final double? priceValue;
  final String priceDisplay;
  final String currency;
  final String imageUrl;
  final List<String> additionalImageUrls;
  final String productUrl;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.brandName,
    required this.colour,
    required this.priceValue,
    required this.priceDisplay,
    required this.currency,
    required this.imageUrl,
    required this.additionalImageUrls,
    required this.productUrl,
    required this.category,
  });

  /// Builds a Product from ONE item of the ASOS products/v2/list response.
  factory Product.fromJson(Map<String, dynamic> json, {String category = ''}) {
    final price = json['price'] as Map<String, dynamic>?;
    final current = price?['current'] as Map<String, dynamic>?;

    return Product(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Unnamed item',
      brandName: (json['brandName'] as String?) ?? '',
      colour: (json['colour'] as String?) ?? '',
      priceValue: (current?['value'] as num?)?.toDouble(),
      priceDisplay: (current?['text'] as String?) ?? '',
      currency: (price?['currency'] as String?) ?? 'USD',
      imageUrl: _withScheme(json['imageUrl'] as String?),
      additionalImageUrls: ((json['additionalImageUrls'] as List?) ?? [])
          .map((e) => _withScheme(e as String?))
          .toList(),
      productUrl: _asosProductUrl(json['url'] as String?),
      category: category,
    );
  }

  /// Builds a Product from the products/v4/detail response.
  ///
  /// That response has a different shape from the list: brand is nested
  /// (brand.name), images sit under media.images, the product URL is a
  /// full address inside localisedData, and there is NO price at all.
  /// So price fields are left empty and category stays blank (the detail
  /// endpoint's productType is just "Shoes", which would look inconsistent
  /// next to the feed's "Shoes, Boots & Sneakers").
  factory Product.fromDetailJson(Map<String, dynamic> json) {
    final brand = json['brand'] as Map<String, dynamic>?;
    final media = json['media'] as Map<String, dynamic>?;

    final imageUrls = ((media?['images'] as List?) ?? [])
        .map((e) => _withScheme((e as Map<String, dynamic>)['url'] as String?))
        .where((url) => url.isNotEmpty)
        .toList();

    return Product(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Unnamed item',
      brandName: (brand?['name'] as String?) ?? '',
      colour: _primaryColour(json['variants'] as List?),
      priceValue: null,
      priceDisplay: '',
      currency: '',
      imageUrl: imageUrls.isEmpty ? '' : imageUrls.first,
      additionalImageUrls: imageUrls.length > 1 ? imageUrls.sublist(1) : [],
      productUrl: _detailProductUrl(json['localisedData'] as List?),
      category: '',
    );
  }

  /// Rebuilds a Product from OUR OWN saved format (the output of toMap).
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      name: (map['name'] as String?) ?? 'Unnamed item',
      brandName: (map['brandName'] as String?) ?? '',
      colour: (map['colour'] as String?) ?? '',
      priceValue: (map['priceValue'] as num?)?.toDouble(),
      priceDisplay: (map['priceDisplay'] as String?) ?? '',
      currency: (map['currency'] as String?) ?? 'USD',
      imageUrl: (map['imageUrl'] as String?) ?? '',
      additionalImageUrls: ((map['additionalImageUrls'] as List?) ?? [])
          .map((e) => e as String)
          .toList(),
      productUrl: (map['productUrl'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
    );
  }

  /// Flattens this Product into plain JSON-friendly values for saving.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brandName': brandName,
      'colour': colour,
      'priceValue': priceValue,
      'priceDisplay': priceDisplay,
      'currency': currency,
      'imageUrl': imageUrl,
      'additionalImageUrls': additionalImageUrls,
      'productUrl': productUrl,
      'category': category,
    };
  }

  /// ASOS returns image URLs without a scheme (e.g.
  /// "images.asos-media.com/..."), so prepend https:// to make them usable.
  static String _withScheme(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://$url';
  }

  /// List-endpoint product URLs are relative ("asos-design/.../prd/123").
  /// Prefix them with ASOS's site address.
  static String _asosProductUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return '';
    return 'https://www.asos.com/$relativeUrl';
  }

  /// The colour of the first variant marked primary, else the first
  /// variant, else blank.
  static String _primaryColour(List? variants) {
    if (variants == null || variants.isEmpty) return '';

    for (final variant in variants) {
      final map = variant as Map<String, dynamic>;
      if (map['isPrimary'] == true) return (map['colour'] as String?) ?? '';
    }
    return ((variants.first as Map<String, dynamic>)['colour'] as String?) ??
        '';
  }

  /// Picks the en-US page address from the translations; falls back to
  /// the first one if en-US is missing.
  static String _detailProductUrl(List? localised) {
    if (localised == null || localised.isEmpty) return '';

    for (final entry in localised) {
      final map = entry as Map<String, dynamic>;
      if (map['locale'] == 'en-US') return (map['pdpUrl'] as String?) ?? '';
    }
    return ((localised.first as Map<String, dynamic>)['pdpUrl'] as String?) ??
        '';
  }
}