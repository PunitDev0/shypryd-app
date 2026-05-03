import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ← New import
import 'raise_ticket_screen.dart'; // Your existing import

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Color yellow = Color(0xFFFFD600);

  // Helpline numbers
  final String number1 = '7339966643';
  final String number2 = '9220424574';

  Future<void> _callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Launch error: $e');
    }
  }

  void _showHelplineBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6)[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Call Helpline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.phone, color: yellow),
              title: Text(number1,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              onTap: () {
                _callNumber(number1);
                Navigator.pop(context);
              },
              tileColor: Colors.black.withOpacity(0.6)[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.phone, color: yellow),
              title: Text(number2,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              onTap: () {
                _callNumber(number2);
                Navigator.pop(context);
              },
              tileColor: Colors.black.withOpacity(0.6)[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      body: Column(
        children: [
          // Yellow Header
          Stack(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                color: yellow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'How can we help\nyou today?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    const Center(
                      child: Text(
                        'Help Center',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Decorative circle
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf5c034).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6)[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for issues...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Support Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.9,
              children: [
                _HelpTile(
                  icon: Icons.support_agent,
                  iconColor: Colors.black,
                  iconBgColor: const Color(0xFFE3F2FD),
                  title: 'Raise Ticket',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RaiseTicketScreen()),
                    );
                  },
                ),
                _HelpTile(
                  icon: Icons.receipt_long,
                  iconColor: Colors.black,
                  iconBgColor: const Color(0xFFF3E5F5),
                  title: 'My Tickets',
                  onTap: () {},
                ),
                _HelpTile(
                  icon: Icons.phone_in_talk,
                  iconColor: Colors.black,
                  iconBgColor: const Color(0xFFFFF3E0),
                  title: 'Helpline',
                  onTap: () => _showHelplineBottomSheet(context),
                ),
                _HelpTile(
                  icon: Icons.play_lesson,
                  iconColor: Colors.black,
                  iconBgColor: const Color(0xFFE8F5E9),
                  title: 'Tutorials',
                  onTap: () {},
                ),
                _HelpTile(
                  icon: Icons.location_on,
                  iconColor: Colors.black,
                  iconBgColor: const Color(0xFFFFEBEE),
                  title: 'Hub Locator',
                  onTap: () {},
                ),
                _HelpTile(
                  icon: Icons.info,
                  iconColor: Colors.black,
                  iconBgColor: const Color(0xFFE0F2F1),
                  title: 'About App',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFf5c034),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.6).shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
