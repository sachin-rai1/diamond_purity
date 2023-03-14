

//     final diamondModel = diamondModelFromJson(jsonString);

import 'dart:convert';

DiamondModel diamondModelFromJson(String str) => DiamondModel.fromJson(json.decode(str));

String diamondModelToJson(DiamondModel data) => json.encode(data.toJson());

class DiamondModel {
  DiamondModel({
    required this.diamondModelClass,
    required this.confidence,
  });

  String diamondModelClass;
  double confidence;

  factory DiamondModel.fromJson(Map<String, dynamic> json) => DiamondModel(
    diamondModelClass: json["class"],
    confidence: json["confidence"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "class": diamondModelClass,
    "confidence": confidence,
  };
}
