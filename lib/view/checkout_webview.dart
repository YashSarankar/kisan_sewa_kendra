import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../shopify/shopify.dart';

class CheckoutWebView extends StatefulWidget {
  final String checkoutUrl;

  const CheckoutWebView({super.key, required this.checkoutUrl});

  @override
  _CheckoutWebViewState createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.contains("thank_you") || request.url.contains("order-success")) {
              await Shopify.getCheckoutStatus(context);
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xff26842c)),
            ),
        ],
      ),
    );
  }
}
