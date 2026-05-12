import 'package:flutter/material.dart';
import 'package:Maxryd_app/features/driver/domain/entities/driver_profile.dart';

class VehicleSectionScreen extends StatelessWidget {
  final DriverProfile? driverProfile;
  const VehicleSectionScreen({super.key, this.driverProfile});

  static const yellow = Color(0xFFf5c034);
  static const darkBg = Colors.black;
  static const darkCard = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    final vehicle = driverProfile?.vehicle;

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
          'My Vehicle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: yellow),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Vehicle ID Card (Premium Design)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
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
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: yellow.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: yellow.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.electric_scooter_rounded, color: yellow, size: 40),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      vehicle?.vehicleId ?? "NOT ASSIGNED",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "VEHICLE IDENTIFICATION",
                      style: TextStyle(
                        color: yellow.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Specifications Section
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
                    _SpecRow(
                      icon: Icons.confirmation_number_rounded,
                      label: "Chassis Number",
                      value: vehicle?.chassisNo ?? "---",
                      yellow: yellow,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Colors.white.withOpacity(0.05), thickness: 1),
                    ),
                    _SpecRow(
                      icon: Icons.category_rounded,
                      label: "Vehicle Type",
                      value: vehicle?.type ?? "---",
                      yellow: yellow,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Colors.white.withOpacity(0.05), thickness: 1),
                    ),
                    _SpecRow(
                      icon: Icons.info_rounded,
                      label: "Current Status",
                      value: vehicle?.status?.toUpperCase() ?? "---",
                      valueColor: vehicle?.status == "assigned" ? Colors.greenAccent : yellow,
                      yellow: yellow,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Quick Actions Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Vehicle Services",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Quick Actions Grid/List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ActionItem(
                    title: "Report Maintenance",
                    icon: Icons.build_circle_rounded,
                    onTap: () {},
                    yellow: yellow,
                  ),
                  const SizedBox(height: 15),
                  _ActionItem(
                    title: "Service History",
                    icon: Icons.history_edu_rounded,
                    onTap: () {},
                    yellow: yellow,
                  ),
                  const SizedBox(height: 15),
                  _ActionItem(
                    title: "Request Vehicle Return",
                    icon: Icons.assignment_return_rounded,
                    textColor: Colors.redAccent,
                    onTap: () {},
                    yellow: yellow,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
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
  final Color yellow;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: yellow.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: yellow, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.white,
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
  final Color yellow;

  const _ActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.textColor,
    required this.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor ?? yellow, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[700]),
            ],
          ),
        ),
      ),
    );
  }
}
