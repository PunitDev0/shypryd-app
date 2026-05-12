import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:Maxryd_app/core/constants/api_constants.dart';
import 'package:Maxryd_app/features/wallet/presentation/pages/payment_method_screen.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  int selectedPlanIndex = -1;
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> plans = [];
  final _storage = const FlutterSecureStorage();

  static const yellow = Color(0xFFf5c034);
  static const darkBg = Colors.black;
  static const darkCard = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      final driverId = await _storage.read(key: 'driverId');

      if (token == null) {
        throw Exception('No auth token found. Please login again.');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/subscription/plans${driverId != null ? "?driverId=$driverId" : ""}');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            plans = List<Map<String, dynamic>>.from(data['plans']);
            isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'API error');
        }
      } else {
        throw Exception('Failed to load plans');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  int get _selectedPlanPrice {
    if (selectedPlanIndex < 0 || selectedPlanIndex >= plans.length) return 0;
    final plan = plans[selectedPlanIndex];
    return plan['basePrice'] as int? ?? 0;
  }

  int get _deposit => 1000;
  int get _total => _selectedPlanPrice + _deposit;

  @override
  Widget build(BuildContext context) {
    final selectedPlan = selectedPlanIndex >= 0 && selectedPlanIndex < plans.length ? plans[selectedPlanIndex] : null;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: yellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: yellow))
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
                        const SizedBox(height: 20),
                        Text('Error: $errorMessage',
                            style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _fetchPlans,
                          style: ElevatedButton.styleFrom(backgroundColor: yellow, foregroundColor: Colors.black),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...List.generate(plans.length, (index) {
                        final plan = plans[index];
                        final isSelected = selectedPlanIndex == index;

                        return GestureDetector(
                          onTap: () => setState(() => selectedPlanIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: darkCard,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected ? yellow : Colors.white.withOpacity(0.05),
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: yellow.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))]
                                  : [],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      plan['name'] as String,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                    if (isSelected) const Icon(Icons.check_circle_rounded, color: yellow, size: 28),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${plan['basePrice']}',
                                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6, left: 4),
                                      child: Text(
                                        plan['duration'] != null ? '/ ${plan['duration']}' : '',
                                        style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  plan['description'] as String? ?? '',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.4),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      _PlanDetailRow(
                                        label: 'First time total',
                                        value: '₹${plan['firstTimePrice']}',
                                        color: Colors.greenAccent,
                                      ),
                                      const SizedBox(height: 8),
                                      _PlanDetailRow(
                                        label: 'Renewal Price',
                                        value: '₹${plan['renewalPrice']}',
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text('Plan Benefits:',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                                const SizedBox(height: 12),
                                ...[
                                  "2 swaps/day - 3rd or more swaps ₹65/swap",
                                  "Regular maintenance included",
                                  "Damage caused by driver will be charged",
                                ].map((r) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.bolt_rounded, color: yellow, size: 14),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(r, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      const Text('Pricing Breakdown',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: darkCard,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          children: [
                            _priceRow('Plan Price', _selectedPlanPrice),
                            const SizedBox(height: 12),
                            _priceRow('Security Deposit', _deposit),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Divider(color: Colors.white.withOpacity(0.05)),
                            ),
                            _priceRow('Total Amount', _total, isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
        decoration: BoxDecoration(
          color: darkBg,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: selectedPlanIndex >= 0
                ? () {
                    final selected = plans[selectedPlanIndex];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentMethodScreen(
                          selectedPlan: {
                            'title': selected['name'],
                            'price': '₹${selected['basePrice']}',
                            'duration': selected['duration'],
                            'rules': const [
                              "2 swaps/day - 3rd or more swaps ₹65/swap",
                              "Regular maintenance included",
                              "Damage caused by driver will be charged",
                            ],
                          },
                          selectedPickupTime: 'N/A',
                          totalAmount: _total,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 65),
              elevation: 8,
              shadowColor: yellow.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              disabledBackgroundColor: Colors.white.withOpacity(0.05),
              disabledForegroundColor: Colors.grey[700],
            ),
            child: Text(
              selectedPlanIndex >= 0 ? 'Proceed - ₹$_total' : 'Select a Plan',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, int amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.white : Colors.grey[500],
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          '₹$amount',
          style: TextStyle(
            color: isBold ? yellow : Colors.white,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            fontSize: isBold ? 20 : 16,
          ),
        ),
      ],
    );
  }
}

class _PlanDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PlanDetailRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
