import 'package:ShipRyd_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ShipRyd_app/core/constants/api_constants.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Map<String, dynamic> selectedPlan;
  final String selectedPickupTime;
  final int totalAmount;

  const PaymentMethodScreen({
    super.key,
    required this.selectedPlan,
    required this.selectedPickupTime,
    required this.totalAmount,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int selectedMethod = 0; // 0 = online, 1 = cash
  bool isSubmitting = false;
  Razorpay? _razorpay;
  String? _subscriptionId;

  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  // Payment success
  // Payment success → verify payment + navigate
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('PAYMENT SUCCESS:');
    print('Payment ID: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    print('Signature: ${response.signature}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful! Verifying...'),
        backgroundColor: Colors.black,
      ),
    );

    // Verify payment with backend
    final verified = await _verifyPayment(
      subscriptionId: _subscriptionId ?? '',
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );

    if (verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription activated successfully!'),
          backgroundColor: Colors.black,
        ),
      );

      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment verified but subscription activation failed'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  // Payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    print('PAYMENT ERROR:');
    print('Code: ${response.code}');
    print('Message: ${response.message}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? "Unknown error"}'),
        backgroundColor: Colors.black,
      ),
    );
  }

  // External wallet (optional)
  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected wallet: ${response.walletName}')),
    );
  }

  // Call backend to create Razorpay order
  // Call backend to create Razorpay order + get key
  Future<Map<String, dynamic>?> _createSubscriptionOrder() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token');

      final driverId =
          await _storage.read(key: 'driverId') ?? '65e0b1a2c3d4e5f6a7b8c9d0';
      final plan = widget.selectedPlan['title']
              .toString()
              .toLowerCase()
              .contains('weekly')
          ? 'weekly'
          : 'monthly';

      print('Sending order creation request to: $url');
      print('Request body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print('Order Creation Status Code: ${response.statusCode}');
      print('Order Creation Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final fullData = jsonDecode(response.body);
        final nestedData = fullData['data'] as Map<String, dynamic>?;

        if (nestedData == null) throw Exception('No data in response');

        final orderId = nestedData['orderId'] as String?;
        final subscriptionId = nestedData['subscriptionId'] as String?;
        final razorpayKeyId = nestedData['razorpayKeyId'] as String?;

        if (orderId == null ||
            subscriptionId == null ||
            razorpayKeyId == null) {
          throw Exception('Missing required fields in response');
        }

        // Store subscriptionId for verification later
        _subscriptionId = subscriptionId;

        return {
          'orderId': orderId,
          'razorpayKeyId': razorpayKeyId,
        };
      } else {
        throw Exception('Order creation failed: ${response.body}');
      }
    } catch (e) {
      print('Order creation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initiate payment: $e')),
      );
      return null;
    }
  }

  // Verify payment after success
  Future<bool> _verifyPayment({
    required String subscriptionId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token');

      final url =
          Uri.parse('${ApiConstants.baseUrl}/api/subscription/verify-payment');

      final body = {
        'subscriptionId': subscriptionId,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      };

      print('Verifying payment with body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Verify Payment Status: ${response.statusCode}');
      print('Verify Payment Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('Payment verified successfully');
          return true;
        } else {
          print('Verification failed: ${data['message']}');
          return false;
        }
      } else {
        print('Verification failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Verification error: $e');
      return false;
    }
  }

// Open Razorpay checkout using dynamic key
  Future<void> _openRazorpayCheckout() async {
    setState(() => isSubmitting = true);

    final orderData = await _createSubscriptionOrder();
    if (orderData == null) {
      setState(() => isSubmitting = false);
      return;
    }

    final orderId = orderData['orderId'] as String;
    final razorpayKey = orderData['razorpayKeyId'] as String;
    final amountInPaise = widget.totalAmount * 100;

    print('Preparing Razorpay options...');
    print('OrderId: $orderId');
    print('Key: $razorpayKey');
    print('Amount (Paise): $amountInPaise');

    var options = {
      'key': razorpayKey, // ← Using the key returned from backend
      'amount': amountInPaise,
      'name': 'ShipRyd',
      'description': '${widget.selectedPlan['title']} Subscription',
      'order_id': orderId,
      'prefill': {
        'contact': '7017584814', // optional
        'email': 'amar@shipryd.com',
      },
      'theme': {
        'color': '#f5c034',
      },
    };

    try {
      _razorpay!.open(options);
      print('Razorpay checkout opened successfully with key: $razorpayKey');
    } catch (e) {
      print('Razorpay open error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening payment gateway: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf5c034),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Choose Payment Method',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary (unchanged)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFf5c034),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.6).shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Booking Summary',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _summaryRow('Plan', widget.selectedPlan['title'] as String),
                  _summaryRow('Date', _formattedToday()),
                  _summaryRow('Time', widget.selectedPickupTime),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('₹${widget.totalAmount}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _paymentTile(
              icon: Icons.credit_card,
              title: 'Pay Online',
              subtitle: 'Credit/Debit Card, UPI, Net Banking',
              index: 0,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F9EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Colors.black),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment is secured with 256-bit SSL encryption.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: ElevatedButton(
          onPressed: selectedMethod != -1 && !isSubmitting
              ? () async {
                  if (selectedMethod == 0) {
                    // Pay Online → Razorpay
                    await _openRazorpayCheckout();
                  } else {
                    // Cash → handle differently (if needed in future)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Online payment is currently required for renewal.')),
                    );
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD600),
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 3),
                )
              : const Text(
                  'Confirm Booking and Pay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _paymentTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
  }) {
    final isSelected = selectedMethod == index;

    return GestureDetector(
      onTap: () => setState(() => selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFf5c034),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black.withOpacity(0.6).shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6).shade600)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.black : Colors.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.black.withOpacity(0.6).shade600, fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formattedToday() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)} ${now.year}";
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
