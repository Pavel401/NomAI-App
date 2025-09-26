import 'package:NomAi/app/modules/Analytics/views/analytics_view.dart';
import 'package:NomAi/app/modules/Chat/Views/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Home/views/home_view.dart';
import 'package:NomAi/app/modules/Scanner/views/scan_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

// Helper widget to reduce repetition
  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData selectedIcon,
    required IconData unselectedIcon,
  }) {
    final bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              size: 26,
              color: isSelected
                  ? MealAIColors.blackText
                  : MealAIColors.stepperColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? MealAIColors.blackText
                    : MealAIColors.stepperColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: MealAIColors.lightBackground,
      extendBody: true,
      floatingActionButton: _selectedIndex == 0
          ? Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: MealAIColors.blackText,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: MealAIColors.blackText,
                elevation: 0,
                shape: const CircleBorder(),
                onPressed: () {
                  // Preserve existing UserBloc when navigating via GetX
                  try {
                    final userBloc = context.read<UserBloc>();
                    Get.to(() => BlocProvider.value(
                          value: userBloc,
                          child: MealAiCamera(),
                        ));
                  } catch (_) {
                    // Fallback if bloc not found; navigate as-is
                    Get.to(() => MealAiCamera());
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Lottie.asset(
                    'assets/lottie/scan.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomAppBar(
        height: 65,
        color: MealAIColors.switchWhiteColor,
        elevation: 20,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              index: 0,
              label: 'Home',
              selectedIcon: Icons.home, // filled
              unselectedIcon: Icons.home_outlined, // outline
            ),
            _buildNavItem(
              index: 1,
              label: 'Analytics',
              selectedIcon: Icons.insert_chart, // better filled analytics
              unselectedIcon: Icons.insert_chart_outlined, // outline
            ),
            _buildNavItem(
              index: 2,
              label: 'Chat',
              selectedIcon: Icons.chat, // filled
              unselectedIcon: Icons.chat_outlined, // outline
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          AnalyticsView(),
          NomAiAgentView(),
        ],
      ),
    );
  }
}
