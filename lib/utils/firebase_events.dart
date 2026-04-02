import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseEvents {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Trigger: When product detail page opens
  static void viewItem(String? id, String? price) {
    if (id == null || price == null) return;
    double val = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    _analytics.logViewItem(
      currency: 'INR',
      value: val,
      items: [
        AnalyticsEventItem(
          itemId: id,
          itemCategory: 'product',
        ),
      ],
    );
  }

  /// Trigger: When user taps "Add to Cart"
  static void addToCart(String? id, String? price) {
    if (id == null || price == null) return;
    double val = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    _analytics.logAddToCart(
      currency: 'INR',
      value: val,
      items: [
        AnalyticsEventItem(
          itemId: id,
          itemCategory: 'product',
        ),
      ],
    );
  }

  /// Trigger: When user taps "Buy Now" or proceeds to checkout
  static void beginCheckout(double totalValue) {
    _analytics.logBeginCheckout(
      currency: 'INR',
      value: totalValue,
      items: [
        AnalyticsEventItem(
          itemCategory: 'product',
        ),
      ],
    );
  }

  /// Tracks a successful purchase event in Firebase Analytics.
  /// 
  /// This function is called automatically when a user successfully completes 
  /// a payment/order, detected via success URL redirects.
  /// 
  /// [totalAmount] - The total transaction value.
  /// [transactionId] - Unique ID for the transaction (e.g., Order ID).
  /// [productList] - List of purchased items. Each item is a map containing:
  ///   - 'id': Product/Variant ID
  ///   - 'name': Product title
  ///   - 'price': Unit price (double)
  ///   - 'quantity': Number of units (int)
  static void trackPurchase({
    required double totalAmount,
    required String transactionId,
    required List<Map<String, dynamic>> productList,
  }) {
    _analytics.logPurchase(
      currency: 'INR',
      value: totalAmount,
      transactionId: transactionId,
      items: productList.map((item) {
        return AnalyticsEventItem(
          itemId: item['id']?.toString() ?? '',
          itemName: item['name']?.toString() ?? item['title']?.toString() ?? 'Product',
          price: double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
          quantity: int.tryParse(item['quantity']?.toString() ?? '1') ?? 1,
          itemCategory: 'product',
        );
      }).toList(),
    );
  }

  /// Deprecated: Use [trackPurchase] for full details.
  static void purchase(double totalValue) {
    _analytics.logPurchase(
      currency: 'INR',
      value: totalValue,
      items: [
        AnalyticsEventItem(
          itemCategory: 'product',
        ),
      ],
    );
  }
}
