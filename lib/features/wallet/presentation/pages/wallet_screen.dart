import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:Maxryd_app/core/constants/api_constants.dart';
import 'package:Maxryd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:Maxryd_app/features/wallet/presentation/pages/my_subscription_screen.dart';

class WalletScreen extends StatefulWidget {
  final DriverProfile? driverProfile;
  const WalletScreen({super.key, this.driverProfile});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isLoadingHistory = true;
  List<dynamic> _subscriptions = [];
  String? _error;

  static const yellow = Color(0xFFf5c034);
  static const darkBg = Colors.black;
  static const darkCard = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionHistory();
  }

  Future<void> _fetchSubscriptionHistory() async {
    setState(() {
      _isLoadingHistory = true;
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
        Uri.parse('${ApiConstants.baseUrl}/api/subscription/driver/$driverId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _subscriptions = data['subscriptions'] ?? [];
            _isLoadingHistory = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch history');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSub = widget.driverProfile?.activeSubscription;

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
          "My Wallet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: yellow),
            onPressed: _fetchSubscriptionHistory,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSubscriptionHistory,
        color: yellow,
        backgroundColor: darkCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card (Premium)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [darkCard, Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "WALLET BALANCE",
                        style: TextStyle(
                          color: yellow.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "₹${widget.driverProfile?.walletBalance ?? 0}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _WalletActionBtn(
                            icon: Icons.add_circle_rounded,
                            label: "Top Up",
                            onTap: () {},
                            yellow: yellow,
                          ),
                          const SizedBox(width: 50),
                          _WalletActionBtn(
                            icon: Icons.history_rounded,
                            label: "Statement",
                            onTap: () {},
                            yellow: yellow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Text(
                  "Current Subscription",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),

              // Subscription Card
              if (activeSub != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: darkCard,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: yellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.electric_scooter_rounded, color: yellow, size: 28),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${activeSub.plan?.toUpperCase()} Plan",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Valid until ${DateFormat('dd MMM yyyy').format(DateTime.tryParse(activeSub.endDate!) ?? DateTime.now())}",
                                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "ACTIVE",
                                style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w900),
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
                            Text("Plan Amount", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600)),
                            Text("₹${activeSub.totalAmount}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  backgroundColor: Colors.white.withOpacity(0.05),
                                ),
                                child: const Text("Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MySubscriptionScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: yellow,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: const Text("Renew Plan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: darkCard,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: const Center(
                      child: Text("No active subscription", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(25, 35, 25, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                    TextButton(
                      onPressed: () {},
                      child: const Text("See All", style: TextStyle(color: yellow, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              if (_isLoadingHistory)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: yellow)))
              else if (_error != null)
                Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(_error!, style: const TextStyle(color: Colors.redAccent))))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = _subscriptions[index];
                    final date = DateTime.tryParse(sub['createdAt']) ?? DateTime.now();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: darkCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_upward_rounded, color: Colors.redAccent, size: 20),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${sub['plan'].toString().toUpperCase()} Plan",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a').format(date),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "- ₹${sub['totalAmount']}",
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color yellow;

  const _WalletActionBtn({required this.icon, required this.label, required this.onTap, required this.yellow});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: yellow, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
