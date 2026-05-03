import 'package:ShipRyd_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VehicleAllotmentScreen extends StatefulWidget {
  const VehicleAllotmentScreen({super.key});

  @override
  State<VehicleAllotmentScreen> createState() => _VehicleAllotmentScreenState();
}

class _VehicleAllotmentScreenState extends State<VehicleAllotmentScreen> {
  DateTime? selectedDate;
  bool videoWatched = false;
  final Map<String, bool> checklist = {};

  final sections = {
    "⚙️ Mechanical & Controls": [
      "Front and rear brakes working properly",
      "Throttle responding smoothly",
      "Handlebar alignment straight and firm",
      "Center stand / side stand functional",
    ],
    "💡 Electrical Components": [
      "Battery level meter displaying correctly",
      "Headlight working",
      "Tail light working",
      "Left and right indicators working",
      "Horn working",
      "Display screen (speedometer, etc.) working",
    ],
    "🧱 Body Condition": [
      "Headlight not broken or cracked",
      "Indicators not broken or loose",
      "Mirrors present and not cracked",
      "Seat not torn or damaged",
      "Footrest and floorboard intact",
      "Body panels not loose or heavily scratched",
    ],
    "🔋 Battery & Charging": [
      "Battery properly locked in position",
      "Charging port cover present and closed",
      "Charger cable (if provided) in good condition",
    ],
    "🧾 Miscellaneous": [
      "Scooter is clean and dry",
      "Number plate visible and undamaged",
      "No unusual sounds when riding",
    ],
  };

  @override
  void initState() {
    super.initState();
    for (var section in sections.values) {
      for (var item in section) {
        checklist[item] = false;
      }
    }
  }

  bool get allChecked => checklist.values.every((v) => v);

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFf5c034);
    const lightGray = Color(0xFFE8E6E6);

    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: yellow,
        centerTitle: true,
        title: const Text(
          "Vehicle Allotment",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Allotment Info
            Card(
              color: const Color(0xFFf5c034),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: lightGray, width: 2),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Allotment Code: #RIDZ12345",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      "Pickup Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Please visit your selected hub on the same day for scooter collection.",
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "⚠️ Your allotment code is valid only on the day of pickup. "
                      "If pickup is not done, you can reschedule once based on hub availability.",
                      style: TextStyle(color: Colors.blackAccent, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🟡 Reschedule Button
                        ElevatedButton.icon(
                          onPressed: pickDate,
                          icon: const Icon(Icons.calendar_month_outlined,
                              color: Colors.black),
                          label: const Text(
                            "Reschedule",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFf5c034),
                            elevation: 0,
                            side: const BorderSide(
                                color: Colors.black, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // ❌ Cancel Plan Button
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.cancel_outlined,
                              color: Colors.black),
                          label: const Text(
                            "Cancel Plan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: Colors.black, width: 1.5),

                            backgroundColor: const Color(0xFFf5c034), // light red tint
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "New Pickup Date: ${DateFormat('dd MMM yyyy').format(selectedDate!)}",
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text("Vehicle Checklist",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...sections.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                children: entry.value.map((item) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    trailing: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: checklist[item],
                        onChanged: (v) {
                          setState(() => checklist[item] = v ?? false);
                        },
                        shape: const CircleBorder(),
                        activeColor: const Color(0xFFf5c034), // yellow fill
                        checkColor: const Color(0xFFf5c034), // white tick
                        side: const BorderSide(
                            color: Color(0xFFE8E6E6), width: 1.5),
                      ),
                    ),
                    title: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 24),
            const Text("📽️ Rules & Regulations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Please watch the short training video below. "
              "You must complete it to accept the vehicle.",
            ),
            const SizedBox(height: 12),

            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, size: 64),
              ),
            ),
            const SizedBox(height: 12),

            // 🎥 Mark Video as Watched
            ElevatedButton(
              onPressed: () => setState(() => videoWatched = true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFf5c034), // color change
                foregroundColor: Colors.black,
                side: BorderSide(
                    color: videoWatched
                        ? const Color(0xFFf5c034)
                        : const Color.fromARGB(255, 232, 230, 230),
                    width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                videoWatched ? "✅ Video Watched" : "Mark Video as Watched",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Accept Vehicle
            ElevatedButton(
              onPressed: allChecked && videoWatched
                  ? () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFFf5c034),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFf5c034),
                                size: 60,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Vehicle Accepted ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Please proceed to the hub counter\nto collect your scooter.",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 120,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFf5c034),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const HomeScreen()),
                                    );
                                  },
                                  child: const Text(
                                    "OK",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFFf5c034),
                foregroundColor: Colors.black,
              ),
              child: const Text(
                "Accept Vehicle",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
