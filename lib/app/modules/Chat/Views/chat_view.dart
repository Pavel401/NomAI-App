import 'package:NomAi/app/components/buttons.dart';
import 'package:NomAi/app/components/dialogs.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/constants/enums.dart';
import 'package:NomAi/app/models/AI/nutrition_input.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart';
import 'package:NomAi/app/models/AI/nutrition_record.dart';
import 'package:NomAi/app/models/Agent/agent_response.dart' as AgentModel;
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/modules/Chat/controller/chat_controller.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:NomAi/app/modules/Scanner/views/scan_view.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/services/nutrition_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class NomAiAgentView extends StatefulWidget {
  const NomAiAgentView({super.key});

  @override
  State<NomAiAgentView> createState() => _NomAiAgentViewState();
}

class _NomAiAgentViewState extends State<NomAiAgentView>
    with TickerProviderStateMixin {
  ChatController controller = Get.put(ChatController());
  ScannerController scannerController = Get.put(ScannerController());
  late AnimationController _fadeController;
  late AnimationController _slideController;
  // Use RxBool for reactive updates instead of setState
  final RxBool _showScrollToTopButton = false.obs;

  // Map to track expansion state of nutrition cards
  final Map<String, bool> _cardExpansionStates = {};

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

    // Add scroll listener for scroll to top button
    controller.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (controller.scrollController.hasClients) {
      // Show button when scrolled down more than 150 pixels
      final bool shouldShow = controller.scrollController.offset > 150;

      // Only update if the state actually changes to avoid unnecessary rebuilds
      if (shouldShow != _showScrollToTopButton.value) {
        _showScrollToTopButton.value = shouldShow;
      }
    }
  }

  @override
  void dispose() {
    controller.scrollController.removeListener(_scrollListener);
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
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MealAIColors.blueGrey,
                  MealAIColors.blueGrey.withOpacity(0.9),
                  MealAIColors.blueGrey.withOpacity(0.8),
                  MealAIColors.blueGrey.withOpacity(0.7),
                  MealAIColors.blueGrey.withOpacity(0.6),
                  MealAIColors.blueGrey.withOpacity(0.5),
                  MealAIColors.blueGrey.withOpacity(0.4),
                  MealAIColors.blueGrey.withOpacity(0.3),
                  MealAIColors.blueGrey.withOpacity(0.2),
                  MealAIColors.blueGrey.withOpacity(0.1),
                  MealAIColors.whiteText,
                ],
                stops: const [
                  0.0,
                  0.1,
                  0.2,
                  0.3,
                  0.4,
                  0.5,
                  0.6,
                  0.7,
                  0.8,
                  0.9,
                  1.0,
                ],
              ),
            ),
            child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(child: _buildMessagesList()),
                    _buildInputArea(),
                  ],
                ),
                // Floating scroll to top button with background and drop shadow
                Positioned(
                  bottom: 100, // Position above the input area
                  right: 16,
                  child: Obx(() => AnimatedScale(
                        scale: _showScrollToTopButton.value ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: _showScrollToTopButton.value ? 1.0 : 0.0,
                          child: _buildScrollToTopButton(),
                        ),
                      )),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

