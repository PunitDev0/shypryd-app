import 'package:ShipRyd_app/features/onboarding/presentation/pages/plan_selection_screen.dart';
import 'package:flutter/material.dart';


class HubSelectionScreen extends StatefulWidget {
  const HubSelectionScreen({super.key});

  @override
  State<HubSelectionScreen> createState() => _HubSelectionScreenState();
}

class _HubSelectionScreenState extends State<HubSelectionScreen> {
  String? selectedHub;

  // Example hub data (you can later fetch this via API or BLoC)
  final List<Map<String, dynamic>> hubs = [
    {'name': 'Uttam Nagar', 'available': 4, 'waitlist': 0},
    {'name': 'South Delhi', 'available': 0, 'waitlist': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf5c034),
        centerTitle: true,
        title: const Text(
          "Select Your Hub",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a hub near you to get started:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // List of Hubs
            Expanded(
              child: ListView(
                children: hubs.map((hub) {
                  final String name = hub['name']?.toString() ?? '';
                  final int available = hub['available'] is int
                      ? hub['available'] as int
                      : int.tryParse(hub['available'].toString()) ?? 0;
                  final int waitlist = hub['waitlist'] is int
                      ? hub['waitlist'] as int
                      : int.tryParse(hub['waitlist'].toString()) ?? 0;

                  final bool hasAvailability = available > 0;
                  final bool isSelected = selectedHub == name;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedHub = name;
                      });
                    },
                    child: Card(
                      color: const Color(0xFFf5c034),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFFf5c034)
                              : const Color.fromARGB(255, 232, 230, 230),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 24,
                              color: isSelected
                                  ? const Color(0xFFf5c034)
                                  : const Color.fromARGB(255, 232, 230, 230),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasAvailability
                                        ? "Scooters Available: $available"
                                        : "Waitlist: $waitlist",
                                    style: TextStyle(
                                      color: hasAvailability
                                          ? Colors.black
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Color(0xFFf5c034)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              "💡 It is recommended that you select a hub close to the area you’re willing to operate in for smooth off-road maintenance and support.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedHub == null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Selected Hub: $selectedHub"),
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlanSelectionScreen(),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFffd700),
                  disabledBackgroundColor: Colors.black.withOpacity(0.6)[400],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
