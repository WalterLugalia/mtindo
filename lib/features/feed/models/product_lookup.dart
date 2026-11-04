import 'product.dart';

/// The three possible answers when asking ASOS for one product by ID.
///
/// A sealed class lets the compiler force every caller to handle all
/// three cases. A plain `Product?` could only express "found" and
/// "not found", which would make "removed" and "request failed" look
/// identical.
sealed class ProductLookup {
  const ProductLookup();
}

/// ASOS returned the product.
class ProductFound extends ProductLookup {
  final Product product;
  const ProductFound(this.product);
}

/// ASOS answered clearly that the product no longer exists. Safe to
/// remember: asking again would give the same answer.
class ProductRemoved extends ProductLookup {
  const ProductRemoved();
}

/// The request failed or the answer was unexpected (no connection,
/// rate limit, server error). We know nothing about the product, so
/// this must never be saved as "removed".
class ProductLookupFailed extends ProductLookup {
  const ProductLookupFailed();
}