//This widget handles the list of messages in the chat interface
  Widget _buildMessagesList() {
    return Container(
      color: Colors.transparent,
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
          padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
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

  Widget _buildMessageItem(AgentModel.AgentResponse message, int index) {
    final isUser = message.role == AgentModel.AgentRole.user;

    if (message.content?.trim().isEmpty == true &&
        (message.toolReturns == null || message.toolReturns!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return InkWell(
      child: Container(
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

                //If the message is from the Agent ( like the response to nutrition analysis tool), show the nutrition card
                child: message.role == AgentModel.AgentRole.model &&
                        message.toolReturns != null &&
                        message.toolReturns!.isNotEmpty
                    ? _buildNutritionResponse(message) // Pass imageUrl here

                    //If not an tool response, show regular message bubble from the agent
                    : Container(
                        padding: EdgeInsets.only(
                            left: 4.w, right: 4.w, top: 2.h, bottom: 2.h),
                        decoration: BoxDecoration(
                          color: isUser
                              ? MealAIColors.blackText
                              : MealAIColors.greyLight,
                          borderRadius: BorderRadius.circular(20).copyWith(
                            bottomLeft:
                                !isUser ? const Radius.circular(4) : null,
                            bottomRight:
                                isUser ? const Radius.circular(4) : null,
                          ),
                          border: !isUser
                              ? Border.all(
                                  color: MealAIColors.grey.withOpacity(0.2),
                                  width: 1)
                              : null,
                        ),
                        child: InkWell(
                            child: _buildMessageContent(message, isUser)),
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
      ),
    );
  }

// Modified _buildNutritionResponse method - accept imageUrl as parameter
  Widget _buildNutritionResponse(AgentModel.AgentResponse message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        // Display tool outputs - pass imageUrl down
        _buildToolOutputResponse(message.toolReturns!, message),
      ],
    );
  }

  Widget _buildToolOutputResponse(List<AgentModel.ToolReturn> toolReturns,
      AgentModel.AgentResponse message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: toolReturns.map((toolReturn) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildToolCard(
            toolReturn,
            message,
          ), // Pass imageUrl
        );
      }).toList(),
    );
  }

  Widget _buildToolCard(
    AgentModel.ToolReturn toolReturn,
    AgentModel.AgentResponse message,
  ) {
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
          // Tool content - pass imageUrl down
          _buildToolContent(toolReturn, message),
        ],
      ),
    );
  }

