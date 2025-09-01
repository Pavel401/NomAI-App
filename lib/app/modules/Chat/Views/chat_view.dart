import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/models/Agent/agent_response.dart';
import 'package:NomAi/app/modules/Chat/controller/chat_controller.dart';

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

  UserModel? user;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          user = state.userModel;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: _buildResponsiveAppBarTitle(),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(child: _buildMessagesList()),
                _buildInputArea(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveAppBarTitle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final bool isNarrow = availableWidth < 350;

        return Row(
          children: [
            Container(
              width: isNarrow ? 32 : 8.w,
              height: isNarrow ? 32 : 8.w,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: isNarrow ? 18 : 5.w,
              ),
            ),
            SizedBox(width: isNarrow ? 8 : 3.w),
            Text(
              'NomAI',
              style: TextStyle(
                color: const Color(0xFF1F2937),
                fontSize: isNarrow ? 18 : 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isNarrow) ...[
              _buildCompactUserControls(),
            ] else ...[
              _buildFullUserControls(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCompactUserControls() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
      onSelected: (value) {
        if (value == 'user_id') {
          _showUserIdDialog(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'user_id',
          child: GetBuilder<ChatController>(
            builder: (controller) => Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(
                  controller.userIdController.text.isEmpty
                      ? 'Guest'
                      : controller.userIdController.text,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullUserControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _showUserIdDialog(context),
          child: GetBuilder<ChatController>(
            builder: (controller) => Container(
              constraints: BoxConstraints(maxWidth: 25.w),
              padding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: const Color(0xFF6B7280),
                  ),
                  SizedBox(width: 1.5.w),
                  Flexible(
                    child: Text(
                      controller.userIdController.text.isEmpty
                          ? 'Guest'
                          : controller.userIdController.text,
                      style: TextStyle(
                        color: const Color(0xFF374151),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Obx(() => controller.isDemoMode.value
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 0.8.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Demo',
                  style: TextStyle(
                    color: const Color(0xD92400E),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  void _showUserIdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User ID'),
        content: TextField(
          controller: controller.userIdController,
          decoration: const InputDecoration(
            hintText: 'Enter User ID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.update();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      color: Colors.white, // Clean white background like ChatGPT
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF10B981),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
              child: Text(
            controller.errorMessage.value,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ));
        }

        if (controller.messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: controller.scrollController,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 8.h),
            Icon(
              Icons.restaurant_menu,
              size: 16.w.clamp(60.0, 80.0),
              color: const Color(0xFF9CA3AF),
            ),
            SizedBox(height: 4.h),
            Text(
              'How can I help with your nutrition today?',
              style: TextStyle(
                fontSize: 20.sp.clamp(18.0, 24.0),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            _buildRegularModeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularModeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        'Ask about nutrition, meal analysis, or health advice',
        style: TextStyle(
          fontSize: 16.sp.clamp(14.0, 18.0),
          color: const Color(0xFF6B7280),
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessageItem(AgentResponse message, int index) {
    final isUser = message.role == 'user';

    if (message.content?.trim().isEmpty == true &&
        (message.toolReturns == null || message.toolReturns!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final avatarSize = maxWidth < 350 ? 28.0 : 7.w.clamp(28.0, 40.0);
          final spacing = maxWidth < 350 ? 8.0 : 3.w.clamp(8.0, 16.0);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: avatarSize * 0.6,
                  ),
                ),
                SizedBox(width: spacing),
              ],
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isUser ? maxWidth * 0.8 : maxWidth * 0.85,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: maxWidth < 350 ? 12 : 4.w.clamp(12.0, 20.0),
                    vertical: maxWidth < 350 ? 10 : 3.w.clamp(10.0, 16.0),
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomLeft: !isUser ? const Radius.circular(4) : null,
                      bottomRight: isUser ? const Radius.circular(4) : null,
                    ),
                    border: !isUser
                        ? Border.all(color: const Color(0xFFE5E7EB), width: 1)
                        : null,
                  ),
                  child: message.role == 'model' &&
                          message.toolReturns != null &&
                          message.toolReturns!.isNotEmpty
                      ? _buildNutritionResponse(message)
                      : _buildMarkdownContent(
                          message.content?.trim() ?? '',
                          isUser,
                          maxWidth,
                        ),
                ),
              ),
              if (isUser) ...[
                SizedBox(width: spacing),
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B7280),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: avatarSize * 0.6,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildNutritionResponse(AgentResponse message) {
    final nutritionData = _extractNutritionData(message.toolReturns!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.content?.trim().isNotEmpty == true) ...[
          MarkdownBody(
            data: message.content!,
            styleSheet: _getMarkdownStyleSheet(false, 400),
            shrinkWrap: true,
            selectable: true,
          ),
          SizedBox(height: 4.w),
        ],
        if (nutritionData != null) _buildNutritionCard(nutritionData),
      ],
    );
  }

  Widget _buildMarkdownContent(String content, bool isUser, double maxWidth) {
    if (content.isEmpty) return const SizedBox.shrink();

    return MarkdownBody(
      data: content,
      styleSheet: _getMarkdownStyleSheet(isUser, maxWidth),
      shrinkWrap: true,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          debugPrint('Link tapped: $href');
        }
      },
    );
  }

  MarkdownStyleSheet _getMarkdownStyleSheet(bool isUser, double maxWidth) {
    return MarkdownStyleSheet(
      p: TextStyle(
        color: isUser ? Colors.white : const Color(0xFF111827),
        fontSize: maxWidth < 350 ? 14 : 15.sp.clamp(14.0, 16.0),
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      h1: TextStyle(
        color: isUser ? Colors.white : const Color(0xFF111827),
        fontSize: maxWidth < 350 ? 20 : 22.sp.clamp(20.0, 24.0),
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: TextStyle(
        color: isUser ? Colors.white : const Color(0xFF111827),
        fontSize: maxWidth < 350 ? 18 : 20.sp.clamp(18.0, 22.0),
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h3: TextStyle(
        color: isUser ? Colors.white : const Color(0xFF111827),
        fontSize: maxWidth < 350 ? 16 : 18.sp.clamp(16.0, 20.0),
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      strong: TextStyle(
        color: isUser ? Colors.white : const Color(0xFF111827),
        fontWeight: FontWeight.w700,
      ),
      em: TextStyle(
        color: isUser ? Colors.white.withOpacity(0.9) : const Color(0xFF374151),
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        backgroundColor:
            isUser ? Colors.white.withOpacity(0.2) : const Color(0xFFF3F4F6),
        color: isUser ? Colors.white : const Color(0xFFDC2626),
        fontSize: maxWidth < 350 ? 13 : 14.sp.clamp(13.0, 15.0),
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: isUser ? Colors.white.withOpacity(0.1) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isUser ? Colors.white.withOpacity(0.3) : const Color(0xFFE5E7EB),
        ),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquote: TextStyle(
        color: isUser ? Colors.white.withOpacity(0.9) : const Color(0xFF6B7280),
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isUser
                ? Colors.white.withOpacity(0.5)
                : const Color(0xFFD1D5DB),
            width: 4,
          ),
        ),
      ),
      listBullet: TextStyle(
        color: isUser ? Colors.white : const Color(0xFF111827),
      ),
      tableHead: TextStyle(
        fontWeight: FontWeight.w600,
        color: isUser ? Colors.white : const Color(0xFF111827),
      ),
      tableBody: TextStyle(
        color: isUser ? Colors.white : const Color(0xFF111827),
      ),
      tableBorder: TableBorder.all(
        color: isUser ? Colors.white.withOpacity(0.3) : const Color(0xFFE5E7EB),
      ),
    );
  }

  Widget _buildNutritionCard(Map<String, dynamic> nutritionData) {
    final response = nutritionData['response'] as Map<String, dynamic>?;
    if (response == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF10b981), width: 1),
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
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNutritionHeader(response),
                if (response['ingredients'] != null) ...[
                  SizedBox(height: 4.w.clamp(12.0, 20.0)),
                  _buildNutritionOverview(response['ingredients'] as List),
                  SizedBox(height: 4.w.clamp(12.0, 20.0)),
                  _buildIngredientsBreakdown(response['ingredients'] as List),
                ],
                SizedBox(height: 4.w.clamp(12.0, 20.0)),
                _buildHealthAssessment(response),
                if (response['primaryConcerns'] != null) ...[
                  SizedBox(height: 4.w.clamp(12.0, 20.0)),
                  _buildHealthConcerns(response['primaryConcerns'] as List),
                ],
                if (response['suggestAlternatives'] != null) ...[
                  SizedBox(height: 4.w.clamp(12.0, 20.0)),
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
              padding: EdgeInsets.all(2.w.clamp(6.0, 10.0)),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.analytics,
                color: const Color(0xFF6366F1),
                size: 5.w.clamp(18.0, 24.0),
              ),
            ),
            SizedBox(width: 3.w.clamp(8.0, 12.0)),
            Expanded(
              child: Text(
                response['foodName']?.toString() ?? 'Food Analysis',
                style: TextStyle(
                  fontSize: 18.sp.clamp(16.0, 20.0),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w.clamp(8.0, 12.0)),
        Wrap(
          spacing: 3.w.clamp(8.0, 12.0),
          runSpacing: 2.w.clamp(6.0, 8.0),
          children: [
            _buildInfoChip(
                'Portion', '${response['portionSize']} ${response['portion']}'),
            _buildInfoChip('Confidence', '${response['confidenceScore']}/10'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: EdgeInsets.symmetric(
        horizontal: 3.w.clamp(8.0, 12.0),
        vertical: 1.5.w.clamp(4.0, 8.0),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12.sp.clamp(11.0, 14.0),
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6B7280),
        ),
        overflow: TextOverflow.ellipsis,
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
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.pie_chart,
                color: const Color(0xFF6366F1),
                size: 5.w.clamp(18.0, 24.0),
              ),
            ),
            SizedBox(width: 3.w.clamp(8.0, 12.0)),
            Expanded(
              child: Text(
                'Nutritional Breakdown',
                style: TextStyle(
                  fontSize: 16.sp.clamp(14.0, 18.0),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.w.clamp(12.0, 16.0)),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width < 250 ? 1 : 2;
            final childAspectRatio = width < 250 ? 3.5 : 2.5;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 3.w.clamp(8.0, 12.0),
              mainAxisSpacing: 3.w.clamp(8.0, 12.0),
              children: [
                _buildNutritionValueCard('${total['calories']}', 'Calories',
                    Icons.local_fire_department),
                _buildNutritionValueCard(
                    '${total['protein']}g', 'Protein', Icons.fitness_center),
                _buildNutritionValueCard(
                    '${total['carbs']}g', 'Carbs', Icons.grain),
                _buildNutritionValueCard(
                    '${total['fat']}g', 'Fat', Icons.opacity),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNutritionValueCard(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 5.w.clamp(16.0, 24.0),
          ),
          SizedBox(width: 2.w.clamp(6.0, 8.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp.clamp(12.0, 16.0),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp.clamp(10.0, 13.0),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
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
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.search,
                color: const Color(0xFF6366F1),
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Ingredient Analysis',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.w),
        ...ingredients
            .map<Widget>((ingredient) => _buildIngredientItem(ingredient)),
      ],
    );
  }

  Widget _buildIngredientItem(dynamic ingredient) {
    final healthScore = ingredient['healthScore'] as int? ?? 0;
    final color = _getHealthScoreColor(healthScore);

    return Container(
      margin: EdgeInsets.only(bottom: 3.w.clamp(8.0, 12.0)),
      padding: EdgeInsets.all(4.w.clamp(12.0, 16.0)),
      width: double.infinity,
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
                  style: TextStyle(
                    fontSize: 14.sp.clamp(13.0, 16.0),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w.clamp(6.0, 8.0),
                  vertical: 1.w.clamp(3.0, 6.0),
                ),
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
                      style: TextStyle(
                        fontSize: 12.sp.clamp(11.0, 14.0),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.w.clamp(6.0, 8.0)),
          Text(
            'Cal: ${ingredient['calories']} | Protein: ${ingredient['protein']}g | Carbs: ${ingredient['carbs']}g | Fat: ${ingredient['fat']}g',
            style: TextStyle(
              fontSize: 12.sp.clamp(11.0, 14.0),
              color: const Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
          if (ingredient['healthComments']?.toString().isNotEmpty == true) ...[
            SizedBox(height: 2.w.clamp(6.0, 8.0)),
            Text(
              ingredient['healthComments'].toString(),
              style: TextStyle(
                fontSize: 12.sp.clamp(11.0, 14.0),
                color: const Color(0xFF374151),
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
              padding: EdgeInsets.all(2.w.clamp(6.0, 10.0)),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.health_and_safety,
                color: const Color(0xFF6366F1),
                size: 5.w.clamp(18.0, 24.0),
              ),
            ),
            SizedBox(width: 3.w.clamp(8.0, 12.0)),
            Expanded(
              child: Text(
                'Health Assessment',
                style: TextStyle(
                  fontSize: 16.sp.clamp(14.0, 18.0),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.w.clamp(12.0, 16.0)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w.clamp(12.0, 16.0)),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w.clamp(8.0, 12.0),
                      vertical: 1.5.w.clamp(4.0, 8.0),
                    ),
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
                          style: TextStyle(
                            fontSize: 14.sp.clamp(12.0, 16.0),
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
                SizedBox(height: 3.w.clamp(8.0, 12.0)),
                Text(
                  response['overallHealthComments'].toString(),
                  style: TextStyle(
                    fontSize: 14.sp.clamp(12.0, 16.0),
                    color: const Color(0xFF374151),
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
            Expanded(
              child: Text(
                'Health Concerns',
                style: TextStyle(
                  fontSize: 16.sp.clamp(14.0, 18.0),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
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
      width: double.infinity,
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
            style: TextStyle(
              fontSize: 14.sp.clamp(13.0, 16.0),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF92400E),
            ),
          ),
          if (concern['explanation']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              concern['explanation'].toString(),
              style: TextStyle(
                fontSize: 13.sp.clamp(12.0, 15.0),
                color: const Color(0xFF78350F),
                height: 1.4,
              ),
            ),
          ],
          if (concern['recommendations'] is List &&
              (concern['recommendations'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Color(0xFF92400E),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommendations:',
                        style: TextStyle(
                          fontSize: 13.sp.clamp(12.0, 15.0),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...(concern['recommendations'] as List)
                          .map<Widget>((rec) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '• ${rec['food']} (${rec['quantity']}): ${rec['reasoning']}',
                                  style: TextStyle(
                                    fontSize: 12.sp.clamp(11.0, 14.0),
                                    color: const Color(0xFF78350F),
                                    height: 1.3,
                                  ),
                                ),
                              )),
                    ],
                  ),
                ),
              ],
            ),
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
            Expanded(
              child: Text(
                'Healthier Alternatives',
                style: TextStyle(
                  fontSize: 16.sp.clamp(14.0, 18.0),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
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
      width: double.infinity,
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
                  style: TextStyle(
                    fontSize: 14.sp.clamp(13.0, 16.0),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
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
                  style: TextStyle(
                    fontSize: 12.sp.clamp(11.0, 14.0),
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
            style: TextStyle(
              fontSize: 12.sp.clamp(11.0, 14.0),
              color: const Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
          if (alternative['healthComments']?.toString().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              alternative['healthComments'].toString(),
              style: TextStyle(
                fontSize: 12.sp.clamp(11.0, 14.0),
                color: const Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final avatarSize = maxWidth < 350 ? 28.0 : 7.w.clamp(28.0, 40.0);
          final spacing = maxWidth < 350 ? 8.0 : 3.w.clamp(8.0, 16.0);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: avatarSize * 0.6,
                ),
              ),
              SizedBox(width: spacing),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: maxWidth < 350 ? 12 : 4.w.clamp(12.0, 20.0),
                    vertical: maxWidth < 350 ? 10 : 3.w.clamp(10.0, 16.0),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomLeft: const Radius.circular(4),
                    ),
                    border:
                        Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NomAI is thinking',
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize:
                              maxWidth < 350 ? 14 : 15.sp.clamp(14.0, 16.0),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: maxWidth < 350 ? 6 : 2.w),
                      SizedBox(
                        width: maxWidth < 350 ? 20 : 5.w,
                        height: maxWidth < 350 ? 16 : 4.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                              3, (index) => _buildTypingDot(index)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
      color: Colors.white,
      padding: EdgeInsets.all(4.w.clamp(12.0, 20.0)),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final buttonSize = maxWidth < 350 ? 44.0 : 11.w.clamp(44.0, 52.0);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight:
                          maxWidth < 350 ? 120 : 30.w.clamp(100.0, 150.0),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.sendMessage(user!),
                      decoration: InputDecoration(
                        hintText: 'Message NomAI...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize:
                              maxWidth < 350 ? 14 : 16.sp.clamp(14.0, 18.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal:
                              maxWidth < 350 ? 16 : 5.w.clamp(16.0, 24.0),
                          vertical:
                              maxWidth < 350 ? 12 : 3.5.w.clamp(12.0, 18.0),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: maxWidth < 350 ? 14 : 16.sp.clamp(14.0, 18.0),
                        height: 1.4,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: maxWidth < 350 ? 8 : 3.w.clamp(8.0, 12.0)),
                Obx(() => GestureDetector(
                      onTap: () {
                        if (!controller.isTyping.value) {
                          controller.sendMessage(user!);
                        }
                      },
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          color: controller.isTyping.value
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: controller.isTyping.value
                              ? const Color(0xFF9CA3AF)
                              : Colors.white,
                          size: buttonSize * 0.5,
                        ),
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, dynamic>? _extractNutritionData(List<ToolReturn> toolReturns) {
    for (final toolReturn in toolReturns) {
      if (toolReturn.toolName == 'calculate_nutrition_by_food_description' &&
          toolReturn.content != null) {
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
