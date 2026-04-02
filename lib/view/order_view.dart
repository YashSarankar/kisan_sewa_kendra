import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../controller/constants.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  final TextEditingController _awbController = TextEditingController();
  bool _isTracking = false;
  Map<String, dynamic>? _trackingData;

  Future<void> _trackOrder(String awb) async {
    if (awb.isEmpty) return;
    setState(() {
      _isTracking = true;
      _trackingData = null;
    });

    try {
      final response = await http.get(
        Uri.parse("https://track.delhivery.com/api/v1/packages/json/?waybill=$awb"),
        headers: {
          "Authorization": "Token cbdf7d27252629fa2e79ec785ee201d46a827c23",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _trackingData = data;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to track order. Please check AWB.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Tracking Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isTracking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Track Order", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildTrackingInput(),
            if (_trackingData != null) _buildTrackingResult(),
            if (_isTracking) const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
            const SizedBox(height: 40),
            _buildAboutFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInput() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Constants.baseColor.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Constants.baseColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Color(0xff26842c)),
              SizedBox(width: 10),
              Text("Track My Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _awbController,
            decoration: InputDecoration(
              hintText: "Enter AWB / Tracking Number",
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                onPressed: () => _trackOrder(_awbController.text),
                icon: const Icon(Icons.search, color: Color(0xff26842c)),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingResult() {
    final shipment = _trackingData?['ShipmentData']?[0]?['Shipment'];
    if (shipment == null) return const Center(child: Text("No shipment data found."));

    final scans = shipment['Scans'] as List? ?? [];
    final currentStatus = shipment['Status']?['Status'] ?? "Information Received";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Current Status:", style: TextStyle(color: Colors.grey, fontSize: 12)),
              _statusBadge(currentStatus.toUpperCase()),
            ],
          ),
          const SizedBox(height: 15),
          const Text("Tracking History:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...scans.take(3).map((scan) {
            final detail = scan['ScanDetail'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.radio_button_checked, size: 14, color: Color(0xff26842c)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(detail['Scan'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(detail['ScannedLocation'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(detail['ScanDateTime']?.toString().split('.')[0].replaceFirst('T', ' ') ?? '', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAboutFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Constants.baseColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About Us", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Text(
            "Welcome to EBS Krishi Bhandar, your trusted partner in agriculture. We offer 150+ premium products with nationwide delivery.",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 25),
          const Text("Our Mission", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            "Dedicated to providing high-quality agricultural solutions to ensure healthy crops and gardens across India.",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => launchUrlString("https://wa.me/919399022060"), icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white)),
              const SizedBox(width: 20),
              IconButton(onPressed: () => launchUrlString("tel:919399022060"), icon: const Icon(Icons.phone, color: Colors.white)),
            ],
          ),
          const Center(
            child: Text("© 2026 Kisan Sewa Kendra", style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'FULFILLED' || status == 'DELIVERED' ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
