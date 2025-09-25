import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Analytics/model/analytics.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/utility/registry_service.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  Future<MonthlyAnalytics?>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      _future ??= serviceLocator<NutritionRecordRepo>()
          .getMonthlyAnalytics(userState.userModel.userId, DateTime.now());
    }
  }

  Widget _buildSummary(MonthlyAnalytics data) {
    final days = data.dailyAnalytics;
    int totalCalories = 0;
    int totalProtein = 0;
    int totalFat = 0;
    int totalCarbs = 0;
    int totalMeals = 0;
    int maxDayCalories = 0;

    for (final d in days) {
      totalCalories += d.totalCalories;
      totalProtein += d.totalProtein;
      totalFat += d.totalFat;
      totalCarbs += d.totalCarbs;
      totalMeals += d.mealCount;
      if (d.totalCalories > maxDayCalories) maxDayCalories = d.totalCalories;
    }

    final avgCalories = days.isNotEmpty ? (totalCalories / days.length).round() : 0;
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Monthly Analytics',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: MealAIColors.blackText,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            monthLabel,
            style: TextStyle(
              fontSize: 14,
              color: MealAIColors.grey,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric('Total Cal', totalCalories.toString()),
              _metric('Avg Cal', avgCalories.toString()),
              _metric('Meals', totalMeals.toString()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric('Protein', '${totalProtein}g'),
              _metric('Carbs', '${totalCarbs}g'),
              _metric('Fat', '${totalFat}g'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Daily breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MealAIColors.blackText,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...days.map((d) => _dailyTile(d, maxDayCalories)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: MealAIColors.blackText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: MealAIColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _dailyTile(DailyAnalytics d, int maxDayCalories) {
    final dayLabel = DateFormat('dd MMM').format(d.date);
    final percent = maxDayCalories > 0 ? (d.totalCalories / maxDayCalories) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MealAIColors.blackText.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              dayLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MealAIColors.blackText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: MealAIColors.gaugeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: MealAIColors.blackText,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${d.totalCalories} cal',
            style: TextStyle(
              fontSize: 12,
              color: MealAIColors.blackText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealAIColors.lightBackground,
      appBar: AppBar(
        backgroundColor: MealAIColors.lightSurface,
        elevation: 0.5,
        title: const Text(
          'Analytics',
          style: TextStyle(color: MealAIColors.blackText),
        ),
        iconTheme: const IconThemeData(color: MealAIColors.blackText),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserLoaded) {
            _future ??= serviceLocator<NutritionRecordRepo>()
                .getMonthlyAnalytics(state.userModel.userId, DateTime.now());
            return FutureBuilder<MonthlyAnalytics?>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load analytics',
                      style: TextStyle(color: MealAIColors.red),
                    ),
                  );
                }
                final data = snapshot.data;
                if (data == null || data.dailyAnalytics.isEmpty) {
                  return Center(
                    child: Text(
                      'No analytics for this month yet',
                      style: TextStyle(color: MealAIColors.grey),
                    ),
                  );
                }
                return SingleChildScrollView(child: _buildSummary(data));
              },
            );
          }
          if (state is UserError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: MealAIColors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
