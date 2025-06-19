import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:NomAi/app/modules/Settings/views/adjust_goals.dart';
import 'package:NomAi/app/repo/firebase_user_repo.dart';

import 'edit_profile.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Toggle button state
  bool isCaloriesBurnedEnabled = false;

  late ScannerController _scannerController;
  late String _userId;

  DateTime _selectedDate = DateTime.now();

  late AuthenticationBloc authenticationBloc;
  final FirebaseUserRepo _userRepository = FirebaseUserRepo();

  UserModel? userModel;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize scanner controller
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.user == null) {
      setState(() {
        _errorMessage = 'User not authenticated. Please log in again.';
        _isLoading = false;
      });
      return;
    }

    _userId = authState.user!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
        body: FutureBuilder(
          future: _userRepository.getUserById(_userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              UserModel? userModel = snapshot.data;
              UserMacros userMacros = userModel!.userInfo!.userMacros;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal stats section
                      _buildPersonalStat(
                          'Age', userModel.userInfo!.age.toString()),
                      const SizedBox(height: 16),
                      _buildPersonalStat(
                          'Height', '${userModel.userInfo!.currentHeight} cm'),
                      const SizedBox(height: 16),
                      _buildPersonalStat('Current Weight',
                          '${userModel.userInfo!.currentWeight} kg'),
                      SizedBox(height: 2.h),

                      const Divider(thickness: 1),

                      // Customization section
                      SizedBox(height: 2.h),
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
                          Get.to(
                            () => EditUserBasicInfoView(
                              userBasicInfo: userModel.userInfo!,
                              userModel: userModel,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 2.h),
                      _buildNavigationItem(
                        'Adjust goals',
                        subtitle: 'Calories, carbs, fats, and protein',
                        onTap: () {
                          Get.to(() => AdjustGoalsView(
                                userMacros: userModel.userInfo!.userMacros,
                                userBasicInfo: userModel.userInfo,
                                userModel: userModel,
                              ));
                        },
                      ),
                      SizedBox(height: 2.h),

                      const Divider(thickness: 1),

                      // Preferences section
                      SizedBox(height: 2.h),
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
                      SizedBox(height: 2.h),

                      const Divider(thickness: 1),
                      SizedBox(height: 2.h),

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
              );
            }
          },
        ));
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
