import 'package:ShipRyd_app/features/wallet/presentation/pages/my_subscription_screen.dart';
import 'package:flutter/material.dart';

class WalletEmptyScreen extends StatelessWidget {
  const WalletEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Subscription",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              // refresh action later
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scooter Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: yellow,
                ),
                child: const Icon(
                  Icons.electric_scooter,
                  size: 48,
                  color: const Color(0xFFf5c034),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                "Welcome to maxRyd!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                "Get started by choosing a subscription plan\nand making your first payment.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to Plan Selection
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MySubscriptionScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
                  label: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
