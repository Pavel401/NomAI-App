import 'dart:convert';

enum AgentRole { user, model, system, tool }

String getAgentRoleString(AgentRole role) {
  switch (role) {
    case AgentRole.user:
      return 'user';
    case AgentRole.model:
      return 'model';
    case AgentRole.system:
      return 'system';
    case AgentRole.tool:
      return 'tool';
    default:
      return 'unknown';
  }
}

AgentRole getAgentRoleFromString(String role) {
  switch (role) {
    case 'user':
      return AgentRole.user;
    case 'model':
      return AgentRole.model;
    case 'system':
      return AgentRole.system;
    case 'tool':
      return AgentRole.tool;
    default:
      throw ArgumentError('Unknown role: $role');
  }
}

AgentResponse agentResponseFromJson(String str) =>
    AgentResponse.fromJson(json.decode(str));

String agentResponseToJson(AgentResponse data) => json.encode(data.toJson());

class AgentResponse {
  final AgentRole? role;
  final DateTime? timestamp;
  final String? content;
  final bool? isFinal;
  final bool? isPartial;
  final bool? isToolCall;
  final bool? isToolResult;
  final bool? isSystem;
  final List<ToolCall>? toolCalls;
  final List<ToolReturn>? toolReturns;
  final String? imageUrl;

  AgentResponse({
    this.role,
    this.timestamp,
    this.content,
    this.isFinal,
    this.isPartial,
    this.isToolCall,
    this.isToolResult,
    this.isSystem,
    this.toolCalls,
    this.toolReturns,
    this.imageUrl,
  });

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';

    return AgentResponse(
      role: json["role"] == null ? null : getAgentRoleFromString(json["role"]),
      timestamp:
          json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
      content: json["content"],
      isFinal: json["is_final"] ?? json["isFinal"],
      isPartial: json["is_partial"],
      isToolCall: json["is_tool_call"],
      isToolResult: json["is_tool_result"],
      isSystem: json["is_system"],
      toolCalls: json["tool_calls"] == null
          ? []
          : List<ToolCall>.from(
              json["tool_calls"]!.map((x) => ToolCall.fromJson(x))),
      toolReturns: json["tool_returns"] == null
          ? []
          : List<ToolReturn>.from(
              json["tool_returns"]!.map((x) => ToolReturn.fromJson(x))),
      imageUrl: imageUrl,
    );
  }
  Map<String, dynamic> toJson() => {
        "role": role == null ? null : getAgentRoleString(role!),
        "timestamp": timestamp?.toIso8601String(),
        "content": content,
        "is_final": isFinal,
        "is_partial": isPartial,
        "is_tool_call": isToolCall,
        "is_tool_result": isToolResult,
        "is_system": isSystem,
        "tool_calls": toolCalls == null
            ? []
            : List<dynamic>.from(toolCalls!.map((x) => x.toJson())),
        "tool_returns": toolReturns == null
            ? []
            : List<dynamic>.from(toolReturns!.map((x) => x.toJson())),
        "imageUrl": imageUrl,
      };
}

class ToolCall {
  final String? toolName;
  final String? args;
  final String? toolCallId;

  ToolCall({
    this.toolName,
    this.args,
    this.toolCallId,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) => ToolCall(
        toolName: json["tool_name"],
        args: json["args"],
        toolCallId: json["tool_call_id"],
      );

  Map<String, dynamic> toJson() => {
        "tool_name": toolName,
        "args": args,
        "tool_call_id": toolCallId,
      };
}

class ToolReturn {
  final String? toolCallId;
  final Content? content;
  final String? toolName;

  ToolReturn({
    this.toolCallId,
    this.content,
    this.toolName,
  });

  factory ToolReturn.fromJson(Map<String, dynamic> json) => ToolReturn(
        toolCallId: json["tool_call_id"],
        content:
            json["content"] == null ? null : Content.fromJson(json["content"]),
        toolName: json["tool_name"],
      );

  Map<String, dynamic> toJson() => {
        "tool_call_id": toolCallId,
        "content": content?.toJson(),
        "tool_name": toolName,
      };
}

class Content {
  final AgentResponsePayload? response;
  final int? status;
  final String? message;
  final AgentMetadata? metadata;

  Content({
    this.response,
    this.status,
    this.message,
    this.metadata,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        response: json["response"] == null
            ? null
            : AgentResponsePayload.fromJson(json["response"]),
        status: json["status"] is double
            ? (json["status"] as double).toInt()
            : json["status"],
        message: json["message"],
        metadata: json["metadata"] == null
            ? null
            : AgentMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "response": response?.toJson(),
        "status": status,
        "message": message,
        "metadata": metadata?.toJson(),
      };
}

class AgentMetadata {
  final int? inputTokenCount;
  final int? outputTokenCount;
  final int? totalTokenCount;
  final double? estimatedCost;
  final double? executionTimeSeconds;

  AgentMetadata({
    this.inputTokenCount,
    this.outputTokenCount,
    this.totalTokenCount,
    this.estimatedCost,
    this.executionTimeSeconds,
  });

