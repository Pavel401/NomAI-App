import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Response;
import 'package:NomAi/app/models/Agent/agent_response.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/repo/agent_service.dart';

class ChatController extends GetxController {
  final AgentService _agentService = AgentService();
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController userIdController =
      TextEditingController(text: 'Pavel');

  final RxList<AgentResponse> messages = <AgentResponse>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isDemoMode = false.obs;

  AgentResponse? currentStreamingMessage;
  StreamSubscription? _messageSubscription;

  List<String> dietaryPreferences = [];
  List<String> allergies = [];

  List<String> selectedGoals = [];

  @override
  void onInit() {
    super.onInit();
    userIdController.addListener(_onUserIdChanged);
    loadChatHistory();
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    userIdController.dispose();
    _messageSubscription?.cancel();
    super.onClose();
  }

  void _onUserIdChanged() {
    messages.clear();
    errorMessage.value = '';
    update(); // Trigger GetBuilder update for user ID display
    loadChatHistory();
  }

  Future<void> loadChatHistory() async {
    if (userIdController.text.trim().isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final history =
          await _agentService.getChatHistory(userIdController.text.trim());
      messages.value = history;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      errorMessage.value = 'Failed to load chat history: $e';
      isDemoMode.value = true;
      _addDemoMessages();
    } finally {
      isLoading.value = false;
    }
  }

