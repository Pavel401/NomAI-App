import 'package:NomAi/app/modules/Chat/Views/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: MealAIColors.lightBackground,
      extendBody: true,

      floatingActionButton: Container(
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

            Get.to(() => MealAiCamera());
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Lottie.asset(
              'assets/lottie/scan.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

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
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _onItemTapped(0);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 24,
                      color: _selectedIndex == 0
                          ? MealAIColors.blackText
                          : MealAIColors.stepperColor,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 11,
                        color: _selectedIndex == 0
                            ? MealAIColors.blackText
                            : MealAIColors.stepperColor,
                        fontWeight: _selectedIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(child: Container()),

            Expanded(
              child: GestureDetector(
                onTap: () => _onItemTapped(2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 24,
                      color: _selectedIndex == 2
                          ? MealAIColors.blackText
                          : MealAIColors.stepperColor,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 11,
                        color: _selectedIndex == 2
                            ? MealAIColors.blackText
                            : MealAIColors.stepperColor,
                        fontWeight: _selectedIndex == 2
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          Center(child: Text('📷 QR Scan Screen')),
          NomAiAgentView(),
        ],
      ),
    );
  }
}
