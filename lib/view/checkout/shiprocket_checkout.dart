import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/meta_events.dart';
import '../../utils/firebase_events.dart';

class ShiprocketCheckout extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double? totalValue;

  const ShiprocketCheckout({super.key, required this.cartItems, this.totalValue});

  @override
  State<ShiprocketCheckout> createState() => _ShiprocketCheckoutState();
}

class _ShiprocketCheckoutState extends State<ShiprocketCheckout> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isSuccessLogged = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final cartJson = jsonEncode(widget.cartItems);

    final html = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <script src="https://fastrr-boost-ui.pickrr.com/assets/js/channels/mobileApp.js"></script>
    </head>
    <body style="margin:0;padding:0;display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;">
    
    <div id="loader">Redirecting to checkout...</div>

    <script>
      function startCheckout() {
        try {
          if (typeof window.getOneClickCheckoutUrl === "function") {
            const items = $cartJson;

            const checkoutUrl = window.getOneClickCheckoutUrl({
              items: items,
              domain: "krishibhandar.com"
            });

            if (checkoutUrl) {
              window.location.href = checkoutUrl;
            } else {
              document.getElementById('loader').innerHTML = "<h3>Checkout URL generation failed</h3>";
            }
          } else {
            setTimeout(startCheckout, 500);
          }
        } catch (e) {
          document.getElementById('loader').innerHTML = "<h3>Error: " + e.message + "</h3>";
        }
      }

      window.onload = function() {
        startCheckout();
      }
    </script>

    </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },

          // ✅ FINAL PURCHASE FIX
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;

            debugPrint("👉 URL: $url");

            // 🔥 CORRECT PURCHASE DETECTION
            if (!_isSuccessLogged && url.contains("/orders/")) {

              debugPrint("✅ PAYMENT SUCCESS DETECTED");

              _isSuccessLogged = true;

              double val = widget.totalValue ?? 0.0;

              String txId = Uri.tryParse(url)?.pathSegments.last ??
                  DateTime.now().millisecondsSinceEpoch.toString();

              debugPrint("💰 Purchase Value: $val");
              debugPrint("🧾 Transaction ID: $txId");

              // Meta Event - FIXED: Using named parameter
              MetaEvents.purchase(totalValue: val);

              // Firebase Event - Already using named parameters
              FirebaseEvents.trackPurchase(
                totalAmount: val,
                transactionId: txId,
                productList: widget.cartItems,
              );

              debugPrint("🔥 FIREBASE PURCHASE EVENT SENT");
            }

            try {
              // intent://
              if (url.startsWith("intent://")) {
                final uri = Uri.parse(url);

                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  final fallback = uri.queryParameters['browser_fallback_url'];
                  if (fallback != null) {
                    await launchUrl(Uri.parse(fallback));
                  }
                }

                return NavigationDecision.prevent;
              }

              // UPI apps
              if (url.startsWith("upi://") ||
                  url.startsWith("phonepe://") ||
                  url.startsWith("paytm://") ||
                  url.startsWith("tez://") ||
                  url.startsWith("gpay://")) {

                final uri = Uri.parse(url);

                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }

                return NavigationDecision.prevent;
              }

              // Truecaller
              if (url.startsWith("truecallersdk://")) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }

            } catch (e) {
              debugPrint("🔥 Error: $e");
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Checkout"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
