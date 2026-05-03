import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ShipRyd_app/features/driver/data/datasources/driver_remote_datasource.dart';
import 'package:ShipRyd_app/features/driver/data/repositories/driver_repository_impl.dart';
import 'package:ShipRyd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:ShipRyd_app/features/driver/domain/usecases/fetch_driver_profile.dart';

class VehicleSectionScreen extends StatefulWidget {
  final DriverProfile? driverProfile;
  const VehicleSectionScreen({super.key, this.driverProfile});

  @override
  State<VehicleSectionScreen> createState() => _VehicleSectionScreenState();
}

class _VehicleSectionScreenState extends State<VehicleSectionScreen> {
  DriverProfile? _currentProfile;
  bool _isRefreshing = false;
  static const yellow = Color(0xFFFFD600);

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.driverProfile;
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      if (token == null) return;

      final remote = DriverRemoteDataSourceImpl();
      final repo = DriverRepositoryImpl(remoteDataSource: remote);
      final usecase = FetchDriverProfile(repo);

      final result = await usecase(token);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to refresh: ${failure.toString()}')),
          );
        },
        (profile) {
          setState(() {
            _currentProfile = profile;
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _currentProfile?.vehicle;

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
            icon: _isRefreshing 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                  )
                : const Icon(Icons.refresh, color: Colors.black),
            onPressed: _isRefreshing ? null : _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          color: const Color(0xFFf5c034),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "VEHICLE ID",
                        style: TextStyle(
                          color: const Color(0xFFf5c034)54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Rest of the UI remains same...

            // Specifications Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFf5c034),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.6).shade200),
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
                      valueColor: vehicle?.status == "assigned" ? Colors.black : Colors.black,
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
                    textColor: Colors.black,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
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
        Icon(icon, color: Colors.black.withOpacity(0.6)[400], size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.black.withOpacity(0.6)[500], fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black,
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
          color: const Color(0xFFf5c034),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.6).shade100),
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
                  color: textColor ?? Colors.black,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black.withOpacity(0.6)[300]),
          ],
        ),
      ),
    );
  }
}
