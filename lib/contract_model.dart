import 'dart:convert';

class ContractModel {
  final String name;
  final DateTime timestamp;
  final String signatureData; // base64 or file path

  ContractModel({
    required this.name,
    required this.timestamp,
    required this.signatureData,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'timestamp': timestamp.toIso8601String(),
    'signatureData': signatureData,
  };

  factory ContractModel.fromJson(Map<String, dynamic> json) => ContractModel(
    name: json['name'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    signatureData: json['signatureData'] as String,
  );

  String toJsonString() => jsonEncode(toJson());

  static ContractModel fromJsonString(String jsonString) =>
      ContractModel.fromJson(jsonDecode(jsonString));
}
