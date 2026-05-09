import 'package:flutter/material.dart';

class BatterySwapStationsScreen extends StatelessWidget {
  const BatterySwapStationsScreen({super.key});

  static const Color yellow = Color(0xFFFFD600);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// MAP PLACEHOLDER
          Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Text(
              'Map View (Google Maps / Mapbox)',
              style: TextStyle(color: Colors.black54),
            ),
          ),

          /// APP BAR OVERLAY
          SafeArea(
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: yellow,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Battery Swap Stations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x33FFFFFF),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ZOOM BUTTON
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: yellow,
              foregroundColor: Colors.black,
              onPressed: () {},
              child: const Icon(Icons.fullscreen),
            ),
          ),

          /// FAKE STATION MARKERS
          ...List.generate(
            30,
            (index) => Positioned(
              left: 40.0 + (index * 8) % 260,
              top: 120.0 + (index * 14) % 420,
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
