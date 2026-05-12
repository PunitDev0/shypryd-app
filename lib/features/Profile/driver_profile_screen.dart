import 'package:flutter/material.dart';
import 'package:Maxryd_app/features/driver/domain/entities/driver_profile.dart';

class DriverProfileScreen extends StatelessWidget {
  final DriverProfile driverProfile;

  const DriverProfileScreen({
    super.key,
    required this.driverProfile,
  });

  static const yellow = Color(0xFFf5c034);
  static const darkBg = Colors.black;
  static const darkCard = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: yellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Driver Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Profile Header with Avatar (Visual improvement)
            const SizedBox(height: 10),
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: yellow.withOpacity(0.3), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: darkCard,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: yellow, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Personal Details
            _sectionCard(
              icon: Icons.person_rounded,
              title: "Personal Details",
              children: [
                _ProfileRow(label: "Name", value: driverProfile.personalInformation?.fullName ?? "Not provided"),
                _ProfileRow(label: "Phone Number", value: driverProfile.phone),
                _ProfileRow(
                  label: "Gender",
                  value: driverProfile.personalInformation?.gender ?? "Not provided",
                ),
                _ProfileRow(
                  label: "Address",
                  value: driverProfile.personalInformation?.currentFullAddress ?? "Not provided",
                ),
                _ProfileRow(
                  label: "Region of Operation",
                  value: driverProfile.personalInformation?.serviceRegion ?? "Not provided",
                  showCopy: false,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Document Details
            _sectionCard(
              icon: Icons.description_rounded,
              title: "Document Details",
              children: [
                _ProfileRow(
                  label: "PAN Number",
                  value: _maskPan(driverProfile.panVerification?.panNumber ?? "Not provided"),
                ),
                _ProfileRow(
                  label: "Date of Birth",
                  value: driverProfile.panVerification?.dateOfBirth != null
                      ? driverProfile.panVerification!.dateOfBirth!.split('T')[0]
                      : "Not provided",
                ),
                _ProfileRow(
                  label: "Aadhaar Number",
                  value: _maskAadhaar(driverProfile.aadhaarVerification?.aadhaarNumber ?? "Not provided"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bank Details
            _sectionCard(
              icon: Icons.account_balance_rounded,
              title: "Bank Details",
              children: [
                _ProfileRow(
                  label: "Bank Name",
                  value: driverProfile.bankDetails?.bankName ?? "Not provided",
                ),
                _ProfileRow(
                  label: "Account Number",
                  value: _maskAccount(driverProfile.bankDetails?.accountNumber ?? "Not provided"),
                ),
                _ProfileRow(
                  label: "IFSC Code",
                  value: driverProfile.bankDetails?.ifscCode ?? "Not provided",
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status & Other Info
            _sectionCard(
              icon: Icons.info_rounded,
              title: "Account Status",
              children: [
                _ProfileRow(label: "Status", value: driverProfile.status),
                _ProfileRow(label: "Profile Completed", value: driverProfile.isProfileCompleted ? "Yes" : "No"),
                _ProfileRow(label: "Online", value: driverProfile.isOnline ? "Yes" : "No"),
                _ProfileRow(label: "Rating", value: driverProfile.rating.toString()),
                _ProfileRow(label: "Total Trips", value: driverProfile.totalTrips.toString()),
                _ProfileRow(label: "Wallet Balance", value: "₹${driverProfile.walletBalance}"),
              ],
            ),
            const SizedBox(height: 35),

            _logoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: yellow.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: yellow),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement logout
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          "Logout Account",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          foregroundColor: Colors.redAccent,
          elevation: 0,
          side: const BorderSide(color: Colors.redAccent, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  // Masking helpers for sensitive data
  String _maskPan(String pan) {
    if (pan.length < 10) return pan;
    return '${pan.substring(0, 2)}${'*' * (pan.length - 4)}${pan.substring(pan.length - 2)}';
  }

  String _maskAadhaar(String aadhaar) {
    if (aadhaar.length < 12) return aadhaar;
    return '${aadhaar.substring(0, 4)}${'*' * 4}${aadhaar.substring(8)}';
  }

  String _maskAccount(String account) {
    if (account.length < 8) return account;
    return '${'*' * (account.length - 4)}${account.substring(account.length - 4)}';
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showCopy;

  const _ProfileRow({
    required this.label,
    required this.value,
    this.showCopy = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          if (showCopy)
            IconButton(
              icon: Icon(Icons.copy_rounded, size: 18, color: Colors.white.withOpacity(0.2)),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}