import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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

    print('=== Fetching subscription plans ===');

    try {
      final token = await _storage.read(key: 'auth_token');
      print(
          'Token retrieved: ${token != null ? token.substring(0, 20) + "..." : "NULL - no token"}');

      if (token == null) {
        print('ERROR: No auth token found in secure storage');
        throw Exception('No auth token found. Please login again.');
      }

      final url = Uri.parse('http://192.168.1.43:5008/api/subscription/plans');
      print('API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed JSON success: ${data['success']}');

        if (data['success'] == true) {
          final fetchedPlans = List<Map<String, dynamic>>.from(data['plans']);
          print('Number of plans received: ${fetchedPlans.length}');
          print('Plans data: $fetchedPlans');

          setState(() {
            plans = fetchedPlans;
            isLoading = false;
          });
        } else {
          final msg = data['message'] ?? 'API returned success=false';
          print('API Error Message: $msg');
          throw Exception(msg);
        }
      } else if (response.statusCode == 401) {
        print('401 Unauthorized - Token likely invalid/expired');
        throw Exception('Session expired. Please login again.');
      } else {
        print('Non-200 status: ${response.statusCode}');
        throw Exception(
            'Failed to load plans: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      print('EXCEPTION in _fetchPlans: $e');
      print('Stack trace: $stack');

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    } finally {
      print('=== Fetch plans finished ===');
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
    const yellow = Color(0xFFFFD600);

    final selectedPlan =
        selectedPlanIndex >= 0 && selectedPlanIndex < plans.length
            ? plans[selectedPlanIndex]
            : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: yellow))
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $errorMessage',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPlans,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...List.generate(plans.length, (index) {
                        final plan = plans[index];
                        final isSelected = selectedPlanIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedPlanIndex = index);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isSelected ? yellow : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      plan['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle,
                                          color: yellow),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '₹${plan['basePrice']}',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: plan['duration'] != null
                                            ? ' / ${plan['duration']}'
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  plan['description'] as String? ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'First time total: ₹${plan['firstTimePrice']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Renewal: ₹${plan['renewalPrice']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Divider(),
                                const Text(
                                  'Rules:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                ...[
                                  "2 swaps/day - 3rd or more swaps ₹65/swap",
                                  "Regular maintenance included",
                                  "Damage caused by driver will be charged",
                                ].map(
                                  (r) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Text("• $r",
                                        style: const TextStyle(fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 28),
                      const Text(
                        'Pricing Breakdown',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (selectedPlan != null) ...[
                        _priceRow('Plan Price', _selectedPlanPrice),
                        _priceRow(
                            'One-Time Security Deposit (Refundable)', _deposit),
                        const Divider(height: 32),
                        _priceRow('Total Amount (First Time)', _total,
                            isBold: true),
                      ] else ...[
                        _priceRow('One-Time Security Deposit', _deposit),
                        const Divider(height: 32),
                        _priceRow('Total Amount', _deposit, isBold: true),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
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
                          selectedPickupTime: 'N/A', // Removed pickup time
                          totalAmount: _total,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedPlanIndex >= 0
                  ? const Color(0xFFFFD600)
                  : Colors.grey.shade300,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.black,
            ),
            child: Text(
              selectedPlanIndex >= 0 ? 'Proceed - ₹$_total' : 'Select a Plan',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, int amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            '₹$amount',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
