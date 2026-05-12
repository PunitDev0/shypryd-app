import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'raise_ticket_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Color yellow = Color(0xFFf5c034);
  static const Color darkBg = Colors.black;
  static const Color darkCard = Color(0xFF1E1E1E);

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
      debugPrint('Launch error: $e');
    }
  }

  void _showHelplineBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Call Helpline',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            _HelplineTile(number: number1, yellow: yellow, onTap: () {
              _callNumber(number1);
              Navigator.pop(context);
            }),
            const SizedBox(height: 15),
            _HelplineTile(number: number2, yellow: yellow, onTap: () {
              _callNumber(number2);
              Navigator.pop(context);
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Column(
        children: [
          // Premium Curved Header
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF1A1A1A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: yellow, size: 24),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 25),
                const Text(
                  'How can we help\nyou today?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'SUPPORT HUB',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: yellow.withOpacity(0.5),
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search for issues...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      icon: Icon(Icons.search_rounded, color: yellow, size: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  'Support Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _HelpTile(
                  icon: Icons.support_agent_rounded,
                  color: Colors.blueAccent,
                  title: 'Raise Ticket',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RaiseTicketScreen()),
                    );
                  },
                ),
                _HelpTile(
                  icon: Icons.receipt_long_rounded,
                  color: Colors.purpleAccent,
                  title: 'My Tickets',
                  onTap: () {},
                ),
                _HelpTile(
                  icon: Icons.phone_in_talk_rounded,
                  color: yellow,
                  title: 'Helpline',
                  onTap: () => _showHelplineBottomSheet(context),
                ),
                _HelpTile(
                  icon: Icons.play_lesson_rounded,
                  color: Colors.greenAccent,
                  title: 'Tutorials',
                  onTap: () {},
                ),
                _HelpTile(
                  icon: Icons.location_on_rounded,
                  color: Colors.redAccent,
                  title: 'Hub Locator',
                  onTap: () {},
                ),
                _HelpTile(
                  icon: Icons.info_rounded,
                  color: Colors.tealAccent,
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
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelplineTile extends StatelessWidget {
  final String number;
  final Color yellow;
  final VoidCallback onTap;

  const _HelplineTile({required this.number, required this.yellow, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(Icons.phone_rounded, color: yellow, size: 22),
              const SizedBox(width: 15),
              Text(
                number,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
