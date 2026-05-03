import 'package:flutter/material.dart';
import 'package:ShipRyd_app/features/driver/domain/entities/driver_profile.dart';

class DriverProfileScreen extends StatelessWidget {
  final DriverProfile driverProfile;

  const DriverProfileScreen({
    super.key,
    required this.driverProfile,
  });

  static const yellow = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5c034),
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Driver Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Personal Details
            _sectionCard(
              icon: Icons.person,
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
            const SizedBox(height: 16),

            // Document Details
            _sectionCard(
              icon: Icons.description,
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
            const SizedBox(height: 16),

            // Bank Details
            _sectionCard(
              icon: Icons.account_balance,
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
            const SizedBox(height: 24),

            // Status & Other Info
            _sectionCard(
              icon: Icons.info,
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
            const SizedBox(height: 24),

            _logoutButton(),
            const SizedBox(height: 24),
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
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: yellow.withOpacity(0.25),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  static Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement logout (clear token, navigate to login)
        },
        icon: const Icon(Icons.logout),
        label: const Text(
          "Logout",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: const Color(0xFFf5c034),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

/// Reusable Profile Row
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.6)),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (showCopy)
            Icon(
              Icons.copy,
              size: 18,
              color: Colors.black.withOpacity(0.6).shade600,
            ),
        ],
      ),
    );
  }
}