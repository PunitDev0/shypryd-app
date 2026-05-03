import 'package:ShipRyd_app/features/home/presentation/pages/home_page.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/pages/vehicle_allotment_screen.dart';
import 'package:ShipRyd_app/features/wallet/presentation/pages/payment_method_screen.dart';
import 'package:flutter/material.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  String? selectedPlan;

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String duration,
    required int totalPrice,
    required List<String> rules,
  }) {
    final bool isSelected = selectedPlan == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = title;
        });
      },
      child: Card(
        color: const Color(0xFFf5c034),
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFFf5c034)
                : const Color.fromARGB(255, 232, 230, 230),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle,
                            color: Color(0xFFf5c034)),
                      ]
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(duration, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              const Text(
                "+5% GST\n₹1000 deposit (one time)",
                style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.6)),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const Text(
                "Rules:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              ...rules.map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text("• $r", style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf5c034),
        centerTitle: true,
        title: const Text(
          "Select Your Plan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPlanCard(
              title: "Weekly Plan",
              price: "₹1599/week",
              totalPrice: 1699,
              duration: "7 days of service included",
              rules: [
                "2 swaps/day - 3rd or more swaps ₹65/swap",
                "Regular maintenance included",
                "Damage caused by driver will be charged",
              ],
            ),
            _buildPlanCard(
              title: "Monthly Plan",
              price: "₹5999/month",
              totalPrice: 6999,
              duration: "30 days of service included",
              rules: [
                "2 swaps/day - 3rd or more swaps ₹65/swap",
                "Regular maintenance included",
                "Damage caused by driver will be charged",
              ],
            ),
            const SizedBox(height: 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedPlan != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PaymentMethodScreen(
                                      selectedPlan: {
                                        "title": selectedPlan!,
                                        "price": selectedPlan == "Weekly Plan"
                                            ? "₹1599/week"
                                            : "₹5999/month",
                                        "duration":
                                            selectedPlan == "Weekly Plan"
                                                ? "7 days of service included"
                                                : "30 days of service included",
                                        "rules": const [
                                          "2 swaps/day - 3rd or more swaps ₹65/swap",
                                          "Regular maintenance included",
                                          "Damage caused by driver will be charged",
                                        ],
                                      },
                                      selectedPickupTime: "10 am - 5pm",
                                      totalAmount: selectedPlan == "Weekly Plan"
                                          ? 1699
                                          : 6999)),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPlan != null
                      ? const Color(0xFFf5c034)
                      : Colors.black.withOpacity(0.6)[400],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Proceed to Payment",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
