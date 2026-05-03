import 'dart:async';
import 'package:Maxryd_app/features/BatterySwap/swap_journey_screen.dart';
import 'package:Maxryd_app/features/FeedbackSection/share_feedback_screen.dart';
import 'package:Maxryd_app/features/Profile/driver_profile_screen.dart';
import 'package:Maxryd_app/features/driver/data/datasources/driver_remote_datasource.dart';
import 'package:Maxryd_app/features/driver/data/repositories/driver_repository_impl.dart';
import 'package:Maxryd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:Maxryd_app/features/driver/domain/usecases/fetch_driver_profile.dart';
import 'package:Maxryd_app/features/helpCenter/help_center_screen.dart';
import 'package:Maxryd_app/features/vehicleSection/vehicle_section_screen.dart';
import 'package:Maxryd_app/features/wallet/presentation/pages/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DriverProfile? _driverProfile;
  bool _isLoadingProfile = true;
  String? _profileError;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_driverProfile?.activeSubscription?.endDate == null) return;

    final endDate =
        DateTime.tryParse(_driverProfile!.activeSubscription!.endDate!);
    if (endDate == null) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = endDate.difference(now);

      if (diff.isNegative) {
        timer.cancel();
        setState(() {
          _remainingTime = Duration.zero;
        });
      } else {
        setState(() {
          _remainingTime = diff;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "Expired";
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return "$days d ${hours}h ${minutes}m";
    }
    return "${hours}h ${minutes}m ${seconds}s";
  }

  Future<void> _fetchDriverProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No auth token found');
      }

      final remote = DriverRemoteDataSourceImpl();
      final repo = DriverRepositoryImpl(remoteDataSource: remote);
      final usecase = FetchDriverProfile(repo);

      final result = await usecase(token);

      result.fold(
        (failure) {
          print('Driver Profile Fetch Failure: $failure');
          setState(() {
            _profileError = failure.toString();
            _isLoadingProfile = false;
          });
        },
        (profile) async {
          // Save driver ID if not already saved
          await storage.write(key: 'driverId', value: profile.id);
          print('Driver ID saved/updated: ${profile.id}');

          setState(() {
            _driverProfile = profile;
            _isLoadingProfile = false;
          });
          _startCountdown();
        },
      );
    } catch (e) {
      print('Driver Profile Fetch Exception: $e');
      setState(() {
        _profileError = e.toString();
        _isLoadingProfile = false;
      });
    }
  }

  String get _greetingName {
    if (_isLoadingProfile) return 'Loading...';
    if (_profileError != null) return 'Driver';
    final name = _driverProfile?.personalInformation?.fullName;
    return name != null && name.isNotEmpty ? name : 'Driver';
  }

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        // Vehicle
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VehicleSectionScreen()),
        );
        break;
      case 2:
        // Battery
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SwapJourneyScreen()),
        );
        break;
      case 3:
        // Help
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _timeGreeting;
    final userName = _greetingName.toLowerCase();
    
    // Calculate remaining time for Plan Status card
    String planRemaining = "No Plan";
    if (_driverProfile?.activeSubscription != null && _remainingTime != Duration.zero) {
      int days = _remainingTime.inDays;
      int hours = _remainingTime.inHours.remainder(24);
      planRemaining = "$days Days, $hours Hours left";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const Drawer(), // Placeholder drawer
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, size: 30),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf5c034),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "maxryd",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_driverProfile != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DriverProfileScreen(
                                driverProfile: _driverProfile!,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFf5c034), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          child: _isLoadingProfile
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.person, color: Colors.black, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Greeting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "$userName!",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Summary Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: "Plan Status",
                        value: planRemaining,
                        icon: Icons.timer_outlined,
                        color: const Color(0xFFE8F5E9),
                        iconColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: "Swap Access",
                        value: _driverProfile?.swapStatus == "unblocked" ? "Active" : "Blocked",
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFFE8F5E9),
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Quick Actions Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Grid of Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _ActionTile(
                      icon: Icons.electric_scooter_outlined,
                      title: "My Vehicle",
                      subtitle: "Track status",
                      iconBg: const Color(0xFFE3F2FD),
                      iconColor: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VehicleSectionScreen(
                              driverProfile: _driverProfile,
                            ),
                          ),
                        );
                      },
                    ),
                    _ActionTile(
                      icon: Icons.battery_charging_full_outlined,
                      title: "Battery Swap",
                      subtitle: "Swap history",
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SwapJourneyScreen()),
                        );
                      },
                    ),
                    _ActionTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "My Wallet",
                      subtitle: "Earnings & Bal",
                      iconBg: const Color(0xFFF3E5F5),
                      iconColor: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WalletScreen(
                              driverProfile: _driverProfile,
                            ),
                          ),
                        );
                      },
                    ),
                    _ActionTile(
                      icon: Icons.build_outlined,
                      title: "Maintenance",
                      subtitle: "Service history",
                      iconBg: const Color(0xFFFFF3E0),
                      iconColor: Colors.orange,
                      onTap: () {},
                    ),
                    _ActionTile(
                      icon: Icons.calendar_today_outlined,
                      title: "Hub Locator",
                      subtitle: "Find hubs",
                      iconBg: const Color(0xFFE0F2F1),
                      iconColor: Colors.teal,
                      onTap: () {},
                    ),
                    _ActionTile(
                      icon: Icons.headset_mic_outlined,
                      title: "Help Center",
                      subtitle: "Get support",
                      iconBg: const Color(0xFFFFEBEE),
                      iconColor: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFf5c034),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.crop_square_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.electric_scooter), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.battery_full), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: ""),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: iconColor.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
