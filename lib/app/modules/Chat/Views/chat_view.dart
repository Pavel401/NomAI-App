import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:NomAi/app/models/Agent/agent_response.dart';
import 'package:NomAi/app/modules/Chat/controller/chat_controller.dart';
import 'package:intl/intl.dart';

class NomAiAgentView extends StatefulWidget {
  const NomAiAgentView({super.key});

  @override
  State<NomAiAgentView> createState() => _NomAiAgentViewState();
}

class _NomAiAgentViewState extends State<NomAiAgentView>
    with TickerProviderStateMixin {
  ChatController controller = Get.put(ChatController());
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _fadeController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutCubic,
                )),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 20),
                        blurRadius: 40,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildMessagesList()),
                      _buildInputArea(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF10b981), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: PatternPainter(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NomAI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Your AI Nutrition Assistant',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Obx(() => controller.isDemoMode.value
                              ? Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'DEMO',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GetBuilder<ChatController>(
                        builder: (controller) => Text(
                          controller.userIdController.text.isEmpty
                              ? 'Guest'
                              : controller.userIdController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF10b981),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: _buildErrorWidget(controller.errorMessage.value),
          );
        }

        if (controller.messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(24),
          itemCount:
              controller.messages.length + (controller.isTyping.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.messages.length) {
              return _buildTypingIndicator();
            }
            return _buildMessageItem(controller.messages[index], index);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF10b981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Color(0xFF10b981),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => controller.isDemoMode.value
              ? Column(
                  children: [
                    const Text(
                      '🔧 Demo Mode - Try asking about:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildDemoChip('🍕 Pizza'),
                        _buildDemoChip('🥗 Salad'),
                        _buildDemoChip('🍔 Burger'),
                        _buildDemoChip('🍎 Apple'),
                        _buildDemoChip('🍌 Banana'),
                      ],
                    ),
                  ],
                )
              : const Text(
                  'Ask about nutrition, meal analysis, or health advice',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                )),
        ],
      ),
    );
  }

  Widget _buildDemoChip(String text) {
    return GestureDetector(
      onTap: () {
        controller.messageController.text =
            text.replaceAll(RegExp(r'[🍕🥗🍔🍎🍌] '), '');
        controller.sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF6366F1),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              onPressed: controller.loadChatHistory,
              icon: const Icon(
                Icons.refresh,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(AgentResponse message, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 50)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: message.role == 'user'
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.role == 'model')
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12, bottom: 4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10b981), Color(0xFF047857)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                  crossAxisAlignment: message.role == 'user'
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: message.role == 'user'
                            ? const Color(0xFF6366F1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: message.role == 'user'
                              ? const Radius.circular(4)
                              : null,
                          bottomLeft: message.role == 'model'
                              ? const Radius.circular(4)
                              : null,
                        ),
                        border: message.role == 'model'
                            ? Border.all(
                                color: const Color(0xFFE5E7EB),
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: message.role == 'model' &&
                              message.toolReturns != null &&
                              message.toolReturns!.isNotEmpty
                          ? _buildNutritionResponse(message)
                          : _buildTextContent(message),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.role == 'model')
                          const Icon(
                            Icons.smart_toy,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                        if (message.role == 'model') const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (message.role == 'user') const SizedBox(width: 4),
                        if (message.role == 'user')
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10b981),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (message.role == 'user') const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent(AgentResponse message) {
    return Text(
      message.content ?? '',
      style: TextStyle(
        color: message.role == 'user' ? Colors.white : const Color(0xFF111827),
        fontSize: 15,
        fontWeight: message.role == 'user' ? FontWeight.w500 : FontWeight.w400,
        height: 1.6,
      ),
    );
  }

  Widget _buildNutritionResponse(AgentResponse message) {
    // Extract nutrition data from tool returns
    final nutritionData = _extractNutritionData(message.toolReturns!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.content?.isNotEmpty == true) ...[
          Text(
            message.content!,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (nutritionData != null) _buildNutritionCard(nutritionData),
      ],
    );
  }

  Widget _buildNutritionCard(Map<String, dynamic> nutritionData) {
    final response = nutritionData['response'] as Map<String, dynamic>?;
    if (response == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF10b981), width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10b981), Color(0xFF047857)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNutritionHeader(response),
                if (response['ingredients'] != null) ...[
                  const SizedBox(height: 20),
                  _buildNutritionOverview(response['ingredients'] as List),
                  const SizedBox(height: 20),
                  _buildIngredientsBreakdown(response['ingredients'] as List),
                ],
                const SizedBox(height: 20),
                _buildHealthAssessment(response),
                if (response['primaryConcerns'] != null) ...[
                  const SizedBox(height: 20),
                  _buildHealthConcerns(response['primaryConcerns'] as List),
                ],
                if (response['suggestAlternatives'] != null) ...[
                  const SizedBox(height: 20),
                  _buildAlternatives(response['suggestAlternatives'] as List),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionHeader(Map<String, dynamic> response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.analytics,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                response['foodName']?.toString() ?? 'Food Analysis',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoChip(
                'Portion', '${response['portionSize']} ${response['portion']}'),
            const SizedBox(width: 12),
            _buildInfoChip('Confidence', '${response['confidenceScore']}/10'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildNutritionOverview(List ingredients) {
    final total = _calculateTotalNutrition(ingredients);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pie_chart,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Nutritional Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildNutritionValueCard('${total['calories']}', 'Calories',
                Icons.local_fire_department),
            _buildNutritionValueCard(
                '${total['protein']}g', 'Protein', Icons.fitness_center),
            _buildNutritionValueCard(
                '${total['carbs']}g', 'Carbs', Icons.grain),
            _buildNutritionValueCard('${total['fat']}g', 'Fat', Icons.opacity),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionValueCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsBreakdown(List ingredients) {
    if (ingredients.length <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Ingredient Analysis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...ingredients
            .map<Widget>((ingredient) => _buildIngredientItem(ingredient)),
      ],
    );
  }

  Widget _buildIngredientItem(dynamic ingredient) {
    final healthScore = ingredient['healthScore'] as int? ?? 0;
    final color = _getHealthScoreColor(healthScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ingredient['name']?.toString() ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getHealthScoreIcon(healthScore),
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$healthScore/10',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cal: ${ingredient['calories']} | Protein: ${ingredient['protein']}g | Carbs: ${ingredient['carbs']}g | Fat: ${ingredient['fat']}g',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
          if (ingredient['healthComments']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              ingredient['healthComments'].toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthAssessment(Map<String, dynamic> response) {
    final overallScore = response['overallHealthScore'] as int? ?? 0;
    final color = _getHealthScoreColor(overallScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.health_and_safety,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Health Assessment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getHealthScoreIcon(overallScore),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Overall Score: $overallScore/10',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (response['overallHealthComments']?.toString().isNotEmpty ==
                  true) ...[
                const SizedBox(height: 12),
                Text(
                  response['overallHealthComments'].toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthConcerns(List concerns) {
    if (concerns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Health Concerns',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...concerns.map<Widget>((concern) => _buildConcernItem(concern)),
      ],
    );
  }

  Widget _buildConcernItem(dynamic concern) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            concern['issue']?.toString() ?? 'Health Concern',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E),
            ),
          ),
          if (concern['explanation']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              concern['explanation'].toString(),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF78350F),
                height: 1.4,
              ),
            ),
          ],
          if (concern['recommendations'] is List &&
              (concern['recommendations'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Color(0xFF92400E),
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Recommendations:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...(concern['recommendations'] as List)
                .map<Widget>((rec) => Padding(
                      padding: const EdgeInsets.only(left: 22, top: 4),
                      child: Text(
                        '• ${rec['food']} (${rec['quantity']}): ${rec['reasoning']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF78350F),
                          height: 1.3,
                        ),
                      ),
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildAlternatives(List alternatives) {
    if (alternatives.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.swap_horiz,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Healthier Alternatives',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...alternatives.map<Widget>((alt) => _buildAlternativeItem(alt)),
      ],
    );
  }

  Widget _buildAlternativeItem(dynamic alternative) {
    final healthScore = alternative['healthScore'] as int? ?? 0;
    final color = _getHealthScoreColor(healthScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  alternative['name']?.toString() ?? 'Alternative',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$healthScore/10',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cal: ${alternative['calories']} | Protein: ${alternative['protein']}g | Carbs: ${alternative['carbs']}g | Fat: ${alternative['fat']}g',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
          if (alternative['healthComments']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              alternative['healthComments'].toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10b981), Color(0xFF047857)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'NomAI is analyzing your nutrition data',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24,
                  height: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        List.generate(3, (index) => _buildTypingDot(index)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.4 * (value + (index * 0.2)) % 1.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // User ID input row
          Row(
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: controller.userIdController,
                  decoration: InputDecoration(
                    hintText: 'User ID',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide:
                          const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          // Message input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Describe your meal or ask about nutrition...',
                      contentPadding: const EdgeInsets.fromLTRB(48, 16, 20, 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: Color(0xFF6366F1), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.chat,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Obx(() => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: controller.isTyping.value
                          ? LinearGradient(
                              colors: [
                                Colors.grey.shade400,
                                Colors.grey.shade500,
                              ],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (controller.isTyping.value
                                  ? Colors.grey.shade400
                                  : const Color(0xFF6366F1))
                              .withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: controller.isTyping.value
                            ? null
                            : controller.sendMessage,
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _extractNutritionData(List<ToolReturn> toolReturns) {
    for (final toolReturn in toolReturns) {
      if (toolReturn.toolName == 'calculate_nutrition_by_food_description' &&
          toolReturn.content != null) {
        // Convert Content object to Map
        final content = toolReturn.content!;
        final response = content.response;
        if (response != null) {
          return {
            'response': {
              'foodName': response.foodName,
              'portion': response.portion,
              'portionSize': response.portionSize,
              'confidenceScore': response.confidenceScore,
              'ingredients': response.ingredients
                  ?.map((ing) => {
                        'name': ing.name,
                        'calories': ing.calories,
                        'protein': ing.protein,
                        'carbs': ing.carbs,
                        'fiber': ing.fiber,
                        'fat': ing.fat,
                        'healthScore': ing.healthScore,
                        'healthComments': ing.healthComments,
                      })
                  .toList(),
              'primaryConcerns': response.primaryConcerns
                  ?.map((concern) => {
                        'issue': concern.issue,
                        'explanation': concern.explanation,
                        'recommendations': concern.recommendations
                            ?.map((rec) => {
                                  'food': rec.food,
                                  'quantity': rec.quantity,
                                  'reasoning': rec.reasoning,
                                })
                            .toList(),
                      })
                  .toList(),
              'suggestAlternatives': response.suggestAlternatives
                  ?.map((alt) => {
                        'name': alt.name,
                        'calories': alt.calories,
                        'protein': alt.protein,
                        'carbs': alt.carbs,
                        'fiber': alt.fiber,
                        'fat': alt.fat,
                        'healthScore': alt.healthScore,
                        'healthComments': alt.healthComments,
                      })
                  .toList(),
              'overallHealthScore': response.overallHealthScore,
              'overallHealthComments': response.overallHealthComments,
            }
          };
        }
      }
    }
    return null;
  }

  Map<String, int> _calculateTotalNutrition(List ingredients) {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (final ingredient in ingredients) {
      totalCalories += (ingredient['calories'] as int? ?? 0);
      totalProtein += (ingredient['protein'] as int? ?? 0);
      totalCarbs += (ingredient['carbs'] as int? ?? 0);
      totalFat += (ingredient['fat'] as int? ?? 0);
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 7) return const Color(0xFF10B981);
    if (score >= 5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData _getHealthScoreIcon(int score) {
    if (score >= 7) return Icons.check_circle;
    if (score >= 5) return Icons.warning;
    return Icons.error;
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('HH:mm').format(timestamp);
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const double spacing = 60.0;
    const double dotSize = 4.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x + 20, y + 20), dotSize, paint);
        canvas.drawCircle(Offset(x + 40, y + 40), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
