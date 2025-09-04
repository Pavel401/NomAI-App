class ChatMessageRequest {
  final String prompt;
  final String userId;
  final String? localTime;
  final List<String>? dietaryPreferences;
  final List<String>? allergies;
  final List<String>? selectedGoals;
  final String? foodImage;

  ChatMessageRequest({
    required this.prompt,
    required this.userId,
    this.localTime,
    this.dietaryPreferences,
    this.allergies,
    this.selectedGoals,
    this.foodImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'user_id': userId,
      'local_time': localTime,
      'dietary_preferences': dietaryPreferences,
      'allergies': allergies,
      'selected_goals': selectedGoals,
      'foodImage': foodImage,
    };
  }

  factory ChatMessageRequest.fromJson(Map<String, dynamic> json) {
    return ChatMessageRequest(
      prompt: json['prompt'] as String,
      userId: json['user_id'] as String,
      localTime: json['local_time'] as String?,
      dietaryPreferences: json['dietary_preferences'] != null
          ? List<String>.from(json['dietary_preferences'])
          : null,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      selectedGoals: json['selected_goals'] != null
          ? List<String>.from(json['selected_goals'])
          : null,
      foodImage: json['foodImage'] as String?,
    );
  }
}
