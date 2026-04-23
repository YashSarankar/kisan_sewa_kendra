import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:kisan_sewa_kendra/services/attribution_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';

import 'controller/constants.dart';
import 'firebase_options.dart';
import 'utils/meta_events.dart';
import 'utils/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controller/language_controller.dart';
import 'view/splash_screen.dart';
import 'view/product_view.dart';
import 'view/collection_view.dart';
import 'view/cart_view.dart';
import 'view/home_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.firebaseMessagingBackgroundHandler(message);
}

//this is the dev branch
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Environment Variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Dotenv loading error: $e");
  }

  try {
    // Firebase Init
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Activate App Check
    // AndroidProvider.debug is useful for testing on emulators
    // AndroidProvider.playIntegrity is for production
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );

    // Initialize Push Notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService.init();

    // TEMPORARY: Print token for testing
    FirebaseMessaging.instance.getToken().then((token) {
      debugPrint("📱 YOUR FCM TOKEN: $token");
    });

    // Push Notification Attribution
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AttributionService().handlePushNotification(message);
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        AttributionService().handlePushNotification(message);
      }
    });

    // Initialize Meta Events
    await MetaEvents.init();

    // Initialize AppsFlyer SDK
    AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: "uphcn8e9ZxH7a38qCXQEcd",
      showDebug: false,
      timeToWaitForATTUserAuthorization: 15,
    );

    AppsflyerSdk appsflyerSdk = AppsflyerSdk(options);
    await appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    // Step 6.1 — Add onDeepLinking Handler
    appsflyerSdk.onDeepLinking((DeepLinkResult dp) {
      if (dp.status == Status.FOUND) {
        final deepLinkValue = dp.deepLink?.deepLinkValue;
        final params = dp.deepLink?.clickEvent;

        switch (deepLinkValue) {
          case 'product':
            final productId = params?['product_id'];
            if (productId != null) {
              navigatorKey.currentState?.pushNamed('/product/$productId');
            }
            break;
          case 'category':
            final category = params?['category'];
            if (category != null) {
              navigatorKey.currentState?.pushNamed('/category/$category');
            }
            break;
          case 'offer':
            navigatorKey.currentState?.pushNamed('/offers');
            break;
          case 'cart':
            navigatorKey.currentState?.pushNamed('/cart');
            break;
          default:
            // Do not force navigation to home on default case
            // as it interrupts the login flow during web verification.
            break;
        }
      }
    });

    await AttributionService().init(appsflyerSdk);

    final languageController = LanguageController();
    Constants.languageController = languageController;

    runApp(MyApp(languageController: languageController));
// ignore: strict_top_level_inference
  } catch (e) {
    debugPrint("Error: $e");
  }
}

class MyApp extends StatelessWidget {
  final LanguageController languageController;
  const MyApp({super.key, required this.languageController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageController,
      builder: (context, child) {
        return MaterialApp(
          title: Constants.title,
          debugShowCheckedModeBanner: false,
          locale: languageController.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('te'),
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Constants.baseColor),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.interTextTheme().copyWith(
              displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w900),
              displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.w800),
              displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.w800),
              headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.w800),
              headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Constants.baseColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              elevation: 10,
              type: BottomNavigationBarType.fixed,
            ),
            cardTheme: const CardThemeData(
              elevation: 5,
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            appBarTheme: AppBarTheme(
              foregroundColor: Constants.baseColor,
              backgroundColor: Colors.white,
            ),
          ),
          navigatorKey: navigatorKey,
          onGenerateRoute: (settings) {
            final name = settings.name ?? '';
            if (name.startsWith('/product/')) {
              final id = name.replaceFirst('/product/', '');
              return MaterialPageRoute(
                builder: (context) => ProductView(id: id),
              );
            }
            if (name.startsWith('/category/')) {
              final id = name.replaceFirst('/category/', '');
              return MaterialPageRoute(
                builder: (context) => CollectionView(collectionId: id),
              );
            }
            if (name == '/cart') {
              return MaterialPageRoute(
                builder: (context) => const CartView(),
              );
            }
            if (name == '/home') {
              return MaterialPageRoute(
                builder: (context) => const MyHomePage(),
              );
            }
            // Add other routes as needed
            return null;
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
