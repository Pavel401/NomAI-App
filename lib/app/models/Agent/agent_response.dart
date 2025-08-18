// To parse this JSON data, do
//
//     final agentResponse = agentResponseFromJson(jsonString);

import 'dart:convert';

AgentResponse agentResponseFromJson(String str) =>
    AgentResponse.fromJson(json.decode(str));

String agentResponseToJson(AgentResponse data) => json.encode(data.toJson());

class AgentResponse {
  final String? role;
  final DateTime? timestamp;
  final String? content;
  final bool? isFinal;
  final List<ToolCall>? toolCalls;
  final List<ToolReturn>? toolReturns;

  AgentResponse({
    this.role,
    this.timestamp,
    this.content,
    this.isFinal,
    this.toolCalls,
    this.toolReturns,
  });

  factory AgentResponse.fromJson(Map<String, dynamic> json) => AgentResponse(
        role: json["role"],
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
        content: json["content"],
        isFinal: json["is_final"],
        toolCalls: json["tool_calls"] == null
            ? []
            : List<ToolCall>.from(
                json["tool_calls"]!.map((x) => ToolCall.fromJson(x))),
        toolReturns: json["tool_returns"] == null
            ? []
            : List<ToolReturn>.from(
                json["tool_returns"]!.map((x) => ToolReturn.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "role": role,
        "timestamp": timestamp?.toIso8601String(),
        "content": content,
        "is_final": isFinal,
        "tool_calls": toolCalls == null
            ? []
            : List<dynamic>.from(toolCalls!.map((x) => x.toJson())),
        "tool_returns": toolReturns == null
            ? []
            : List<dynamic>.from(toolReturns!.map((x) => x.toJson())),
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
  final Response? response;
  final int? status;
  final String? message;
  final Metadata? metadata;

  Content({
    this.response,
    this.status,
    this.message,
    this.metadata,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        response: json["response"] == null
            ? null
            : Response.fromJson(json["response"]),
        status: json["status"],
        message: json["message"],
        metadata: json["metadata"] == null
            ? null
            : Metadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "response": response?.toJson(),
        "status": status,
        "message": message,
        "metadata": metadata?.toJson(),
      };
}

class Metadata {
  final int? inputTokenCount;
  final int? outputTokenCount;
  final int? totalTokenCount;
  final double? estimatedCost;
  final double? executionTimeSeconds;

  Metadata({
    this.inputTokenCount,
    this.outputTokenCount,
    this.totalTokenCount,
    this.estimatedCost,
    this.executionTimeSeconds,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        inputTokenCount: json["input_token_count"],
        outputTokenCount: json["output_token_count"],
        totalTokenCount: json["total_token_count"],
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

class Response {
  final dynamic message;
  final String? foodName;
  final String? portion;
  final int? portionSize;
  final int? confidenceScore;
  final List<Ingredient>? ingredients;
  final List<PrimaryConcern>? primaryConcerns;
  final List<Ingredient>? suggestAlternatives;
  final int? overallHealthScore;
  final String? overallHealthComments;

  Response({
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
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        message: json["message"],
        foodName: json["foodName"],
        portion: json["portion"],
        portionSize: json["portionSize"],
        confidenceScore: json["confidenceScore"],
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
        overallHealthScore: json["overallHealthScore"],
        overallHealthComments: json["overallHealthComments"],
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
        calories: json["calories"],
        protein: json["protein"],
        carbs: json["carbs"],
        fiber: json["fiber"],
        fat: json["fat"],
        healthScore: json["healthScore"],
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
