import 'package:flutter/material.dart';
import 'package:Maxryd_app/features/driver/domain/entities/driver_profile.dart';

class VehicleSectionScreen extends StatelessWidget {
  final DriverProfile? driverProfile;
  const VehicleSectionScreen({super.key, this.driverProfile});

  static const yellow = Color(0xFFFFD600);

  @override
  Widget build(BuildContext context) {
    final vehicle = driverProfile?.vehicle;

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
          'My Vehicle',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Vehicle ID Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: yellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.electric_scooter, color: Colors.black, size: 32),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      vehicle?.vehicleId ?? "NOT ASSIGNED",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "VEHICLE ID",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Specifications Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _SpecRow(
                      icon: Icons.confirmation_number_outlined,
                      label: "Chassis Number",
                      value: vehicle?.chassisNo ?? "---",
                    ),
                    const Divider(height: 30),
                    _SpecRow(
                      icon: Icons.category_outlined,
                      label: "Vehicle Type",
                      value: vehicle?.type ?? "---",
                    ),
                    const Divider(height: 30),
                    _SpecRow(
                      icon: Icons.info_outline,
                      label: "Status",
                      value: vehicle?.status?.toUpperCase() ?? "---",
                      valueColor: vehicle?.status == "assigned" ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _ActionItem(
                    title: "Report Maintenance",
                    icon: Icons.build_circle_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionItem(
                    title: "Service History",
                    icon: Icons.history,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionItem(
                    title: "Request Vehicle Return",
                    icon: Icons.assignment_return_outlined,
                    textColor: Colors.red,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;

  const _ActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Colors.black, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textColor ?? Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
