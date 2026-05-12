import 'dart:async';
import 'package:Maxryd_app/features/BatterySwap/swap_journey_screen.dart';
import 'package:Maxryd_app/features/Profile/driver_profile_screen.dart';
import 'package:Maxryd_app/features/driver/data/datasources/driver_remote_datasource.dart';
import 'package:Maxryd_app/features/driver/data/repositories/driver_repository_impl.dart';
import 'package:Maxryd_app/features/driver/domain/entities/driver_profile.dart';
import 'package:Maxryd_app/features/driver/domain/usecases/fetch_driver_profile.dart';
import 'package:Maxryd_app/features/helpCenter/help_center_screen.dart';
import 'package:Maxryd_app/features/vehicleSection/vehicle_section_screen.dart';
import 'package:Maxryd_app/features/wallet/presentation/pages/my_subscription_screen.dart';
import 'package:Maxryd_app/features/wallet/presentation/pages/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  DriverProfile? _driverProfile;
  bool _isLoadingProfile = true;
  String? _profileError;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_driverProfile?.activeSubscription?.endDate == null) return;

    final endDate = DateTime.tryParse(_driverProfile!.activeSubscription!.endDate!);
    if (endDate == null) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = endDate.difference(now);

      if (diff.isNegative) {
        timer.cancel();
        setState(() => _remainingTime = Duration.zero);
      } else {
        setState(() => _remainingTime = diff);
      }
    });
  }

  Future<void> _fetchDriverProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('No auth token found');

      final remote = DriverRemoteDataSourceImpl();
      final repo = DriverRepositoryImpl(remoteDataSource: remote);
      final usecase = FetchDriverProfile(repo);

      final result = await usecase(token);

      result.fold(
        (failure) => setState(() {
          _profileError = failure.toString();
          _isLoadingProfile = false;
        }),
        (profile) async {
          await storage.write(key: 'driverId', value: profile.id);
          setState(() {
            _driverProfile = profile;
            _isLoadingProfile = false;
          });
          _startCountdown();
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

  @override
  Widget build(BuildContext context) {
    final greeting = _timeGreeting;
    final userName = _greetingName;

    String planRemaining = "No Plan";
    if (_driverProfile?.activeSubscription != null && _remainingTime != Duration.zero) {
      int days = _remainingTime.inDays;
      int hours = _remainingTime.inHours.remainder(24);
      planRemaining = "$days Days, $hours Hours";
    }

    const yellowAccent = Color(0xFFf5c034);
    const darkCardBg = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true, // Important for floating nav
      drawer: _buildSidebar(yellowAccent),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(greeting, userName, yellowAccent),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildSummarySection(planRemaining, yellowAccent, darkCardBg),
                  const SizedBox(height: 25),
                  if (_driverProfile?.activeSubscription == null && !_isLoadingProfile)
                    _buildSubscriptionNudge(yellowAccent),
                  _buildQuickActionsHeader(yellowAccent),
                  const SizedBox(height: 15),
                  _buildQuickActionsGrid(yellowAccent, darkCardBg),
                  const SizedBox(height: 120), // Extra space for floating nav
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(yellowAccent),
    );
  }

  // ==================== Sidebar / Drawer ====================
  Widget _buildSidebar(Color yellowAccent) {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: yellowAccent, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _greetingName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  _driverProfile?.phone ?? "No Number",
                  style: TextStyle(color: yellowAccent.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildDrawerItem(Icons.dashboard_rounded, "Home", yellowAccent, () => Navigator.pop(context)),
                _buildDrawerItem(Icons.person_outline_rounded, "My Profile", yellowAccent, () {
                  Navigator.pop(context);
                  if (_driverProfile != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DriverProfileScreen(driverProfile: _driverProfile!)));
                  }
                }),
                _buildDrawerItem(Icons.electric_scooter_rounded, "My Vehicle", yellowAccent, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => VehicleSectionScreen(driverProfile: _driverProfile)));
                }),
                _buildDrawerItem(Icons.account_balance_wallet_outlined, "My Wallet", yellowAccent, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WalletScreen(driverProfile: _driverProfile)));
                }),
                _buildDrawerItem(Icons.support_agent_rounded, "Help Center", yellowAccent, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
                }),
              ],
            ),
          ),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ListTile(
              onTap: () {
                // Handle Logout
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              tileColor: Colors.redAccent.withOpacity(0.05),
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Color yellowAccent, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: yellowAccent, size: 24),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  // ==================== Floating Bottom Navigation ====================
  Widget _buildModernBottomNav(Color yellowAccent) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: yellowAccent,
            unselectedItemColor: Colors.grey[500],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded, size: 24),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.electric_scooter_rounded, size: 24),
                label: "Vehicle",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.battery_saver_rounded, size: 24),
                label: "Swap",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 24),
                label: "Profile",
              ),
            ],
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Rest of your widgets remain the same...
  Widget _buildSliverHeader(String greeting, String userName, Color yellowAccent) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.notes_rounded, size: 28, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Row(
            children: [
              const Text(
                "ShypRyd",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Icon(Icons.bolt, color: yellowAccent, size: 22),
            ],
          ),
          _buildProfileAvatar(yellowAccent),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: yellowAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: yellowAccent.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    greeting,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(Color yellowAccent) {
    return GestureDetector(
      onTap: () {
        if (_driverProfile != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DriverProfileScreen(driverProfile: _driverProfile!)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: yellowAccent.withOpacity(0.5), width: 2),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF1E1E1E),
          child: _isLoadingProfile
              ? SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: yellowAccent))
              : const Icon(Icons.person, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildSummarySection(String planRemaining, Color yellowAccent, Color darkCardBg) {
    return Row(
      children: [
        Expanded(
          child: _ModernSummaryCard(
            title: "Plan Status",
            value: planRemaining,
            icon: Icons.timer_rounded,
            color: yellowAccent,
            bgColor: darkCardBg,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _ModernSummaryCard(
            title: "Swap Status",
            value: _driverProfile?.swapStatus == "unblocked" ? "Active" : "Blocked",
            icon: Icons.battery_charging_full_rounded,
            color: yellowAccent,
            bgColor: darkCardBg,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionNudge(Color yellowAccent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: yellowAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: yellowAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: yellowAccent.withOpacity(0.2),
            child: Icon(Icons.info_outline, color: yellowAccent),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "No active plan. Subscribe to start swapping!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MySubscriptionScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: yellowAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              elevation: 0,
            ),
            child: const Text("Plans", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsHeader(Color yellowAccent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        TextButton(
          onPressed: () {},
          child: Text("See All", style: TextStyle(color: yellowAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(Color yellowAccent, Color darkCardBg) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _ModernActionCard(
          icon: Icons.electric_scooter_rounded,
          title: "My Vehicle",
          color: yellowAccent,
          bgColor: darkCardBg,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VehicleSectionScreen(driverProfile: _driverProfile))),
        ),
        _ModernActionCard(
          icon: Icons.swap_horiz_rounded,
          title: "Battery Swap",
          color: yellowAccent,
          bgColor: darkCardBg,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SwapJourneyScreen())),
        ),
        _ModernActionCard(
          icon: Icons.account_balance_wallet_rounded,
          title: "Earnings",
          color: yellowAccent,
          bgColor: darkCardBg,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WalletScreen(driverProfile: _driverProfile))),
        ),
        _ModernActionCard(
          icon: Icons.support_agent_rounded,
          title: "Help Center",
          color: yellowAccent,
          bgColor: darkCardBg,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
        ),
      ],
    );
  }
}

// Keep your existing _ModernSummaryCard and _ModernActionCard classes
class _ModernSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _ModernSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

class _ModernActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ModernActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}