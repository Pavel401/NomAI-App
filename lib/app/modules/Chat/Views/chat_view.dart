import 'package:NomAi/app/components/buttons.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/modules/Scanner/views/scan_view.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/models/AI/nutrition_record.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart';
import 'package:NomAi/app/models/AI/nutrition_input.dart';
import 'package:NomAi/app/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            // if (isNarrow) ...[
            //   _buildCompactUserControls(),
            // ] else ...[
            //   _buildFullUserControls(),
            // ],
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
    final isSystem = message.isSystem == true;

    if (message.content?.trim().isEmpty == true &&
        (message.toolReturns == null || message.toolReturns!.isEmpty)) {
      return const SizedBox.shrink();
    }

    // Handle system messages (like tool indicators) similar to web implementation
    if (isSystem) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: MealAIColors.greyLight,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: MealAIColors.grey.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: MealAIColors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  message.content ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: MealAIColors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          //If the message is from the AI agent, show the agent icon
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
            SizedBox(width: 2.w),
          ],
          //Now the message bubble ,
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: message.role == 'model' &&
                      message.toolReturns != null &&
                      message.toolReturns!.isNotEmpty
                  ? _buildNutritionResponse(message)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? MealAIColors.blackText
                            : MealAIColors.greyLight,
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomLeft: !isUser ? const Radius.circular(4) : null,
                          bottomRight: isUser ? const Radius.circular(4) : null,
                        ),
                        border: !isUser
                            ? Border.all(
                                color: MealAIColors.grey.withOpacity(0.2),
                                width: 1)
                            : null,
                      ),
                      child: _buildMessageContent(message, isUser),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display tool calls if they exist (showing what tools are being used)
        if (message.toolCalls != null && message.toolCalls!.isNotEmpty) ...[
          ...message.toolCalls!
              .map((toolCall) => _buildToolCallIndicator(toolCall)),
          SizedBox(height: 2.w.clamp(8.0, 12.0)),
        ],

        // Display message content if available
        if (message.content?.trim().isNotEmpty == true) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MealAIColors.greyLight,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(
                  color: MealAIColors.grey.withOpacity(0.2), width: 1),
            ),
            child: MarkdownBody(
              data: message.content!,
              styleSheet: _getMarkdownStyleSheet(false, 400),
              shrinkWrap: true,
              selectable: true,
            ),
          ),
          SizedBox(height: 3.w.clamp(12.0, 16.0)),
        ],

        // Display tool outputs
        _buildToolOutputResponse(message.toolReturns!),
      ],
    );
  }

  Widget _buildToolCallIndicator(AgentResponse.ToolCall toolCall) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: MealAIColors.blackText.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MealAIColors.blackText.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(MealAIColors.blackText),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Using ${_getToolDisplayName(toolCall.toolName ?? 'tool')}...',
            style: TextStyle(
              fontSize: 13.sp.clamp(12.0, 15.0),
              color: MealAIColors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolOutputResponse(List<AgentResponse.ToolReturn> toolReturns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: toolReturns.map((toolReturn) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildToolCard(toolReturn),
        );
      }).toList(),
    );
  }

  Widget _buildToolCard(AgentResponse.ToolReturn toolReturn) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MealAIColors.whiteText,
        border: Border.all(
            color: MealAIColors.blackText.withOpacity(0.08), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MealAIColors.blackText.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: MealAIColors.blackText.withOpacity(0.02),
            offset: const Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tool header
          _buildToolHeader(toolReturn),

          // Tool content
          _buildToolContent(toolReturn),
        ],
      ),
    );
  }

  Widget _buildToolHeader(AgentResponse.ToolReturn toolReturn) {
    final toolName = toolReturn.toolName ?? 'Tool Output';
    final status = toolReturn.content?.status ?? 200;
    final isSuccess = status >= 200 && status < 300;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w.clamp(16.0, 20.0)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSuccess
              ? [
                  MealAIColors.blackText.withOpacity(0.03),
                  MealAIColors.blackText.withOpacity(0.08),
                ]
              : [
                  MealAIColors.red.withOpacity(0.03),
                  MealAIColors.red.withOpacity(0.08),
                ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(
            color: MealAIColors.blackText.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w.clamp(10.0, 12.0)),
            decoration: BoxDecoration(
              color: isSuccess
                  ? MealAIColors.blackText.withOpacity(0.1)
                  : MealAIColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isSuccess
                      ? MealAIColors.blackText.withOpacity(0.1)
                      : MealAIColors.red.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              _getToolIcon(toolName),
              color: isSuccess ? MealAIColors.blackText : MealAIColors.red,
              size: 5.w.clamp(20.0, 26.0),
            ),
          ),
          SizedBox(width: 4.w.clamp(12.0, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getToolDisplayName(toolName),
                  style: TextStyle(
                    fontSize: 17.sp.clamp(15.0, 19.0),
                    fontWeight: FontWeight.w700,
                    color: MealAIColors.blackText,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 1.5.w.clamp(4.0, 6.0)),
                Wrap(
                  spacing: 2.w.clamp(8.0, 10.0),
                  runSpacing: 1.w.clamp(4.0, 6.0),
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w.clamp(10.0, 12.0),
                        vertical: 1.5.w.clamp(5.0, 7.0),
                      ),
                      decoration: BoxDecoration(
                        color: isSuccess ? Colors.green : MealAIColors.red,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isSuccess ? Colors.green : MealAIColors.red)
                                .withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSuccess ? Icons.check_circle : Icons.error,
                            size: 14,
                            color: MealAIColors.whiteText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSuccess ? 'Success' : 'Error',
                            style: TextStyle(
                              fontSize: 12.sp.clamp(11.0, 14.0),
                              fontWeight: FontWeight.w700,
                              color: MealAIColors.whiteText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (toolReturn.content?.metadata != null)
                      _buildMetadataBadge(toolReturn.content!.metadata!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataBadge(AgentResponse.AgentMetadata metadata) {
    String displayText = '';
    IconData icon = Icons.info;

    if (metadata.executionTimeSeconds != null) {
      displayText = '${metadata.executionTimeSeconds!.toStringAsFixed(2)}s';
      icon = Icons.timer;
    } else if (metadata.totalTokenCount != null) {
      displayText = '${metadata.totalTokenCount} tokens';
      icon = Icons.token;
    }

    if (displayText.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 3.w.clamp(10.0, 12.0),
        vertical: 1.5.w.clamp(5.0, 7.0),
      ),
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MealAIColors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: MealAIColors.grey.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: MealAIColors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 11.sp.clamp(10.0, 13.0),
              fontWeight: FontWeight.w600,
              color: MealAIColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolContent(AgentResponse.ToolReturn toolReturn) {
    final content = toolReturn.content;

    return Padding(
      padding: EdgeInsets.all(4.w.clamp(16.0, 20.0)),
      child: Builder(
        builder: (context) {
          if (content?.response != null) {
            // Check if it's a nutrition response
            final nutritionResponse =
                NutritionService.extractNutritionResponse([toolReturn]);
            if (nutritionResponse != null) {
              return _buildNutritionCard(nutritionResponse);
            }

            // Handle other structured responses
            return _buildStructuredResponse(content!.response!);
          }

          if (content?.message != null) {
            return _buildMessageResponse(content!.message!);
          }

          // Fallback to raw content display
          return _buildRawResponse(toolReturn);
        },
      ),
    );
  }

  Widget _buildStructuredResponse(AgentResponse.AgentResponsePayload response) {
    // If this has nutrition data, use the existing nutrition card
    if (response.ingredients != null && response.ingredients!.isNotEmpty) {
      return _buildNutritionCard(response);
    }

    // For other structured responses, create a generic structured view
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (response.message != null)
          _buildResponseField('Message', response.message.toString()),
        if (response.foodName != null)
          _buildResponseField('Food Name', response.foodName!),
        // Add more fields as needed based on your response structure
      ],
    );
  }

  Widget _buildMessageResponse(String message) {
    return Container(
      padding: EdgeInsets.all(4.w.clamp(16.0, 20.0)),
      decoration: BoxDecoration(
        color: MealAIColors.greyLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MealAIColors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: MealAIColors.blackText.withOpacity(0.02),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.message,
                size: 16,
                color: MealAIColors.grey,
              ),
              SizedBox(width: 2.w.clamp(8.0, 10.0)),
              Text(
                'Response',
                style: TextStyle(
                  fontSize: 13.sp.clamp(12.0, 15.0),
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w.clamp(8.0, 12.0)),
          Text(
            message,
            style: TextStyle(
              fontSize: 15.sp.clamp(13.0, 17.0),
              color: MealAIColors.blackText,
              height: 1.6,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawResponse(AgentResponse.ToolReturn toolReturn) {
    final rawContent =
        toolReturn.content?.toJson().toString() ?? 'No content available';

    return Container(
      padding: EdgeInsets.all(4.w.clamp(16.0, 20.0)),
      decoration: BoxDecoration(
        color: MealAIColors.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MealAIColors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                size: 18,
                color: MealAIColors.grey,
              ),
              SizedBox(width: 2.w.clamp(8.0, 10.0)),
              Text(
                'Raw Output',
                style: TextStyle(
                  fontSize: 13.sp.clamp(12.0, 15.0),
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.grey,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: MealAIColors.blackText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'JSON',
                  style: TextStyle(
                    fontSize: 10.sp.clamp(9.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: MealAIColors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w.clamp(12.0, 16.0)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w.clamp(12.0, 16.0)),
            decoration: BoxDecoration(
              color: MealAIColors.blackText.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MealAIColors.grey.withOpacity(0.15)),
            ),
            child: SelectableText(
              rawContent,
              style: TextStyle(
                fontSize: 12.sp.clamp(11.0, 14.0),
                color: MealAIColors.blackText.withOpacity(0.8),
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseField(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.w.clamp(8.0, 12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp.clamp(11.0, 14.0),
              fontWeight: FontWeight.w600,
              color: MealAIColors.grey,
            ),
          ),
          SizedBox(height: 1.w.clamp(4.0, 6.0)),
          Container(
            padding: EdgeInsets.all(3.w.clamp(8.0, 12.0)),
            decoration: BoxDecoration(
              color: MealAIColors.greyLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MealAIColors.grey.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp.clamp(12.0, 15.0),
                color: MealAIColors.blackText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getToolIcon(String toolName) {
    switch (toolName.toLowerCase()) {
      case 'nutrition_analysis':
      case 'analyze_food':
        return Icons.analytics;
      case 'search':
      case 'web_search':
        return Icons.search;
      case 'image_analysis':
      case 'analyze_image':
        return Icons.image;
      case 'recommendation':
        return Icons.recommend;
      case 'calculation':
      case 'calculate':
        return Icons.calculate;
      case 'database':
      case 'query':
        return Icons.storage;
      default:
        return Icons.extension;
    }
  }

  String _getToolDisplayName(String toolName) {
    switch (toolName.toLowerCase()) {
      case 'nutrition_analysis':
      case 'analyze_food':
        return 'Nutrition Analysis';
      case 'search':
      case 'web_search':
        return 'Web Search';
      case 'image_analysis':
      case 'analyze_image':
        return 'Image Analysis';
      case 'recommendation':
        return 'Recommendation Engine';
      case 'calculation':
      case 'calculate':
        return 'Calculation';
      case 'database':
      case 'query':
        return 'Database Query';
      default:
        return toolName
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '')
            .join(' ');
    }
  }

  Widget _buildMessageContent(
      AgentResponse.AgentResponse message, bool isUser) {
    // Debug print to check imageUrl
    if (message.imageUrl != null) {
      print('DEBUG: Message has imageUrl: ${message.imageUrl}');
    }

    // Clean the content - remove any URLs that might be embedded in text
    String cleanContent = message.content?.trim() ?? '';

    // If content looks like it contains a Firebase Storage URL, remove it
    if (cleanContent.contains('firebasestorage.googleapis.com') ||
        cleanContent.startsWith('[User provided an image:') ||
        cleanContent.startsWith('User provided an image:')) {
      // If the message has an imageUrl, don't show the URL text
      if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
        // Try to extract any text that's not the URL
        final lines = cleanContent.split('\n');
        final nonUrlLines = lines
            .where((line) =>
                !line.contains('firebasestorage.googleapis.com') &&
                !line.contains('[User provided an image:') &&
                !line.contains('User provided an image:'))
            .toList();
        cleanContent = nonUrlLines.join('\n').trim();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display image if available
        if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(
              maxWidth: 250,
              maxHeight: 250,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: message.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: MealAIColors.greyLight,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) {
                  print('DEBUG: Error loading image: $error');
                  return Container(
                    height: 150,
                    color: MealAIColors.greyLight,
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),
          ),
          if (cleanContent.isNotEmpty) const SizedBox(height: 8),
        ],
        // Display text content
        if (cleanContent.isNotEmpty)
          _buildMarkdownContent(
            cleanContent,
            isUser,
            MediaQuery.of(context).size.width * 0.75,
          ),
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

  Widget _buildNutritionCard(AgentResponse.AgentResponsePayload response) {
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
                //This is the header section with food name, portion size, confidence score
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

                _buildAddToMealsButton(response),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionHeader(AgentResponse.AgentResponsePayload response) {
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
            // _buildInfoChip('Confidence', '${response.confidenceScore}/10'),
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
          color: MealAIColors.blackText,
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

  Widget _buildHealthAssessment(AgentResponse.AgentResponsePayload response) {
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

  Future<void> _addToMeals(BuildContext context, StateSetter setState,
      AgentResponse.AgentResponsePayload response) async {
    setState(() {});

    try {
      // Get user ID
      String userId = user!.userId;

      // Get user model for preferences
      UserModel? userModel;
      try {
        if (context.mounted) {
          final userBloc = context.read<UserBloc>();
          final userState = userBloc.state;
          if (userState is UserLoaded) {
            userModel = userState.userModel;
          }
        }
      } catch (e) {
        print("Error getting user preferences: $e");
      }

      // Convert AgentResponse.Response to NutritionOutput
      final nutritionOutput = NutritionOutput(
        status: 200,
        message: "Added from chat",
        response: NutritionResponse(
          message: response.message?.toString() ?? "",
          foodName: response.foodName,
          portion: response.portion,
          portionSize: response.portionSize?.toDouble(),
          confidenceScore: response.confidenceScore,
          ingredients: response.ingredients
              ?.map((ingredient) => Ingredient(
                    name: ingredient.name,
                    calories: ingredient.calories,
                    protein: ingredient.protein,
                    carbs: ingredient.carbs,
                    fiber: ingredient.fiber,
                    fat: ingredient.fat,
                    healthScore: ingredient.healthScore,
                    healthComments: ingredient.healthComments,
                  ))
              .toList(),
          primaryConcerns: response.primaryConcerns
              ?.map((concern) => PrimaryConcern(
                    issue: concern.issue,
                    explanation: concern.explanation,
                    recommendations: concern.recommendations
                        ?.map((rec) => Recommendation(
                              food: rec.food,
                              quantity: rec.quantity,
                              reasoning: rec.reasoning,
                            ))
                        .toList(),
                  ))
              .toList(),
          suggestAlternatives: response.suggestAlternatives
              ?.map((alt) => Ingredient(
                    name: alt.name,
                    calories: alt.calories,
                    protein: alt.protein,
                    carbs: alt.carbs,
                    fiber: alt.fiber,
                    fat: alt.fat,
                    healthScore: alt.healthScore,
                    healthComments: alt.healthComments,
                  ))
              .toList(),
          overallHealthScore: response.overallHealthScore,
          overallHealthComments: response.overallHealthComments,
        ),
      );

      // Create nutrition record similar to ScannerController
      DateTime time = DateTime.now();
      NutritionRecord nutritionRecord = NutritionRecord(
        recordTime: time,
        nutritionInputQuery: NutritionInputQuery(
          imageUrl: "",
          scanMode: ScanMode.food,
          food_description: response.foodName ?? "Chat analysis",
          dietaryPreferences: userModel?.userInfo?.selectedDiet != null
              ? [userModel!.userInfo!.selectedDiet]
              : [],
          allergies: userModel?.userInfo?.selectedAllergies != null &&
                  userModel!.userInfo!.selectedAllergies.isNotEmpty
              ? userModel.userInfo!.selectedAllergies
              : [],
          selectedGoals: userModel?.userInfo?.selectedGoal != null
              ? [userModel!.userInfo!.selectedGoal.name]
              : [],
        ),
        processingStatus: ProcessingStatus.COMPLETED,
        nutritionOutput: nutritionOutput,
      );

      final nutritionRecordRepo = NutritionRecordRepo();
      String dailyRecordID = nutritionRecordRepo.getRecordId(time);

      // Calculate total nutrition values
      int totalNutritionValue = 0;
      int totalProteinValue = 0;
      int totalFatValue = 0;
      int totalCarbValue = 0;

      if (response.ingredients != null) {
        for (final ingredient in response.ingredients!) {
          totalNutritionValue += ingredient.calories ?? 0;
          totalProteinValue += ingredient.protein ?? 0;
          totalFatValue += ingredient.fat ?? 0;
          totalCarbValue += ingredient.carbs ?? 0;
        }
      }

      // Get existing records for today
      DailyNutritionRecords? existingRecords;
      try {
        existingRecords =
            await nutritionRecordRepo.getNutritionData(userId, time);
      } catch (e) {
        // If no existing records, create new empty one
        existingRecords = DailyNutritionRecords(
          dailyRecords: [],
          recordDate: time,
          recordId: dailyRecordID,
          dailyConsumedCalories: 0,
          dailyBurnedCalories: 0,
          dailyConsumedProtein: 0,
          dailyConsumedFat: 0,
          dailyConsumedCarb: 0,
        );
      }

      // Calculate updated totals
      int totalConsumedCalories =
          existingRecords.dailyConsumedCalories + totalNutritionValue;
      int totalConsumedFat = existingRecords.dailyConsumedFat + totalFatValue;
      int totalConsumedProtein =
          existingRecords.dailyConsumedProtein + totalProteinValue;
      int totalConsumedCarb =
          existingRecords.dailyConsumedCarb + totalCarbValue;

      // Add new record to daily records
      List<NutritionRecord> updatedDailyRecords =
          List.from(existingRecords.dailyRecords);
      updatedDailyRecords.add(nutritionRecord);

      // Create updated daily nutrition records
      DailyNutritionRecords dailyNutritionRecords = DailyNutritionRecords(
        dailyRecords: updatedDailyRecords,
        recordDate: time,
        recordId: dailyRecordID,
        dailyConsumedCalories: totalConsumedCalories,
        dailyBurnedCalories: existingRecords.dailyBurnedCalories,
        dailyConsumedProtein: totalConsumedProtein,
        dailyConsumedFat: totalConsumedFat,
        dailyConsumedCarb: totalConsumedCarb,
      );

      // Save to database
      print("🚀 About to save nutrition data to database...");
      final result = await nutritionRecordRepo.saveNutritionData(
          dailyNutritionRecords, userId);
      print("📤 Save operation completed with result: $result");

      if (result == QueryStatus.SUCCESS) {
        print("✅ Save successful, showing success message");
        Get.snackbar(
          "Success",
          "Added to your meals!",
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        print("❌ Save failed, showing error message");
        Get.snackbar(
          "Error",
          "Failed to add to meals. Please try again.",
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error adding to meals: $e");
      Get.snackbar(
        "Error",
        "Failed to add to meals. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  Widget _buildAddToMealsButton(AgentResponse.AgentResponsePayload response) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isAdded = false;
        bool isLoading = false;

        // Function to update states
        void updateButtonState({bool? loading, bool? added}) {
          setState(() {
            if (loading != null) isLoading = loading;
            if (added != null) isAdded = added;
          });
        }

        return Padding(
          padding: EdgeInsets.only(top: 4.w.clamp(12.0, 20.0)),
          child: PrimaryButton(
            onPressed: () {
              if (isAdded || isLoading) return;

              updateButtonState(loading: true);

              _addToMeals(context, setState, response).then((_) {
                updateButtonState(loading: false, added: true);
              }).catchError((error) {
                updateButtonState(loading: false);
              });
            },
            tile: _getButtonText(isLoading, isAdded),
          ),
        );
      },
    );
  }

  String _getButtonText(bool isLoading, bool isAdded) {
    if (isLoading) return 'Adding...';
    if (isAdded) return 'Added to My Meals ✓';
    return 'Add to My Meals';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview section
            Obx(() => controller.selectedImage.value != null
                ? _buildImagePreview()
                : const SizedBox.shrink()),

            // Input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Camera/Gallery button
                GestureDetector(
                  onTap: _showImageSourceBottomSheet,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: MealAIColors.greyLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: MealAIColors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: MealAIColors.blackText,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Text input
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
                      onSubmitted: (_) => _sendMessage(),
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

                // Send button
                Obx(() => GestureDetector(
                      onTap: () {
                        if (!controller.isTyping.value &&
                            !controller.isUploadingImage.value) {
                          _sendMessage();
                        }
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (controller.isTyping.value ||
                                  controller.isUploadingImage.value)
                              ? MealAIColors.grey
                              : MealAIColors.blackText,
                          shape: BoxShape.circle,
                        ),
                        child: controller.isUploadingImage.value
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    MealAIColors.whiteText,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: (controller.isTyping.value ||
                                        controller.isUploadingImage.value)
                                    ? MealAIColors.greyLight
                                    : MealAIColors.whiteText,
                                size: 24,
                              ),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MealAIColors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(
                controller.selectedImage.value!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => controller.removeSelectedImage(),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: MealAIColors.blackText.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: MealAIColors.whiteText,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    controller.sendMessage(user!);
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: MealAIColors.whiteText,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MealAIColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MealAIColors.blackText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      controller.pickImageFromCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: MealAIColors.greyLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: MealAIColors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: MealAIColors.blackText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Camera',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: MealAIColors.blackText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      controller.pickImageFromGallery();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: MealAIColors.greyLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: MealAIColors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library,
                            size: 32,
                            color: MealAIColors.blackText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: MealAIColors.blackText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
