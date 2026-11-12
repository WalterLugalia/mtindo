class RouteConstants {
  RouteConstants._();

  static const String feed = '/';
  static const String leaderboard = '/leaderboard';
  static const String login = '/login';
  static const String signup = '/signup';

  /// The pattern go_router matches against. ":id" is a placeholder for
  /// the product ID.
  static const String itemDetailPattern = '/item/:id';

  /// The real address for one product, for example "/item/210872358".
  /// This is a method, not a constant, because it needs the ID.
  static String itemDetail(int productId) => '/item/$productId';
}