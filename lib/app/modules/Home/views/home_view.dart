import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turfit/app/modules/Auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:turfit/app/modules/Scanner/bloc/bloc/ai_scan_bloc.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AiScanBloc>();
    final authBloc = context.read<SignInBloc>();

    return Scaffold(
      appBar: AppBar(title: Text('Nutrition Scan')),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // ✅ Add Event to Bloc
                  authBloc.add(SignOutRequired());
                },
                child: Text("Logout"),
              ),
            ],
          ),
          // ✅ Listen to Bloc State (like Obx())
          BlocBuilder<AiScanBloc, AiScanState>(
            builder: (context, state) {
              if (state is AiScanLoading) {
                return CircularProgressIndicator();
              }

              if (state is AiScanSuccess) {
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
