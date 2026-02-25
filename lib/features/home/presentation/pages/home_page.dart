import 'package:Maxryd_app/features/BatterySwap/swap_journey_screen.dart';
import 'package:Maxryd_app/features/FeedbackSection/share_feedback_screen.dart';
import 'package:Maxryd_app/features/Profile/driver_profile_screen.dart';
import 'package:Maxryd_app/features/driver/data/datasources/driver_remote_datasource.dart';
import 'package:Maxryd_app/features/driver/data/repositories/driver_repository_impl.dart';
import 'package:Maxryd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:Maxryd_app/features/driver/domain/usecases/fetch_driver_profile.dart';
import 'package:Maxryd_app/features/helpCenter/help_center_screen.dart';
import 'package:Maxryd_app/features/vehicleSection/vehicle_section_screen.dart';
import 'package:Maxryd_app/features/wallet/presentation/pages/wallet_started_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
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
        },
      );
    } catch (e) {
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
        Navigator.push(
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
    final greeting = "$_timeGreeting, $_greetingName !";
    const subtitle = "Ready to start your journey today?";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        } else if (_profileError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Profile load error: $_profileError')),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.yellow,
                        child: _isLoadingProfile
                            ? const CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2)
                            : const Icon(Icons.person, color: Colors.black),
                      )),
                  const SizedBox(width: 12),
                  const Spacer(),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ShareFeedbackScreen(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.yellow,
                        child: Icon(Icons.star, color: Colors.black),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  'assets/images/MaxRyd.jpeg',
                  fit: BoxFit.contain,
                  height: 140,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _HomeTile(
                    icon: Icons.electric_scooter,
                    label: 'My Vehicle',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VehicleSectionScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeTile(
                    icon: Icons.battery_charging_full,
                    label: 'Battery Swap',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SwapJourneyScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeTile(
                    icon: Icons.support_agent,
                    label: 'Help Center',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HelpCenterScreen()),
                      );
                    },
                  ),
                  _HomeTile(
                    icon: Icons.account_balance_wallet,
                    label: 'Wallet',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WalletEmptyScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFFAFA),
        selectedItemColor: Colors.yellow[800],
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.electric_scooter), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.battery_full), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _HomeTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.black),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
