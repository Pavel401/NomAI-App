import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:turfit/app/components/buttons.dart';
import 'package:turfit/app/constants/colors.dart';
import 'package:turfit/app/modules/Onboarding/views/onboarding_progress_view.dart';

class OnboardingHome extends StatefulWidget {
  const OnboardingHome({super.key});

  @override
  State<OnboardingHome> createState() => _OnboardingHomeState();
}

class _OnboardingHomeState extends State<OnboardingHome> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageListener);
  }

  void _pageListener() {
    _currentPage.value = _pageController.page?.round() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Align(
            //   alignment: Alignment.topRight,
            //   child: TextButton(
            //     onPressed: () => context.go('/home'),
            //     child: Text(
            //       'Skip',
            //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //             color: MealAI.darkPrimary,
            //           ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => _currentPage.value = index,
                children: [
                  OnboardingPage(
                    svgAsset: 'assets/svg/welcome.svg',
                    title: 'Welcome to MealAI',
                    message: 'Today is the day to start tracking your health.',
                  ),
                  OnboardingPage(
                    svgAsset: 'assets/svg/nutrition.svg',
                    title: 'Track Your Meals',
                    message: 'Log your food and maintain a balanced diet.',
                  ),
                  OnboardingPage(
                    svgAsset: 'assets/svg/analytics.svg',
                    title: 'Monitor Your Progress',
                    message:
                        'Get insights and analytics to improve your health.',
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: WormEffect(
                dotWidth: 10,
                dotHeight: 10,
                spacing: 16,
                dotColor: MealAIColors.lightPrimaryVariant,
                activeDotColor: MealAIColors.darkPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, value, child) {
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: PrimaryButton(
                        tile: value == 2 ? 'Get Started' : 'Next',
                        onPressed: () {
                          if (value == 2) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OnboardingQuestionaries()));
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }));
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage extends StatelessWidget {
  final String svgAsset;
  final String title;
  final String message;

  const OnboardingPage({
    Key? key,
    required this.svgAsset,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svgAsset, height: 250),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MealAIColors.lightSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MealAIColors.lightSecondaryVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
