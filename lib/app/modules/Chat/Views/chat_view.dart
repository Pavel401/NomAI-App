import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/models/Agent/agent_response.dart' as AgentResponse;
import 'package:NomAi/app/modules/Chat/controller/chat_controller.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/services/nutrition_service.dart';

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
          backgroundColor: MealAIColors.whiteText,
          appBar: AppBar(
            backgroundColor: MealAIColors.whiteText,
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
              decoration: BoxDecoration(
                color: MealAIColors.blackText,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: MealAIColors.whiteText,
                size: isNarrow ? 18 : 5.w,
              ),
            ),
            SizedBox(width: isNarrow ? 8 : 3.w),
            Text(
              'NomAI',
              style: TextStyle(
                color: MealAIColors.blackText,
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
      icon: Icon(Icons.more_vert, color: MealAIColors.grey),
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
                color: MealAIColors.greyLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MealAIColors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: MealAIColors.blackText,
                  ),
                  SizedBox(width: 1.5.w),
                  Flexible(
                    child: Text(
                      controller.userIdController.text.isEmpty
                          ? 'Guest'
                          : controller.userIdController.text,
                      style: TextStyle(
                        color: MealAIColors.blackText,
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
                  color: MealAIColors.greyLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: MealAIColors.grey,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Demo',
                  style: TextStyle(
                    color: MealAIColors.blackText,
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
      color: MealAIColors.whiteText,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: MealAIColors.blackText,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
              child: Text(
            controller.errorMessage.value,
            style: TextStyle(
              color: MealAIColors.red,
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
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
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
            Container(
              width: 16.w.clamp(60.0, 80.0),
              height: 16.w.clamp(60.0, 80.0),
              decoration: BoxDecoration(
                color: MealAIColors.blackText,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 10.w.clamp(30.0, 40.0),
                color: MealAIColors.whiteText,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'How can I help with your nutrition today?',
              style: TextStyle(
                fontSize: 20.sp.clamp(18.0, 24.0),
                fontWeight: FontWeight.w600,
                color: MealAIColors.blackText,
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
          color: MealAIColors.grey,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessageItem(AgentResponse.AgentResponse message, int index) {
    final isUser = message.role == 'user';

    if (message.content?.trim().isEmpty == true &&
        (message.toolReturns == null || message.toolReturns!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: MealAIColors.blackText,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: MealAIColors.whiteText,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser ? MealAIColors.blackText : MealAIColors.greyLight,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                  bottomRight: isUser ? const Radius.circular(4) : null,
                ),
                border: !isUser
                    ? Border.all(
                        color: MealAIColors.grey.withOpacity(0.2), width: 1)
                    : null,
              ),
              child: message.role == 'model' &&
                      message.toolReturns != null &&
                      message.toolReturns!.isNotEmpty
                  ? _buildNutritionResponse(message)
                  : _buildMarkdownContent(
                      message.content?.trim() ?? '',
                      isUser,
                      MediaQuery.of(context).size.width * 0.75,
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: MealAIColors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: MealAIColors.whiteText,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionResponse(AgentResponse.AgentResponse message) {
    final nutritionResponse =
        NutritionService.extractNutritionResponse(message.toolReturns!);

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
        if (nutritionResponse != null) _buildNutritionCard(nutritionResponse),
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
        color: isUser ? MealAIColors.whiteText : MealAIColors.blackText,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      h1: TextStyle(
        color: isUser ? MealAIColors.whiteText : MealAIColors.blackText,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: TextStyle(
        color: isUser ? MealAIColors.whiteText : MealAIColors.blackText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h3: TextStyle(
        color: isUser ? MealAIColors.whiteText : MealAIColors.blackText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      strong: TextStyle(
        color: isUser ? MealAIColors.whiteText : MealAIColors.blackText,
        fontWeight: FontWeight.w700,
      ),
      em: TextStyle(
        color: isUser
            ? MealAIColors.whiteText.withOpacity(0.9)
            : MealAIColors.grey,
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        backgroundColor: isUser
            ? MealAIColors.whiteText.withOpacity(0.2)
            : MealAIColors.greyLight,
        color: isUser ? MealAIColors.whiteText : MealAIColors.blackText,
        fontSize: 14,
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: isUser
            ? MealAIColors.whiteText.withOpacity(0.1)
            : MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUser
              ? MealAIColors.whiteText.withOpacity(0.3)
              : MealAIColors.grey.withOpacity(0.3),
        ),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquote: TextStyle(
        color: isUser
            ? MealAIColors.whiteText.withOpacity(0.9)
            : MealAIColors.grey,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isUser
                ? MealAIColors.whiteText.withOpacity(0.5)
                : MealAIColors.grey,
            width: 4,
          ),
        ),
      ),
      listBullet: TextStyle(
        color: isUser ? MealAIColors.whiteText : MealAIColors.blackText,
      ),
      tableHead: TextStyle(
        fontWeight: FontWeight.w600,
        color: isUser ? MealAIColors.whiteText : MealAIColors.blackText,
      ),
      tableBody: TextStyle(
        color: isUser ? MealAIColors.whiteText : MealAIColors.blackText,
      ),
      tableBorder: TableBorder.all(
        color: isUser
            ? MealAIColors.whiteText.withOpacity(0.3)
            : MealAIColors.grey.withOpacity(0.3),
      ),
    );
  }

  Widget _buildNutritionCard(AgentResponse.Response response) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MealAIColors.whiteText,
        border: Border.all(color: MealAIColors.blackText, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MealAIColors.blackText.withOpacity(0.05),
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
                if (response.ingredients != null &&
                    response.ingredients!.isNotEmpty) ...[
                  SizedBox(height: 4.w.clamp(12.0, 20.0)),
                  _buildNutritionOverview(response.ingredients!),
                  SizedBox(height: 4.w.clamp(12.0, 20.0)),
                  _buildIngredientsBreakdown(response.ingredients!),
                ],
                SizedBox(height: 4.w.clamp(12.0, 20.0)),
                _buildHealthAssessment(response),
                if (response.primaryConcerns != null &&
                    response.primaryConcerns!.isNotEmpty) ...[
                  SizedBox(height: 4.w.clamp(12.0, 20.0)),
                  _buildHealthConcerns(response.primaryConcerns!),
                ],
                if (response.suggestAlternatives != null &&
                    response.suggestAlternatives!.isNotEmpty) ...[
                  SizedBox(height: 4.w.clamp(12.0, 20.0)),
                  _buildAlternatives(response.suggestAlternatives!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionHeader(AgentResponse.Response response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w.clamp(6.0, 10.0)),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.analytics,
                color: MealAIColors.blackText,
                size: 5.w.clamp(18.0, 24.0),
              ),
            ),
            SizedBox(width: 3.w.clamp(8.0, 12.0)),
            Expanded(
              child: Text(
                response.foodName ?? 'Food Analysis',
                style: TextStyle(
                  fontSize: 18.sp.clamp(16.0, 20.0),
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.blackText,
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
                'Portion', '${response.portionSize} ${response.portion}'),
            _buildInfoChip('Confidence', '${response.confidenceScore}/10'),
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
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12.sp.clamp(11.0, 14.0),
          fontWeight: FontWeight.w500,
          color: MealAIColors.grey,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNutritionOverview(List<AgentResponse.Ingredient> ingredients) {
    final total = NutritionService.calculateTotalNutrition(ingredients);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.pie_chart,
                color: MealAIColors.blackText,
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
                  color: MealAIColors.blackText,
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
                _buildNutritionValueCard('${total.calories}', 'Calories',
                    Icons.local_fire_department),
                _buildNutritionValueCard(
                    '${total.protein}g', 'Protein', Icons.fitness_center),
                _buildNutritionValueCard(
                    '${total.carbs}g', 'Carbs', Icons.grain),
                _buildNutritionValueCard('${total.fat}g', 'Fat', Icons.opacity),
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
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MealAIColors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: MealAIColors.blackText,
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
                      color: MealAIColors.blackText,
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
                      color: MealAIColors.grey,
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

  Widget _buildIngredientsBreakdown(
      List<AgentResponse.Ingredient> ingredients) {
    if (ingredients.length <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.search,
                color: MealAIColors.blackText,
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
                  color: MealAIColors.blackText,
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

  Widget _buildIngredientItem(AgentResponse.Ingredient ingredient) {
    final healthScore = ingredient.healthScore ?? 0;
    final color = _getHealthScoreColor(healthScore);

    return Container(
      margin: EdgeInsets.only(bottom: 3.w.clamp(8.0, 12.0)),
      padding: EdgeInsets.all(4.w.clamp(12.0, 16.0)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
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
                  ingredient.name ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 14.sp.clamp(13.0, 16.0),
                    fontWeight: FontWeight.w600,
                    color: MealAIColors.blackText,
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
                        color: MealAIColors.whiteText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.w.clamp(6.0, 8.0)),
          Text(
            'Cal: ${ingredient.calories} | Protein: ${ingredient.protein}g | Carbs: ${ingredient.carbs}g | Fat: ${ingredient.fat}g',
            style: TextStyle(
              fontSize: 12.sp.clamp(11.0, 14.0),
              color: MealAIColors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (ingredient.healthComments?.isNotEmpty == true) ...[
            SizedBox(height: 2.w.clamp(6.0, 8.0)),
            Text(
              ingredient.healthComments!,
              style: TextStyle(
                fontSize: 12.sp.clamp(11.0, 14.0),
                color: MealAIColors.blackText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthAssessment(AgentResponse.Response response) {
    final overallScore = response.overallHealthScore ?? 0;
    final color = _getHealthScoreColor(overallScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w.clamp(6.0, 10.0)),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.health_and_safety,
                color: MealAIColors.blackText,
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
                  color: MealAIColors.blackText,
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
                            color: MealAIColors.whiteText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (response.overallHealthComments?.isNotEmpty == true) ...[
                SizedBox(height: 3.w.clamp(8.0, 12.0)),
                Text(
                  response.overallHealthComments!,
                  style: TextStyle(
                    fontSize: 14.sp.clamp(12.0, 16.0),
                    color: MealAIColors.blackText,
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

  Widget _buildHealthConcerns(List<AgentResponse.PrimaryConcern> concerns) {
    if (concerns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MealAIColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning,
                color: MealAIColors.grey,
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
                  color: MealAIColors.blackText,
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

  Widget _buildConcernItem(AgentResponse.PrimaryConcern concern) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MealAIColors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            concern.issue ?? 'Health Concern',
            style: TextStyle(
              fontSize: 14.sp.clamp(13.0, 16.0),
              fontWeight: FontWeight.w600,
              color: MealAIColors.blackText,
            ),
          ),
          if (concern.explanation?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              concern.explanation!,
              style: TextStyle(
                fontSize: 13.sp.clamp(12.0, 15.0),
                color: MealAIColors.grey,
                height: 1.4,
              ),
            ),
          ],
          if (concern.recommendations != null &&
              concern.recommendations!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: MealAIColors.blackText,
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
                          color: MealAIColors.blackText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...concern.recommendations!.map<Widget>((rec) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '• ${rec.food} (${rec.quantity}): ${rec.reasoning}',
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

  Widget _buildAlternatives(List<AgentResponse.Ingredient> alternatives) {
    if (alternatives.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.swap_horiz,
                color: MealAIColors.blackText,
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
                  color: MealAIColors.blackText,
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

  Widget _buildAlternativeItem(AgentResponse.Ingredient alternative) {
    final healthScore = alternative.healthScore ?? 0;
    final color = _getHealthScoreColor(healthScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MealAIColors.blackText.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  alternative.name ?? 'Alternative',
                  style: TextStyle(
                    fontSize: 14.sp.clamp(13.0, 16.0),
                    fontWeight: FontWeight.w600,
                    color: MealAIColors.blackText,
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
            'Cal: ${alternative.calories} | Protein: ${alternative.protein}g | Carbs: ${alternative.carbs}g | Fat: ${alternative.fat}g',
            style: TextStyle(
              fontSize: 12.sp.clamp(11.0, 14.0),
              color: MealAIColors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (alternative.healthComments?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              alternative.healthComments!,
              style: TextStyle(
                fontSize: 12.sp.clamp(11.0, 14.0),
                color: MealAIColors.blackText,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: MealAIColors.blackText,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: MealAIColors.whiteText,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: MealAIColors.greyLight,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: const Radius.circular(4),
                ),
                border: Border.all(
                    color: MealAIColors.grey.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NomAI is thinking',
                    style: TextStyle(
                      color: MealAIColors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
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
      color: MealAIColors.whiteText,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: MealAIColors.greyLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: MealAIColors.grey.withOpacity(0.3),
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
                      color: MealAIColors.grey,
                      fontSize: 16,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: MealAIColors.blackText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(() => GestureDetector(
                  onTap: () {
                    if (!controller.isTyping.value) {
                      controller.sendMessage(user!);
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: controller.isTyping.value
                          ? MealAIColors.grey
                          : MealAIColors.blackText,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: controller.isTyping.value
                          ? MealAIColors.greyLight
                          : MealAIColors.whiteText,
                      size: 24,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 7) return MealAIColors.blackText;
    if (score >= 5) return MealAIColors.grey;
    return MealAIColors.grey.withOpacity(0.7);
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
