import 'package:flutter/material.dart';

class ShareFeedbackScreen extends StatefulWidget {
  const ShareFeedbackScreen({super.key});

  @override
  State<ShareFeedbackScreen> createState() => _ShareFeedbackScreenState();
}

class _ShareFeedbackScreenState extends State<ShareFeedbackScreen> {
  static const yellow = Color(0xFFFFD700);
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Share Feedback",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _welcomeCard(),
            const SizedBox(height: 16),
            _ratingCard(),
            const SizedBox(height: 16),
            _feedbackCard(),
            const SizedBox(height: 16),
            _voiceCard(),
            const SizedBox(height: 16),
            _photoCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 🔹 Welcome Card
  Widget _welcomeCard() {
    return _card(
      child: const Column(
        children: [
          Icon(Icons.feedback_outlined, size: 48, color: yellow),
          SizedBox(height: 12),
          Text(
            "Hi Shishant Sharma!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            "Help us improve your delivery experience",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  /// ⭐ Rating Card
  Widget _ratingCard() {
    return _card(
      child: Column(
        children: [
          const Text(
            "Rate Your Experience",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isSelected = index < rating;
              return IconButton(
                onPressed: () {
                  setState(() => rating = index + 1);
                },
                icon: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  color: yellow,
                  size: 32,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// ✍️ Feedback Text
  Widget _feedbackCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tell us more (Optional)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Share your experience with us...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎙 Voice Message
  Widget _voiceCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mic),
              SizedBox(width: 8),
              Text(
                "Voice Message (Optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mic),
              label: const Text(
                "Start Recording",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📷 Add Photo
  Widget _photoCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image),
              SizedBox(width: 8),
              Text(
                "Add Photo (Optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withOpacity(0.6).shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.black.withOpacity(0.6)),
                SizedBox(height: 8),
                Text("Tap to add photo", style: TextStyle(color: Colors.black.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔲 Common Card Wrapper
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf5c034),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
