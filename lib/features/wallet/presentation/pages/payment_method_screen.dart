import 'package:Maxryd_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Maxryd_app/core/constants/api_constants.dart';

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

  static const yellow = Color(0xFFf5c034);
  static const darkBg = Colors.black;
  static const darkCard = Color(0xFF1E1E1E);

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

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Successful! Verifying...'), backgroundColor: Colors.greenAccent),
    );

    final verified = await _verifyPayment(
      subscriptionId: _subscriptionId ?? '',
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );

    if (verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription activated!'), backgroundColor: Colors.greenAccent),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.redAccent),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wallet: ${response.walletName}')));
  }

  Future<Map<String, dynamic>?> _createSubscriptionOrder() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token');

      final driverId = await _storage.read(key: 'driverId') ?? '';
      final plan = widget.selectedPlan['title'].toString().toLowerCase().contains('weekly') ? 'weekly' : 'monthly';

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/subscription/create-order'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'driverId': driverId, 'plan': plan}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        _subscriptionId = data['subscriptionId'];
        return {'orderId': data['orderId'], 'razorpayKeyId': data['razorpayKeyId']};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _verifyPayment({required String subscriptionId, required String razorpayOrderId, required String razorpayPaymentId, required String razorpaySignature}) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/subscription/verify-payment'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'subscriptionId': subscriptionId,
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        }),
      );
      return jsonDecode(response.body)['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _openRazorpayCheckout() async {
    setState(() => isSubmitting = true);
    final orderData = await _createSubscriptionOrder();
    if (orderData == null) {
      setState(() => isSubmitting = false);
      return;
    }

    var options = {
      'key': orderData['razorpayKeyId'],
      'amount': widget.totalAmount * 100,
      'name': 'ShypRyd',
      'description': '${widget.selectedPlan['title']} Subscription',
      'order_id': orderData['orderId'],
      'prefill': {'contact': '7017584814', 'email': 'amar@maxryd.com'},
      'theme': {'color': '#f5c034'},
    };

    try {
      _razorpay!.open(options);
    } finally {
      setState(() => isSubmitting = false);
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
          'Payment Method',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary (Premium Style)
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Booking Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 20),
                  _summaryRow('Selected Plan', widget.selectedPlan['title'] as String),
                  _summaryRow('Current Date', _formattedToday()),
                  _summaryRow('Reference Time', widget.selectedPickupTime),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.white.withOpacity(0.05)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Payable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                      Text('₹${widget.totalAmount}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: yellow)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            const Text('Choose Payment Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 20),

            _paymentTile(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Online Payment',
              subtitle: 'Cards, UPI, Net Banking',
              index: 0,
            ),

            const SizedBox(height: 30),

            // Security Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 24),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Secured with SSL encryption for safe and fast transactions.',
                      style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
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
            onPressed: !isSubmitting ? _openRazorpayCheckout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 65),
              elevation: 8,
              shadowColor: yellow.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              disabledBackgroundColor: Colors.white.withOpacity(0.05),
            ),
            child: isSubmitting
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                : const Text('Confirm & Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }

  Widget _paymentTile({required IconData icon, required String title, required String subtitle, required int index}) {
    final isSelected = selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: darkCard,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? yellow : Colors.white.withOpacity(0.05), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: yellow.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: yellow, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isSelected ? yellow : Colors.grey[800]),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }

  String _formattedToday() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)} ${now.year}";
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
