import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ← New import
import 'raise_ticket_screen.dart'; // Your existing import

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Color yellow = Color(0xFFFFD600);

  // Helpline numbers
  final String number1 = '7339966643';
  final String number2 = '9220424574';

  // Function to open phone dialer
  Future<void> _callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);

    print('Attempting to dial: $uri'); // for your logs

    try {
      if (await canLaunchUrl(uri)) {
        print('Dialer can be launched → opening');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('canLaunchUrl returned false → no dialer found');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Could not open dialer. Please dial $number manually.'),
        //     duration: const Duration(seconds: 5),
        //   ),
        // );
      }
    } catch (e) {
      print('Launch error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error opening dialer: $e\nTry dialing $number manually.'),
      //     duration: const Duration(seconds: 5),
      //   ),
      // );
    }
  }

  // Show bottom sheet with helpline numbers
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
                color: Colors.grey[400],
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
            const SizedBox(height: 8),
            const Text(
              'Reach out to our support team',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Number 1
            ListTile(
              leading: const Icon(Icons.phone, color: yellow),
              title: Text(
                number1,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Tap to call'),
              onTap: () {
                _callNumber(number1);
                Navigator.pop(context); // close sheet after tap
              },
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            const SizedBox(height: 12),

            // Number 2
            ListTile(
              leading: const Icon(Icons.phone, color: yellow),
              title: Text(
                number2,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Tap to call'),
              onTap: () {
                _callNumber(number2);
                Navigator.pop(context);
              },
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose from the options below to get assistance',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            /// GRID OPTIONS
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 0.9,
                children: [
                  _HelpTile(
                    icon: Icons.support_agent,
                    title: 'Raise Ticket',
                    subtitle: 'Report an issue or get help',
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
                    title: 'My Tickets',
                    subtitle: 'View your support tickets',
                    onTap: () {},
                  ),
                  _HelpTile(
                    icon: Icons.call,
                    title: 'Call Helpline',
                    subtitle: 'Talk to our support team',
                    onTap: () => _showHelplineBottomSheet(context), // ← Updated
                  ),
                  _HelpTile(
                    icon: Icons.play_circle_outline,
                    title: 'Training Videos',
                    subtitle: 'Watch helpful tutorials',
                    onTap: () {},
                  ),
                  _HelpTile(
                    icon: Icons.electric_scooter,
                    title: 'Hub',
                    subtitle: 'Hub Details',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.black, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
