import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/widget_button.dart';
import '../controller/constants.dart';

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitToWhatsApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    final fullMessage = "Name: $name\nPhone: $phone\nEmail: $email\nMessage: $message";
    final encodedMessage = Uri.encodeComponent(fullMessage);
    
    final whatsappUrl = Uri.parse("https://wa.me/919399022060?text=$encodedMessage");
    final playStoreUrl = Uri.parse("https://play.google.com/store/apps/details?id=com.whatsapp");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to process request"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Support & Contact", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Branding Header
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1B5E20), const Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(FontAwesomeIcons.headset, color: Color(0xFF1B5E20), size: 30),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "How can we help you?",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Our experts are available to guide you",
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                  ),
                ],
              ),
            ),

            // Quick Contact
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.5,
                children: [
                  _quickContactCard(
                    icon: FontAwesomeIcons.phone,
                    label: "Call Us",
                    onTap: () async {
                      final url = Uri.parse("tel:919399022060");
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                    color: Colors.blue,
                  ),
                  _quickContactCard(
                    icon: FontAwesomeIcons.whatsapp,
                    label: "WhatsApp",
                    onTap: _submitToWhatsApp,
                    color: const Color(0xFF25D366),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Contact Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Send us a Message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _modernField(
                    label: "Full Name",
                    icon: Icons.person_outline,
                    controller: _nameController,
                    validator: (v) => v!.isEmpty ? "Enter your name" : null,
                  ),
                  _modernField(
                    label: "Phone Number",
                    icon: Icons.phone_android,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Enter valid 10-digit mobile number";
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                        return "Enter valid 10-digit mobile number";
                      }
                      return null;
                    },
                  ),
                  _modernField(
                    label: "Email Address",
                    icon: Icons.email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Enter valid email address";
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                        return "Enter valid email address";
                      }
                      return null;
                    },
                  ),
                  _modernField(
                    label: "Message",
                    icon: Icons.chat_bubble_outline,
                    maxLines: 4,
                    controller: _messageController,
                    validator: (v) => (v == null || v.length < 3) ? "Min 3 characters required" : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitToWhatsApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.baseColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("SUBMIT MESSAGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Office Address
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[50],
              child: Column(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 30),
                  const SizedBox(height: 10),
                  const Text("Our Head Office", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  const Text(
                    "HIG 3/554, Arvind Vihar, Bagmugaliya, Bhopal, MP, 462043",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _quickContactCard({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return WidgetButton(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _modernField({
    required String label, 
    required IconData icon, 
    int maxLines = 1, 
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey),
          floatingLabelStyle: TextStyle(color: Constants.baseColor),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Constants.baseColor, width: 1)),
          errorStyle: const TextStyle(fontSize: 12, height: 0.8),
        ),
      ),
    );
  }
}