// Modified _buildToolContent method
  Widget _buildToolContent(
    AgentModel.ToolReturn toolReturn,
    AgentModel.AgentResponse message,
  ) {
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
              return _buildNutritionCard(
                nutritionResponse,
                message,
              ); // Pass imageUrl
            }
            // Handle other structured responses
            return _buildStructuredResponse(
              content!.response!,
              message,
            ); // Pass imageUrl
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

  Widget _buildStructuredResponse(AgentModel.AgentResponsePayload response,
      AgentModel.AgentResponse message) {
    // If this has nutrition data, use the existing nutrition card
    if (response.ingredients != null && response.ingredients!.isNotEmpty) {
      return _buildNutritionCard(
        response,
        message,
      ); // Pass imageUrl
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

  Widget _buildRawResponse(AgentModel.ToolReturn toolReturn) {
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

//This widget builds the content inside each chat bubble, handling both text and images
  Widget _buildMessageContent(AgentModel.AgentResponse message, bool isUser) {
    final cleanContent = _cleanMessageContent(message);
    String imageUrl = "";
    if (controller.hasImageUrl(message.content!)) {
      imageUrl = controller.extractImageUrlFromContent(message.content!)!;
    }

    if (_hasImageUrl(message)) {
      imageUrl = message.imageUrl!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display image if available
        if (_hasImageUrl(message) ||
            controller.hasImageUrl(message.content!)) ...[
          _buildMessageImage(imageUrl),
          if (cleanContent.isNotEmpty) const SizedBox(height: 8),
        ],

        // Display text content
        if (cleanContent.isNotEmpty)
          _buildMarkdownContent(
            controller.getFormattedUserInput(cleanContent),
            isUser,
            MediaQuery.of(context).size.width * 0.75,
          ),
      ],
    );
  }

  String _cleanMessageContent(AgentModel.AgentResponse message) {
    String cleanContent = message.content?.trim() ?? '';

    return cleanContent;
  }

  bool _hasImageUrl(AgentModel.AgentResponse message) {
    return message.imageUrl != null && message.imageUrl!.isNotEmpty;
  }

  Widget _buildMessageImage(String imageUrl) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 250,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 150,
            color: MealAIColors.greyLight,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) {
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
        // Handle link taps if needed
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

  Widget _buildNutritionCard(AgentModel.AgentResponsePayload response,
      AgentModel.AgentResponse message) {
    // Create a stable unique key for this card based on message content
    final cardKey = '${response.foodName ?? 'unknown'}_${message.hashCode}';

    // Get current expansion state (default to false)
    final isExpanded = _cardExpansionStates[cardKey] ?? false;

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
          // Expandable header that's always visible
          InkWell(
            onTap: () {
              setState(() {
                _cardExpansionStates[cardKey] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with expand/collapse button
                  Row(
                    children: [
                      Expanded(
                        child: _buildNutritionHeader(response),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MealAIColors.blackText.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: isExpanded ? 0.5 : 0.0,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: MealAIColors.blackText,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Always show basic nutrition overview when collapsed
                  if (response.ingredients != null &&
                      response.ingredients!.isNotEmpty) ...[
                    SizedBox(height: 3.w.clamp(8.0, 12.0)),
                    _buildCompactNutritionSummary(response.ingredients!),
                  ],

                  // Show expand hint when collapsed
                  if (!isExpanded) ...[
                    SizedBox(height: 2.w.clamp(6.0, 8.0)),
                    Center(
                      child: Text(
                        'Tap to view detailed analysis',
                        style: TextStyle(
                          fontSize: 11.sp.clamp(10.0, 13.0),
                          color: MealAIColors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  // Pass the imageUrl parameter instead of trying to extract from toolCalls
                  _buildAddToMealsButton(
                    response,
                    message,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionHeader(AgentModel.AgentResponsePayload response) {
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

  Widget _buildNutritionOverview(List<AgentModel.Ingredient> ingredients) {
    final total = NutritionService.calculateTotalNutrition(ingredients);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Nutritional Breakdown', Icons.pie_chart),
        SizedBox(height: 4.w.clamp(12.0, 16.0)),
        _buildNutritionGrid(total),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: MealAIColors.blackText.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: MealAIColors.blackText,
            size: 5.w.clamp(18.0, 24.0),
          ),
        ),
        SizedBox(width: 3.w.clamp(8.0, 12.0)),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp.clamp(14.0, 18.0),
              fontWeight: FontWeight.w600,
              color: MealAIColors.blackText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionGrid(total) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridConfig = _getNutritionGridConfig(constraints.maxWidth);

        return GridView.count(
          crossAxisCount: gridConfig['crossAxisCount']!.toInt(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: gridConfig['childAspectRatio']!,
          crossAxisSpacing: 3.w.clamp(8.0, 12.0),
          mainAxisSpacing: 3.w.clamp(8.0, 12.0),
          children: [
            _buildNutritionValueCard(
                '${total.calories}', 'Calories', Icons.local_fire_department),
            _buildNutritionValueCard(
                '${total.protein}g', 'Protein', Icons.fitness_center),
            _buildNutritionValueCard('${total.carbs}g', 'Carbs', Icons.grain),
            _buildNutritionValueCard('${total.fat}g', 'Fat', Icons.opacity),
          ],
        );
      },
    );
  }

  Map<String, double> _getNutritionGridConfig(double width) {
    final crossAxisCount = width < 250 ? 1.0 : 2.0;
    final childAspectRatio = width < 250 ? 3.5 : 2.5;

    return {
      'crossAxisCount': crossAxisCount,
      'childAspectRatio': childAspectRatio,
    };
  }

  Widget _buildCompactNutritionSummary(
      List<AgentModel.Ingredient> ingredients) {
    final total = NutritionService.calculateTotalNutrition(ingredients);

    return Container(
      padding: EdgeInsets.all(3.w.clamp(12.0, 16.0)),
      decoration: BoxDecoration(
        color: MealAIColors.greyLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MealAIColors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactNutrientInfo(
              '${total.calories}', 'Cal', Icons.local_fire_department),
          _buildCompactNutrientInfo(
              '${total.protein}g', 'Protein', Icons.fitness_center),
          _buildCompactNutrientInfo('${total.carbs}g', 'Carbs', Icons.grain),
          _buildCompactNutrientInfo('${total.fat}g', 'Fat', Icons.opacity),
        ],
      ),
    );
  }

  Widget _buildCompactNutrientInfo(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: MealAIColors.blackText,
          size: 4.w.clamp(16.0, 20.0),
        ),
        SizedBox(height: 1.w.clamp(4.0, 6.0)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp.clamp(11.0, 14.0),
            fontWeight: FontWeight.w600,
            color: MealAIColors.blackText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp.clamp(9.0, 12.0),
            fontWeight: FontWeight.w400,
            color: MealAIColors.grey,
          ),
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

  Widget _buildIngredientsBreakdown(List<AgentModel.Ingredient> ingredients) {
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

  Widget _buildIngredientItem(AgentModel.Ingredient ingredient) {
    final healthScore = ingredient.healthScore ?? 0;
    final color = _getHealthScoreColor(healthScore);

    return Container(
      margin: EdgeInsets.only(bottom: 3.w.clamp(8.0, 12.0)),
      padding: EdgeInsets.all(4.w.clamp(12.0, 16.0)),
      width: double.infinity,
      decoration: _buildIngredientDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIngredientHeader(ingredient, healthScore, color),
          SizedBox(height: 2.w.clamp(6.0, 8.0)),
          _buildIngredientNutrition(ingredient),
          if (_hasHealthComments(ingredient)) ...[
            SizedBox(height: 2.w.clamp(6.0, 8.0)),
            _buildIngredientHealthComments(ingredient.healthComments!),
          ],
        ],
      ),
    );
  }

  BoxDecoration _buildIngredientDecoration(Color color) {
    return BoxDecoration(
      color: MealAIColors.greyLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildIngredientHeader(
      AgentModel.Ingredient ingredient, int healthScore, Color color) {
    return Row(
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
        _buildHealthScoreBadge(healthScore, color),
      ],
    );
  }

  Widget _buildHealthScoreBadge(int healthScore, Color color) {
    return Container(
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
    );
  }

  Widget _buildIngredientNutrition(AgentModel.Ingredient ingredient) {
    return Text(
      'Cal: ${ingredient.calories} | Protein: ${ingredient.protein}g | Carbs: ${ingredient.carbs}g | Fat: ${ingredient.fat}g',
      style: TextStyle(
        fontSize: 12.sp.clamp(11.0, 14.0),
        color: MealAIColors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildIngredientHealthComments(String comments) {
    return Text(
      comments,
      style: TextStyle(
        fontSize: 12.sp.clamp(11.0, 14.0),
        color: MealAIColors.blackText,
        height: 1.4,
      ),
    );
  }

  bool _hasHealthComments(AgentModel.Ingredient ingredient) {
    return ingredient.healthComments?.isNotEmpty == true;
  }

  Widget _buildHealthAssessment(AgentModel.AgentResponsePayload response) {
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

  Widget _buildHealthConcerns(List<AgentModel.PrimaryConcern> concerns) {
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

  Widget _buildConcernItem(AgentModel.PrimaryConcern concern) {
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

  Widget _buildAlternatives(List<AgentModel.Ingredient> alternatives) {
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

  Widget _buildAlternativeItem(AgentModel.Ingredient alternative) {
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

  Future<void> _addToMealsWithImageUrl(
    BuildContext context,
    StateSetter setState,
    AgentModel.AgentResponsePayload response,
  ) async {
    setState(() {});

    // Show loading dialog
    AppDialogs.showLoadingDialog(
      title: "Adding to Daily Meals",
      message: "Please wait while we add this meal to your daily nutrition...",
    );

    try {
      final userId = user!.userId;
      final userModel = _getUserModel(context);
      final nutritionOutput = _convertToNutritionOutput(response);
      final nutritionRecord =
          _createNutritionRecord(nutritionOutput, response, userModel);
      final totalNutrition = _calculateTotalNutrition(response);
      final updatedDailyRecords =
          await _updateDailyRecords(userId, nutritionRecord, totalNutrition);

      // Save to database
      final nutritionRecordRepo = NutritionRecordRepo();
      final result = await nutritionRecordRepo.saveNutritionData(
          updatedDailyRecords, userId);

      await _handleSaveResult(result, userId, nutritionRecord.recordTime!);
    } catch (e) {
      _handleError("Failed to add to meals. Please try again.");
    }
  }

  UserModel? _getUserModel(BuildContext context) {
    try {
      if (context.mounted) {
        final userBloc = context.read<UserBloc>();
        final userState = userBloc.state;
        if (userState is UserLoaded) {
          return userState.userModel;
        }
      }
    } catch (e) {
      print("Error getting user preferences: $e");
    }
    return null;
  }

  NutritionOutput _convertToNutritionOutput(
      AgentModel.AgentResponsePayload response) {
    return NutritionOutput(
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
  }

  NutritionRecord _createNutritionRecord(NutritionOutput nutritionOutput,
      AgentModel.AgentResponsePayload response, UserModel? userModel) {
    final time = DateTime.now();
    return NutritionRecord(
      recordTime: time,
      nutritionInputQuery: NutritionInputQuery(
        imageUrl: response.imageUrl ?? "",
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
  }

  Map<String, int> _calculateTotalNutrition(
      AgentModel.AgentResponsePayload response) {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalFat = 0;
    int totalCarbs = 0;

    if (response.ingredients != null) {
      for (final ingredient in response.ingredients!) {
        totalCalories += ingredient.calories ?? 0;
        totalProtein += ingredient.protein ?? 0;
        totalFat += ingredient.fat ?? 0;
        totalCarbs += ingredient.carbs ?? 0;
      }
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'fat': totalFat,
      'carbs': totalCarbs,
    };
  }

  Future<DailyNutritionRecords> _updateDailyRecords(String userId,
      NutritionRecord nutritionRecord, Map<String, int> totalNutrition) async {
    final nutritionRecordRepo = NutritionRecordRepo();
    final time = nutritionRecord.recordTime!;
    final dailyRecordID = nutritionRecordRepo.getRecordId(time);

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
    final totalConsumedCalories =
        existingRecords.dailyConsumedCalories + totalNutrition['calories']!;
    final totalConsumedFat =
        existingRecords.dailyConsumedFat + totalNutrition['fat']!;
    final totalConsumedProtein =
        existingRecords.dailyConsumedProtein + totalNutrition['protein']!;
    final totalConsumedCarb =
        existingRecords.dailyConsumedCarb + totalNutrition['carbs']!;

    // Add new record to daily records
    final updatedDailyRecords =
        List<NutritionRecord>.from(existingRecords.dailyRecords);
    updatedDailyRecords.add(nutritionRecord);

    // Create updated daily nutrition records
    return DailyNutritionRecords(
      dailyRecords: updatedDailyRecords,
      recordDate: time,
      recordId: dailyRecordID,
      dailyConsumedCalories: totalConsumedCalories,
      dailyBurnedCalories: existingRecords.dailyBurnedCalories,
      dailyConsumedProtein: totalConsumedProtein,
      dailyConsumedFat: totalConsumedFat,
      dailyConsumedCarb: totalConsumedCarb,
    );
  }

  Future<void> _handleSaveResult(
      QueryStatus result, String userId, DateTime time) async {
    if (result == QueryStatus.SUCCESS) {
      await scannerController.getRecordByDate(userId, time);
      AppDialogs.hideDialog();
      AppDialogs.showSuccessSnackbar(
        title: "Success",
        message: "Added to your meals!",
      );
    } else {
      AppDialogs.hideDialog();
      AppDialogs.showErrorSnackbar(
        title: "Error",
        message: "Failed to add to meals. Please try again.",
      );
    }
  }

  void _handleError(String message) {
    AppDialogs.hideDialog();
    AppDialogs.showErrorSnackbar(
      title: "Error",
      message: message,
    );
  }

// Modified _buildAddToMealsButton method - accept imageUrl as parameter
  Widget _buildAddToMealsButton(
    AgentModel.AgentResponsePayload response,
    AgentModel.AgentResponse message,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(top: 4.w.clamp(12.0, 20.0)),
          child: PrimaryButton(
            onPressed: () {
              _addToMealsWithImageUrl(context, setState, response)
                  .then((_) {})
                  .catchError((error) {});
            },
            tile: _getButtonText(
              false,
              false,
            ),
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

  Widget _buildScrollToTopButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: MealAIColors.whiteText,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: MealAIColors.blackText.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: MealAIColors.blackText.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: MealAIColors.blackText.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _scrollToTop,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: MealAIColors.blackText,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToTop() {
    if (controller.scrollController.hasClients) {
      // Smooth animation to scroll to top
      controller.scrollController
          .animateTo(
        0.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      )
          .then((_) {
        // Hide the button after animation completes and we're at the top
        if (controller.scrollController.hasClients &&
            controller.scrollController.offset <= 10) {
          _showScrollToTopButton.value = false;
        }
      });
    }
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
