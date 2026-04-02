import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  final String title;
  final String content;

  const PolicyPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        elevation: 2,
        shadowColor: Colors.black12,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FadeInWidget(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _parseContent(content),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _parseContent(String text) {
    final List<Widget> widgets = [];
    final lines = text.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      // Check if it's a section heading (starts with number or is short/bold-like)
      if (RegExp(r'^\d+\.').hasMatch(line) || line == line.toUpperCase()) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    line.trim(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        widgets.add(const Divider(color: Color(0xFFEEEEEE), thickness: 1));
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              line.trim(),
              style: TextStyle(
                fontSize: 14.5,
                color: Colors.grey[700],
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}

class FadeInWidget extends StatefulWidget {
  final Widget child;
  const FadeInWidget({super.key, required this.child});

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class PolicyContent {
  static const String privacyPolicy = """
PRIVACY POLICY

At Krishi Bhandar, we value your privacy and are committed to protecting your personal data.

1. Information We Collect
We may collect personal information such as your name, email address, phone number, and shipping address when you create an account or make a purchase.

2. How We Use Your Information
- To process and fulfill your orders.
- To communicate with you about your orders and promotional offers.
- To improve our app and customer service.

3. Data Security
We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, loss, or theft.

4. Third-Party Services
We may share your information with third-party service providers (e.g., payment processors, shipping partners) only to the extent necessary to provide our services.

5. Your Rights
You have the right to access, correct, or delete your personal information. Please contact us if you wish to exercise these rights.
""";

  static const String termsConditions = """
TERMS & CONDITIONS

Welcome to Krishi Bhandar. By using our app, you agree to comply with and be bound by the following terms and conditions.

1. General
The content of the app is for your general information and use only. It is subject to change without notice.

2. Account Responsibility
You are responsible for maintaining the confidentiality of your account and password and for restricting access to your device.

3. Product Information
We strive to provide accurate product descriptions and pricing. However, we do not warrant that product descriptions or other content are error-free.

4. Intellectual Property
All content included in the app, such as text, graphics, logos, and images, is the property of Krishi Bhandar or its content suppliers.

5. Limitation of Liability
Krishi Bhandar shall not be liable for any direct, indirect, incidental, or consequential damages resulting from the use or inability to use our services.
""";

  static const String shippingPolicy = """
SHIPPING POLICY

We aim to deliver our products to you in the fastest and most efficient way possible.

1. Shipping Times
Orders are typically processed within 1-2 business days. Delivery times vary based on your location but generally range from 3-7 business days.

2. Shipping Costs
Shipping charges are calculated at checkout based on the weight of your order and your delivery address.

3. Tracking Your Order
Once your order has shipped, you will receive a tracking number via email or SMS to monitor its progress.

4. Delivery Areas
We currently ship to most locations within India. If we are unable to ship to your location, we will notify you and provide a full refund.
""";

  static const String refundPolicy = """
RETURN & REFUND POLICY

Your satisfaction is our priority. If you are not completely satisfied with your purchase, we are here to help.

1. Returns
You have 7 days to return an item from the date you received it. To be eligible for a return, your item must be unused and in the same condition that you received it.

2. Refunds
Once we receive your item, we will inspect it and notify you of the status of your refund. If approved, we will initiate a refund to your original method of payment.

3. Shipping Costs for Returns
You will be responsible for paying for your own shipping costs for returning your item. Shipping costs are non-refundable.

4. Damaged Items
If you receive a damaged or defective item, please contact us immediately for a replacement or refund.
""";
}
