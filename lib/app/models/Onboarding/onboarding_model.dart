import 'package:flutter/widgets.dart';

class OnboardingModel {
  final String title;
  final String description;
  final Widget Function(BuildContext) widgetBuilder;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.widgetBuilder,
  });
}
