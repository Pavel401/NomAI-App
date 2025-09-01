
import 'dart:convert';

ErrorModel errorModelFromJson(String str) =>
    ErrorModel.fromJson(json.decode(str));

String errorModelToJson(ErrorModel data) => json.encode(data.toJson());

class ErrorModel {
  final bool? success;
  final String? errorCode;
  final String? errorType;
  final String? message;
  final String? severity;
  final int? statusCode;
  final Metadata? metadata;

  ErrorModel({
    this.success,
    this.errorCode,
    this.errorType,
    this.message,
    this.severity,
    this.statusCode,
    this.metadata,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
        success: json["success"],
        errorCode: json["error_code"],
        errorType: json["error_type"],
        message: json["message"],
        severity: json["severity"],
        statusCode: json["status_code"],
        metadata: json["metadata"] == null
            ? null
            : Metadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "error_code": errorCode,
        "error_type": errorType,
        "message": message,
        "severity": severity,
        "status_code": statusCode,
        "metadata": metadata?.toJson(),
      };
}

class Metadata {
  final DateTime? timestamp;
  final String? requestId;
  final String? endpoint;
  final String? method;
  final String? userAgent;
  final String? ipAddress;
  final double? executionTimeSeconds;

  Metadata({
    this.timestamp,
    this.requestId,
    this.endpoint,
    this.method,
    this.userAgent,
    this.ipAddress,
    this.executionTimeSeconds,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
        requestId: json["request_id"],
        endpoint: json["endpoint"],
        method: json["method"],
        userAgent: json["user_agent"],
        ipAddress: json["ip_address"],
        executionTimeSeconds: json["execution_time_seconds"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "timestamp": timestamp?.toIso8601String(),
        "request_id": requestId,
        "endpoint": endpoint,
        "method": method,
        "user_agent": userAgent,
        "ip_address": ipAddress,
        "execution_time_seconds": executionTimeSeconds,
      };
}
