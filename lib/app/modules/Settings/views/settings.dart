import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_profile.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Toggle button state
  bool isCaloriesBurnedEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECECEC),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal stats section
              _buildPersonalStat('Age', '23'),
              const SizedBox(height: 16),
              _buildPersonalStat('Height', '183.0 cm'),
              const SizedBox(height: 16),
              _buildPersonalStat('Current Weight', '108 kg'),
              const Divider(thickness: 1),

              // Customization section
              const SizedBox(height: 16),
              const Text(
                'Customization',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              _buildNavigationItem(
                'Personal details',
                onTap: () {
                  Get.to(() => const EditProfile());
                },
              ),
              const SizedBox(height: 16),
              _buildNavigationItem('Adjust goals',
                  subtitle: 'Calories, carbs, fats, and protein'),
              const Divider(thickness: 1),

              // Preferences section
              const SizedBox(height: 16),
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              _buildToggleItem(
                  'Burned Calories',
                  'Add burned calories to daily goal',
                  isCaloriesBurnedEnabled, (value) {
                setState(() {
                  isCaloriesBurnedEnabled = value;
                });
              }),
              const Divider(thickness: 1),

              // Legal section
              const SizedBox(height: 16),
              const Text(
                'Legal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              _buildNavigationItem('Terms and Conditions'),
              const SizedBox(height: 16),
              _buildNavigationItem('Privacy Policy'),
              const SizedBox(height: 16),
              _buildNavigationItem('Delete Account?'),
              const SizedBox(height: 16),

              // Version information
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'VERSION 1.0.62',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),

              // Space at the bottom for floating action button
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for personal stats like height, weight, age
  Widget _buildPersonalStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  // Widget for toggle switch items
  Widget _buildToggleItem(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
        ),
      ],
    );
  }
}