  factory AgentMetadata.fromJson(Map<String, dynamic> json) => AgentMetadata(
        inputTokenCount: json["input_token_count"] is double
            ? (json["input_token_count"] as double).toInt()
            : json["input_token_count"],
        outputTokenCount: json["output_token_count"] is double
            ? (json["output_token_count"] as double).toInt()
            : json["output_token_count"],
        totalTokenCount: json["total_token_count"] is double
            ? (json["total_token_count"] as double).toInt()
            : json["total_token_count"],
        estimatedCost: json["estimated_cost"]?.toDouble(),
        executionTimeSeconds: json["execution_time_seconds"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "input_token_count": inputTokenCount,
        "output_token_count": outputTokenCount,
        "total_token_count": totalTokenCount,
        "estimated_cost": estimatedCost,
        "execution_time_seconds": executionTimeSeconds,
      };
}

class AgentResponsePayload {
  final dynamic message;
  final String? foodName;
  final String? portion;
  final String? imageUrl;
  final int? portionSize;
  final int? confidenceScore;
  final List<Ingredient>? ingredients;
  final List<PrimaryConcern>? primaryConcerns;
  final List<Ingredient>? suggestAlternatives;
  final int? overallHealthScore;
  final String? overallHealthComments;

  AgentResponsePayload({
    this.message,
    this.foodName,
    this.portion,
    this.portionSize,
    this.confidenceScore,
    this.ingredients,
    this.primaryConcerns,
    this.suggestAlternatives,
    this.overallHealthScore,
    this.overallHealthComments,
    this.imageUrl,
  });

  factory AgentResponsePayload.fromJson(Map<String, dynamic> json) =>
      AgentResponsePayload(
        message: json["message"],
        foodName: json["foodName"],
        portion: json["portion"],
        portionSize: json["portionSize"] is double
            ? (json["portionSize"] as double).toInt()
            : json["portionSize"],
        confidenceScore: json["confidenceScore"] is double
            ? (json["confidenceScore"] as double).toInt()
            : json["confidenceScore"],
        ingredients: json["ingredients"] == null
            ? []
            : List<Ingredient>.from(
                json["ingredients"]!.map((x) => Ingredient.fromJson(x))),
        primaryConcerns: json["primaryConcerns"] == null
            ? []
            : List<PrimaryConcern>.from(json["primaryConcerns"]!
                .map((x) => PrimaryConcern.fromJson(x))),
        suggestAlternatives: json["suggestAlternatives"] == null
            ? []
            : List<Ingredient>.from(json["suggestAlternatives"]!
                .map((x) => Ingredient.fromJson(x))),
        overallHealthScore: json["overallHealthScore"] is double
            ? (json["overallHealthScore"] as double).toInt()
            : json["overallHealthScore"],
        overallHealthComments: json["overallHealthComments"],
        imageUrl: json["imageUrl"] == null || json["imageUrl"] == "null"
            ? ''
            : json["imageUrl"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "foodName": foodName,
        "portion": portion,
        "portionSize": portionSize,
        "confidenceScore": confidenceScore,
        "ingredients": ingredients == null
            ? []
            : List<dynamic>.from(ingredients!.map((x) => x.toJson())),
        "primaryConcerns": primaryConcerns == null
            ? []
            : List<dynamic>.from(primaryConcerns!.map((x) => x.toJson())),
        "suggestAlternatives": suggestAlternatives == null
            ? []
            : List<dynamic>.from(suggestAlternatives!.map((x) => x.toJson())),
        "overallHealthScore": overallHealthScore,
        "overallHealthComments": overallHealthComments,
        "imageUrl": imageUrl,
      };
}

class Ingredient {
  final String? name;
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fiber;
  final int? fat;
  final int? healthScore;
  final String? healthComments;

  Ingredient({
    this.name,
    this.calories,
    this.protein,
    this.carbs,
    this.fiber,
    this.fat,
    this.healthScore,
    this.healthComments,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json["name"],
        calories: json["calories"] is double
            ? (json["calories"] as double).toInt()
            : json["calories"],
        protein: json["protein"] is double
            ? (json["protein"] as double).toInt()
            : json["protein"],
        carbs: json["carbs"] is double
            ? (json["carbs"] as double).toInt()
            : json["carbs"],
        fiber: json["fiber"] is double
            ? (json["fiber"] as double).toInt()
            : json["fiber"],
        fat: json["fat"] is double
            ? (json["fat"] as double).toInt()
            : json["fat"],
        healthScore: json["healthScore"] is double
            ? (json["healthScore"] as double).toInt()
            : json["healthScore"],
        healthComments: json["healthComments"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fiber": fiber,
        "fat": fat,
        "healthScore": healthScore,
        "healthComments": healthComments,
      };
}

class PrimaryConcern {
  final String? issue;
  final String? explanation;
  final List<Recommendation>? recommendations;

  PrimaryConcern({
    this.issue,
    this.explanation,
    this.recommendations,
  });

  factory PrimaryConcern.fromJson(Map<String, dynamic> json) => PrimaryConcern(
        issue: json["issue"],
        explanation: json["explanation"],
        recommendations: json["recommendations"] == null
            ? []
            : List<Recommendation>.from(json["recommendations"]!
                .map((x) => Recommendation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "issue": issue,
        "explanation": explanation,
        "recommendations": recommendations == null
            ? []
            : List<dynamic>.from(recommendations!.map((x) => x.toJson())),
      };
}

class Recommendation {
  final String? food;
  final String? quantity;
  final String? reasoning;

  Recommendation({
    this.food,
    this.quantity,
    this.reasoning,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
        food: json["food"],
        quantity: json["quantity"],
        reasoning: json["reasoning"],
      );

  Map<String, dynamic> toJson() => {
        "food": food,
        "quantity": quantity,
        "reasoning": reasoning,
      };
}
