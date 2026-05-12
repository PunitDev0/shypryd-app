import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:Maxryd_app/core/constants/api_constants.dart';

class SwapJourneyScreen extends StatefulWidget {
  const SwapJourneyScreen({super.key});

  @override
  State<SwapJourneyScreen> createState() => _SwapJourneyScreenState();
}

class _SwapJourneyScreenState extends State<SwapJourneyScreen> {
  bool _isLoading = true;
  List<dynamic> _swaps = [];
  String? _error;

  static const yellow = Color(0xFFf5c034);
  static const darkBg = Colors.black;
  static const darkCard = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _fetchSwapHistory();
  }

  Future<void> _fetchSwapHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      final driverId = await storage.read(key: 'driverId');

      if (token == null || driverId == null) {
        throw Exception('Missing auth data');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/batterySwap/driver/swapDetails/$driverId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _swaps = data['data'] ?? [];
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch swaps');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: yellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Battery Swap',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: yellow),
            onPressed: _fetchSwapHistory,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 24, 25, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Swap History",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: yellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Recent",
                    style: TextStyle(color: yellow, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: yellow))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
                    : _swaps.isEmpty
                        ? const Center(child: Text("No swaps recorded yet", style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _swaps.length,
                            itemBuilder: (context, index) {
                              final swap = _swaps[index];
                              final dateTime = DateTime.tryParse(swap['dateTime']) ?? DateTime.now();
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: darkCard,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.bolt_rounded, color: Colors.greenAccent, size: 24),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Swap Successful",
                                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                DateFormat('dd MMM yyyy, hh:mm a').format(dateTime),
                                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            "HUB ID: ${swap['partnerId'] ?? '---'}",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: yellow.withOpacity(0.8)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      child: Divider(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _BatteryInfo(
                                          label: "Battery ID",
                                          value: swap['batteriesIssued']?.join(", ") ?? "---",
                                          icon: Icons.battery_charging_full_rounded,
                                          yellow: yellow,
                                        ),
                                        _BatteryInfo(
                                          label: "Swap Status",
                                          value: "COMPLETED",
                                          icon: Icons.verified_rounded,
                                          isRight: true,
                                          yellow: yellow,
                                          valueColor: Colors.greenAccent,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _BatteryInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isRight;
  final Color yellow;
  final Color? valueColor;

  const _BatteryInfo({
    required this.label,
    required this.value,
    required this.icon,
    required this.yellow,
    this.isRight = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) Icon(icon, size: 14, color: yellow.withOpacity(0.5)),
            if (!isRight) const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600)),
            if (isRight) const SizedBox(width: 6),
            if (isRight) Icon(icon, size: 14, color: yellow.withOpacity(0.5)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: valueColor ?? Colors.white),
        ),
      ],
    );
  }
}
