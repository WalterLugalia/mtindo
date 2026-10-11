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

  static String _withScheme(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://$url';
  }

  static String _asosProductUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return '';
    return 'https://www.asos.com/$relativeUrl';
  }
}