  void _addDemoMessages() {
    final demoNotification = AgentResponse(
      role: 'model',
      timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
      content:
          '🔧 Demo Mode Active: API server not available. Showing sample nutrition data. Try asking about "pizza", "salad", "burger", "apple", or "banana" for demo responses!',
      isFinal: true,
    );

    final demoMessages = [
      demoNotification,
      AgentResponse(
        role: 'user',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        content:
            'Tell me about the nutrition of a chicken salad with mixed vegetables',
        isFinal: true,
      ),
      AgentResponse(
        role: 'model',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        content:
            'I\'ll analyze the nutritional content of your chicken salad with mixed vegetables.',
        isFinal: true,
        toolReturns: [
          ToolReturn(
            toolCallId: 'demo_call',
            toolName: 'calculate_nutrition_by_food_description',
            content: Content(
              response: Response(
                message: 'Nutrition analysis complete',
                foodName: 'Chicken Salad with Mixed Vegetables',
                portion: 'cup',
                portionSize: 2,
                confidenceScore: 8,
                ingredients: [
                  Ingredient(
                    name: 'Grilled Chicken Breast',
                    calories: 165,
                    protein: 31,
                    carbs: 0,
                    fiber: 0,
                    fat: 4,
                    healthScore: 9,
                    healthComments:
                        'Excellent source of lean protein, supports muscle maintenance and growth.',
                  ),
                  Ingredient(
                    name: 'Mixed Lettuce',
                    calories: 10,
                    protein: 1,
                    carbs: 2,
                    fiber: 1,
                    fat: 0,
                    healthScore: 8,
                    healthComments:
                        'Rich in vitamins A and K, provides fiber and antioxidants.',
                  ),
                  Ingredient(
                    name: 'Cherry Tomatoes',
                    calories: 18,
                    protein: 1,
                    carbs: 4,
                    fiber: 1,
                    fat: 0,
                    healthScore: 9,
                    healthComments:
                        'High in lycopene and vitamin C, supports heart health.',
                  ),
                  Ingredient(
                    name: 'Cucumber',
                    calories: 8,
                    protein: 0,
                    carbs: 2,
                    fiber: 1,
                    fat: 0,
                    healthScore: 7,
                    healthComments:
                        'Hydrating and low-calorie, provides minor vitamins and minerals.',
                  ),
                ],
                overallHealthScore: 8,
                overallHealthComments:
                    'This is a well-balanced, nutritious meal that\'s high in protein and low in calories. Great choice for weight management and muscle maintenance.',
                primaryConcerns: [
                  PrimaryConcern(
                    issue: 'Low in healthy fats',
                    explanation:
                        'While this salad is nutritious, it may benefit from additional healthy fats for better nutrient absorption.',
                    recommendations: [
                      Recommendation(
                        food: 'Avocado',
                        quantity: '1/4 medium',
                        reasoning:
                            'Adds healthy monounsaturated fats and improves vitamin absorption',
                      ),
                      Recommendation(
                        food: 'Olive oil dressing',
                        quantity: '1 tablespoon',
                        reasoning:
                            'Provides essential fatty acids and enhances flavor',
                      ),
                    ],
                  ),
                ],
                suggestAlternatives: [
                  Ingredient(
                    name: 'Salmon Salad Bowl',
                    calories: 220,
                    protein: 25,
                    carbs: 8,
                    fiber: 3,
                    fat: 12,
                    healthScore: 9,
                    healthComments:
                        'Rich in omega-3 fatty acids, supports brain and heart health.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ];

    messages.addAll(demoMessages);
    _scrollToBottom();
  }

  Future<void> sendMessage(UserModel user) async {
    print('Sending message: ${messageController.text}');
    final message = messageController.text.trim();
    if (message.isEmpty || isTyping.value) return;

    print('User ID: ${userIdController.text.trim()}');

    final userId = userIdController.text.trim().isNotEmpty
        ? userIdController.text.trim()
        : 'Guest';

    final userMessage = AgentResponse(
      role: 'user',
      timestamp: DateTime.now(),
      content: message,
      isFinal: true,
    );

    print('Adding user message: ${userMessage.content}');
    messages.add(userMessage);
    messageController.clear();

    isTyping.value = true;
    currentStreamingMessage = null;

    _scrollToBottom();

    try {
      _messageSubscription?.cancel();
      print('Starting message subscription for user ID: $userId');
      _messageSubscription =
          _agentService.sendMessage(message, userId, user).listen(
        (response) {
          _handleStreamedResponse(response);
          print('Received response: ${response.content}');
        },
        onError: (error) {
          _handleError(error);
        },
        onDone: () {
          isTyping.value = false;
          currentStreamingMessage = null;
        },
      );
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleStreamedResponse(AgentResponse response) {
    if (response.role == 'user') return;

    if (response.isFinal == true) {
      if (currentStreamingMessage != null) {
        final index = messages.indexOf(currentStreamingMessage!);
        if (index != -1) {
          messages[index] = response;
        }
      } else {
        messages.add(response);
      }
      currentStreamingMessage = null;
      isTyping.value = false;
    } else {
      if (currentStreamingMessage == null) {
        currentStreamingMessage = response;
        messages.add(response);
      } else {
        final index = messages.indexOf(currentStreamingMessage!);
        if (index != -1) {
          currentStreamingMessage = response;
          messages[index] = response;
        }
      }
    }

    _scrollToBottom();
  }

  void _handleError(dynamic error) {
    isTyping.value = false;
    currentStreamingMessage = null;

    print('Error sending message: $error');

    if (error.toString().contains('Connection refused') ||
        error.toString().contains('SocketException') ||
        error.toString().contains('ClientException')) {
      isDemoMode.value = true;
      final lastUserMessage =
          messages.isNotEmpty ? messages.last.content?.toLowerCase() ?? '' : '';
      final demoResponse = _generateDemoResponse(lastUserMessage);
      messages.add(demoResponse);
    } else {
      final errorResponse = AgentResponse(
        role: 'model',
        timestamp: DateTime.now(),
        content:
            'Sorry, I encountered an error while processing your request. Please try again.',
        isFinal: true,
      );
      messages.add(errorResponse);
    }

    _scrollToBottom();
  }

  AgentResponse _generateDemoResponse(String userMessage) {
    if (userMessage.contains('pizza') || userMessage.contains('🍕')) {
      return _generatePizzaNutritionResponse();
    } else if (userMessage.contains('burger') || userMessage.contains('🍔')) {
      return _generateBurgerNutritionResponse();
    } else if (userMessage.contains('salad') || userMessage.contains('🥗')) {
      return _generateSaladNutritionResponse();
    } else if (userMessage.contains('apple') || userMessage.contains('🍎')) {
      return _generateAppleNutritionResponse();
    } else if (userMessage.contains('banana') || userMessage.contains('🍌')) {
      return _generateBananaNutritionResponse();
    } else {
      return _generateGenericNutritionResponse(userMessage);
    }
  }

  AgentResponse _generatePizzaNutritionResponse() {
    return AgentResponse(
      role: 'model',
      timestamp: DateTime.now(),
      content:
          'I\'ll analyze the nutritional content of your pizza. Here\'s what I found:',
      isFinal: true,
      toolReturns: [
        ToolReturn(
          toolCallId: 'demo_pizza',
          toolName: 'calculate_nutrition_by_food_description',
          content: Content(
            response: Response(
              message: 'Pizza nutrition analysis complete',
              foodName: 'Margherita Pizza (2 slices)',
              portion: 'slices',
              portionSize: 2,
              confidenceScore: 9,
              ingredients: [
                Ingredient(
                  name: 'Pizza Dough',
                  calories: 285,
                  protein: 12,
                  carbs: 36,
                  fiber: 2,
                  fat: 10,
                  healthScore: 5,
                  healthComments:
                      'Refined carbohydrates provide quick energy but limited nutrients.',
                ),
                Ingredient(
                  name: 'Tomato Sauce',
                  calories: 15,
                  protein: 1,
                  carbs: 4,
                  fiber: 1,
                  fat: 0,
                  healthScore: 8,
                  healthComments:
                      'Rich in lycopene and vitamin C, supports heart health.',
                ),
                Ingredient(
                  name: 'Mozzarella Cheese',
                  calories: 85,
                  protein: 6,
                  carbs: 1,
                  fiber: 0,
                  fat: 6,
                  healthScore: 6,
                  healthComments:
                      'Good source of calcium and protein, but high in saturated fat.',
                ),
              ],
              overallHealthScore: 5,
              overallHealthComments:
                  'Pizza can be enjoyed in moderation. Consider adding vegetables and choosing thin crust options for better nutrition.',
              primaryConcerns: [
                PrimaryConcern(
                  issue: 'High in refined carbohydrates and saturated fat',
                  explanation:
                      'Pizza is calorie-dense and may contribute to weight gain if consumed frequently.',
                  recommendations: [
                    Recommendation(
                      food: 'Veggie Pizza',
                      quantity: '2 slices',
                      reasoning:
                          'Adding vegetables increases fiber and nutrients while reducing calorie density',
                    ),
                    Recommendation(
                      food: 'Cauliflower crust pizza',
                      quantity: '2 slices',
                      reasoning:
                          'Lower in carbs and calories than traditional pizza crust',
                    ),
                  ],
                ),
              ],
              suggestAlternatives: [
                Ingredient(
                  name: 'Homemade Veggie Pizza on Whole Wheat',
                  calories: 250,
                  protein: 12,
                  carbs: 30,
                  fiber: 4,
                  fat: 8,
                  healthScore: 7,
                  healthComments:
                      'Better fiber content and more vegetables provide additional nutrients.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  AgentResponse _generateSaladNutritionResponse() {
    return AgentResponse(
      role: 'model',
      timestamp: DateTime.now(),
      content:
          'Great choice! Let me analyze your salad\'s nutritional profile.',
      isFinal: true,
      toolReturns: [
        ToolReturn(
          toolCallId: 'demo_salad',
          toolName: 'calculate_nutrition_by_food_description',
          content: Content(
            response: Response(
              message: 'Salad nutrition analysis complete',
              foodName: 'Mixed Green Salad with Chicken',
              portion: 'bowl',
              portionSize: 1,
              confidenceScore: 8,
              ingredients: [
                Ingredient(
                  name: 'Mixed Greens',
                  calories: 20,
                  protein: 2,
                  carbs: 4,
                  fiber: 2,
                  fat: 0,
                  healthScore: 9,
                  healthComments:
                      'Excellent source of vitamins A, K, and folate. Very low in calories.',
                ),
                Ingredient(
                  name: 'Grilled Chicken',
                  calories: 140,
                  protein: 26,
                  carbs: 0,
                  fiber: 0,
                  fat: 3,
                  healthScore: 9,
                  healthComments:
                      'High-quality lean protein, supports muscle maintenance and growth.',
                ),
                Ingredient(
                  name: 'Cherry Tomatoes',
                  calories: 15,
                  protein: 1,
                  carbs: 3,
                  fiber: 1,
                  fat: 0,
                  healthScore: 9,
                  healthComments:
                      'Rich in lycopene, vitamin C, and antioxidants.',
                ),
              ],
              overallHealthScore: 9,
              overallHealthComments:
                  'Excellent nutritional choice! This salad is high in protein, low in calories, and packed with vitamins.',
              primaryConcerns: [],
              suggestAlternatives: [],
            ),
          ),
        ),
      ],
    );
  }

  AgentResponse _generateBurgerNutritionResponse() {
    return AgentResponse(
      role: 'model',
      timestamp: DateTime.now(),
      content: 'I\'ll break down the nutrition in your burger for you.',
      isFinal: true,
      toolReturns: [
        ToolReturn(
          toolCallId: 'demo_burger',
          toolName: 'calculate_nutrition_by_food_description',
          content: Content(
            response: Response(
              message: 'Burger nutrition analysis complete',
              foodName: 'Classic Cheeseburger',
              portion: 'burger',
              portionSize: 1,
              confidenceScore: 8,
              ingredients: [
                Ingredient(
                  name: 'Beef Patty',
                  calories: 250,
                  protein: 20,
                  carbs: 0,
                  fiber: 0,
                  fat: 18,
                  healthScore: 6,
                  healthComments:
                      'Good source of protein and iron, but high in saturated fat.',
                ),
                Ingredient(
                  name: 'Burger Bun',
                  calories: 150,
                  protein: 5,
                  carbs: 30,
                  fiber: 2,
                  fat: 2,
                  healthScore: 4,
                  healthComments:
                      'Refined grains provide energy but limited nutrients.',
                ),
                Ingredient(
                  name: 'Cheese',
                  calories: 110,
                  protein: 7,
                  carbs: 1,
                  fiber: 0,
                  fat: 9,
                  healthScore: 5,
                  healthComments:
                      'Source of calcium and protein, but high in saturated fat.',
                ),
              ],
              overallHealthScore: 4,
              overallHealthComments:
                  'High in calories and saturated fat. Consider healthier alternatives or enjoy occasionally as part of a balanced diet.',
              primaryConcerns: [
                PrimaryConcern(
                  issue: 'High in calories and saturated fat',
                  explanation:
                      'Regular consumption may contribute to weight gain and cardiovascular issues.',
                  recommendations: [
                    Recommendation(
                      food: 'Turkey burger',
                      quantity: '1 burger',
                      reasoning:
                          'Leaner protein option with less saturated fat',
                    ),
                    Recommendation(
                      food: 'Lettuce wrap instead of bun',
                      quantity: '1 wrap',
                      reasoning: 'Significantly reduces carbs and calories',
                    ),
                  ],
                ),
              ],
              suggestAlternatives: [
                Ingredient(
                  name: 'Grilled Chicken Sandwich',
                  calories: 350,
                  protein: 25,
                  carbs: 25,
                  fiber: 3,
                  fat: 12,
                  healthScore: 7,
                  healthComments:
                      'Leaner protein option with better nutritional balance.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  AgentResponse _generateAppleNutritionResponse() {
    return AgentResponse(
      role: 'model',
      timestamp: DateTime.now(),
      content:
          'Excellent choice! Here\'s the nutritional breakdown of your apple.',
      isFinal: true,
      toolReturns: [
        ToolReturn(
          toolCallId: 'demo_apple',
          toolName: 'calculate_nutrition_by_food_description',
          content: Content(
            response: Response(
              message: 'Apple nutrition analysis complete',
              foodName: 'Medium Apple',
              portion: 'apple',
              portionSize: 1,
              confidenceScore: 10,
              ingredients: [
                Ingredient(
                  name: 'Apple',
                  calories: 95,
                  protein: 0,
                  carbs: 25,
                  fiber: 4,
                  fat: 0,
                  healthScore: 9,
                  healthComments:
                      'High in fiber, vitamin C, and antioxidants. Great for digestive health.',
                ),
              ],
              overallHealthScore: 9,
              overallHealthComments:
                  'Apples are an excellent healthy snack! High in fiber and antioxidants with natural sugars for energy.',
              primaryConcerns: [],
              suggestAlternatives: [],
            ),
          ),
        ),
      ],
    );
  }

  AgentResponse _generateBananaNutritionResponse() {
    return AgentResponse(
      role: 'model',
      timestamp: DateTime.now(),
      content:
          'Bananas are a fantastic choice! Let me show you their nutritional benefits.',
      isFinal: true,
      toolReturns: [
        ToolReturn(
          toolCallId: 'demo_banana',
          toolName: 'calculate_nutrition_by_food_description',
          content: Content(
            response: Response(
              message: 'Banana nutrition analysis complete',
              foodName: 'Medium Banana',
              portion: 'banana',
              portionSize: 1,
              confidenceScore: 10,
              ingredients: [
                Ingredient(
                  name: 'Banana',
                  calories: 105,
                  protein: 1,
                  carbs: 27,
                  fiber: 3,
                  fat: 0,
                  healthScore: 8,
                  healthComments:
                      'Rich in potassium, vitamin B6, and natural sugars. Great for energy and muscle function.',
                ),
              ],
              overallHealthScore: 8,
              overallHealthComments:
                  'Bananas provide quick energy and essential nutrients. Perfect for pre or post-workout snacks!',
              primaryConcerns: [],
              suggestAlternatives: [],
            ),
          ),
        ),
      ],
    );
  }

  AgentResponse _generateGenericNutritionResponse(String foodItem) {
    return AgentResponse(
      role: 'model',
      timestamp: DateTime.now(),
      content:
          'I\'d love to help you analyze that food item! Since I\'m currently in demo mode (API not connected), here\'s some general nutrition guidance.',
      isFinal: true,
      toolReturns: [
        ToolReturn(
          toolCallId: 'demo_generic',
          toolName: 'calculate_nutrition_by_food_description',
          content: Content(
            response: Response(
              message: 'General nutrition guidance',
              foodName: 'Food Item Analysis',
              portion: 'serving',
              portionSize: 1,
              confidenceScore: 7,
              ingredients: [
                Ingredient(
                  name: 'Food Item',
                  calories: 200,
                  protein: 10,
                  carbs: 20,
                  fiber: 5,
                  fat: 8,
                  healthScore: 7,
                  healthComments:
                      'Focus on whole foods, balanced macronutrients, and proper portion sizes.',
                ),
              ],
              overallHealthScore: 7,
              overallHealthComments:
                  'For accurate nutrition analysis, try connecting to the API or be more specific about the food item (e.g., "pizza", "salad", "apple").',
              primaryConcerns: [
                PrimaryConcern(
                  issue: 'Demo Mode Active',
                  explanation:
                      'Connect to the nutrition API for detailed, accurate analysis of your specific food items.',
                  recommendations: [
                    Recommendation(
                      food: 'Fresh fruits and vegetables',
                      quantity: '5+ servings daily',
                      reasoning:
                          'Provides essential vitamins, minerals, and fiber',
                    ),
                    Recommendation(
                      food: 'Lean proteins',
                      quantity: '20-30g per meal',
                      reasoning: 'Supports muscle maintenance and satiety',
                    ),
                  ],
                ),
              ],
              suggestAlternatives: [],
            ),
          ),
        ),
      ],
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearMessages() {
    messages.clear();
    errorMessage.value = '';
  }
}
