import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SwapJourneyScreen extends StatefulWidget {
  const SwapJourneyScreen({super.key});

  @override
  State<SwapJourneyScreen> createState() => _SwapJourneyScreenState();
}

class _SwapJourneyScreenState extends State<SwapJourneyScreen> {
  bool _isLoading = true;
  List<dynamic> _swaps = [];
  String? _error;

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
        Uri.parse('http://192.168.1.43:5008/api/batterySwap/driver/swapDetails/$driverId'),
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
    const yellow = Color(0xFFFFD600);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Battery Swap',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchSwapHistory,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Swap History",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Recent",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _swaps.isEmpty
                        ? const Center(child: Text("No swaps recorded yet"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _swaps.length,
                            itemBuilder: (context, index) {
                              final swap = _swaps[index];
                              final dateTime = DateTime.tryParse(swap['dateTime']) ?? DateTime.now();
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check, color: Colors.green, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Swap Completed",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              Text(
                                                DateFormat('dd MMM yyyy, hh:mm a').format(dateTime),
                                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "Hub: ${swap['partnerId'] ?? '---'}",
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      child: Divider(),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _BatteryInfo(
                                          label: "Battery ID",
                                          value: swap['batteriesIssued']?.join(", ") ?? "---",
                                          icon: Icons.battery_std,
                                        ),
                                        _BatteryInfo(
                                          label: "SoC Info",
                                          value: "85% -> 10%", // Mocking SoC for now as API doesn't show it clearly
                                          icon: Icons.bolt,
                                          isRight: true,
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

  const _BatteryInfo({
    required this.label,
    required this.value,
    required this.icon,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            if (isRight) const SizedBox(width: 4),
            if (isRight) Icon(icon, size: 14, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
