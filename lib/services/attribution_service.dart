import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisan_sewa_kendra/main.dart';

class AttributionService {
  static final AttributionService _instance = AttributionService._internal();
  factory AttributionService() => _instance;
  AttributionService._internal();

  // Call once on app start — captures install + re-open attribution
  Future<void> init(AppsflyerSdk sdk) async {
    // For NEW installs (first open after ad click)
    sdk.onInstallConversionData((data) async {
      final prefs = await SharedPreferences.getInstance();
      final attrs = data['payload'] ?? {};
      final source = attrs['media_source'] ?? 'organic';
      print("🚀 AppsFlyer Install Data: $source | Campaign: ${attrs['campaign']}");
      
      // ONLY overwrite if it's a REAL campaign (not organic)
      if (source != 'organic' && source != 'None') {
        await prefs.setString('utm_source', source);
        await prefs.setString('utm_campaign', attrs['campaign'] ?? '');
        await prefs.setString('utm_term', attrs['adset'] ?? '');
        await prefs.setString('utm_content', attrs['ad'] ?? '');
        await prefs.setString('utm_medium', 'app');
      }

      // Step 6.2 — Deferred deep link navigation
      final deepLinkValue = attrs['deep_link_value'];
      final productId = attrs['product_id'];
      final category = attrs['category'];

      if (deepLinkValue == 'product' && productId != null) {
        navigatorKey.currentState?.pushNamed('/product/$productId');
      } else if (deepLinkValue == 'category' && category != null) {
        navigatorKey.currentState?.pushNamed('/category/$category');
      } else if (deepLinkValue == 'offer') {
        navigatorKey.currentState?.pushNamed('/offers');
      } else if (deepLinkValue == 'cart') {
        navigatorKey.currentState?.pushNamed('/cart');
      }
    });

    // For EXISTING users opening app via ad
    sdk.onAppOpenAttribution((data) async {
      final prefs = await SharedPreferences.getInstance();
      final attrs = data['payload'] ?? {};
      final source = attrs['media_source'] ?? 'organic';
      print("📱 AppsFlyer App Open Data: $source | Campaign: ${attrs['campaign']}");

      // ONLY overwrite if it's a REAL campaign (not organic)
      if (source != 'organic' && source != 'None') {
        await prefs.setString('utm_source', source);
        await prefs.setString('utm_campaign', attrs['campaign'] ?? '');
        await prefs.setString('utm_term', attrs['adset'] ?? '');
        await prefs.setString('utm_content', attrs['ad'] ?? '');
        await prefs.setString('utm_medium', 'app');
      }
    });
  }

  // Call this when building checkout — returns all attribution values
  Future<Map<String, String>> getAttribution() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'utm_source': prefs.getString('utm_source') ?? 'organic',
      'utm_medium': prefs.getString('utm_medium') ?? 'app',
      'utm_campaign': prefs.getString('utm_campaign') ?? '',
      'utm_term': prefs.getString('utm_term') ?? '',
      'utm_content': prefs.getString('utm_content') ?? '',
    };
  }

  // Call this when a push notification is tapped
  Future<void> handlePushNotification(RemoteMessage? message) async {
    if (message == null) return;

    final prefs = await SharedPreferences.getInstance();
    final campaign = message.data['campaign'] ?? 'push_campaign';
    print("🔔 Push Notification Tapped: $campaign");

    await prefs.setString('utm_source', 'push_notification');
    await prefs.setString('utm_medium', 'app');
    await prefs.setString('utm_campaign', campaign);
    await prefs.setString('utm_content', message.data['notification_id'] ?? '');
    await prefs.setString('utm_term', '');
  }
}
