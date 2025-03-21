import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';
import 'package:turfit/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:turfit/app/modules/Home/bloc/bloc/user_nutrition_record_bloc.dart';
import 'package:turfit/app/modules/Scanner/bloc/bloc/ai_scan_bloc.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  DailyNutritionRecords dailyNutritionRecords = DailyNutritionRecords(
    dailyRecords: [],
    recordDate: DateTime.now(),
    recordId: "1",
  );
  @override
  void initState() {
    // TODO: implement initState

    final bloc = context.read<AiScanBloc>();
    final authBloc = context.read<AuthenticationBloc>();

    final nutritionrecordBloc = context.read<UserNutritionRecordBloc>();

    DateTime selectedDate = DateTime.now();

    nutritionrecordBloc.add(UserNutritionRecordInitialized(
      authBloc.state.user!.uid,
      selectedDate,
    ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nutrition Scan')),
      body: Column(
        children: [
          BlocBuilder<UserNutritionRecordBloc, UserNutritionRecordState>(
            builder: (context, state) {
              if (state is UserNutritionRecordLoading) {
                return CircularProgressIndicator();
              }
              if (state is UserNutritionRecordSuccess) {
                dailyNutritionRecords = state.nutritionRecords;
                return ListView.builder(
                    itemCount: dailyNutritionRecords.dailyRecords.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final record = dailyNutritionRecords.dailyRecords[index];
                      return ListTile(
                        title: Text(
                          record.nutritionOutput.response.toString(),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          record.nutritionOutput.executionTimeSeconds
                              .toString(),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      );
                    });
              }
              if (state is UserNutritionRecordFailure) {
                return Text("Error: ${state.message}");
              }
              return SizedBox();
            },
          ),
          BlocBuilder<AiScanBloc, AiScanState>(
            builder: (context, state) {
              if (state is AiScanLoading) {
                return CircularProgressIndicator();
              }

              if (state is AiScanSuccess) {
                dailyNutritionRecords.dailyRecords.add(NutritionRecord(
                  nutritionOutput: state.nutritionOutput,
                  recordTime: DateTime.now(),
                  scanMode: state.nutritionInputQuery.scanMode,
                ));

                context.read<UserNutritionRecordBloc>().add(UserNutritionAdded(
                      context.read<AuthenticationBloc>().state.user!.uid,
                      dailyNutritionRecords,
                    ));
                return Text(
                    "Calories: ${state.nutritionOutput.executionTimeSeconds}");
              }

              if (state is AiScanFailure) {
                return Text("Error: ${state.message}");
              }

              return Text("Press the button to scan");
            },
          ),
        ],
      ),
    );
  }
}
