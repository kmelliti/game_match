import 'dart:ui';

import 'package:flutter/material.dart';

const presets = [
  Color(0xFFEF5350),
  Color(0xFFEC407A),
  Color(0xFFAB47BC),
  Color(0xFF7E57C2),
  Color(0xFF5C6BC0),
  Color(0xFF42A5F5),
  Color(0xFF26C6DA),
  Color(0xFF26A69A),
  Color(0xFF66BB6A),
  Color(0xFFFFCA28),
  Color(0xFFFFA726),
  Color(0xFFFF7043),
  Color(0xFF8D6E63),
  Color(0xFF78909C),
  Color(0xFF212121),
];

class GameConfig {
  final List<Color?> gridConfiguration;
  final List<PlayGroundItems?> playGround;
  final List<Color> suggestions;

  GameConfig({required this.playGround, required this.gridConfiguration, required this.suggestions});

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      playGround: List<PlayGroundItems>.from(json['playGround'].map((x) => PlayGroundItems.fromJson(x))),
      gridConfiguration: List<Color>.from(json['gridConfiguration'].map((x) => hexToColor(x))),
      suggestions: List<Color>.from(json['suggestions'].map((x) => hexToColor(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    'playGround': List<dynamic>.from(playGround.map((x) => x?.toJson())),
    'gridConfiguration': List<String?>.from(gridConfiguration.map((x) => colorToHex(x))),
    'suggestions': List<String?>.from(suggestions.map((x) => colorToHex(x))),
  };
}

String? colorToHex(Color? color) => color == null ? null : '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

Color? hexToColor(String? hexString) => hexString == null ? null : Color(int.parse(hexString.replaceFirst('#', '0x')));

class PlayGroundItems {
  final String id;

  final Color? colorHint;

  final Color? targetColor;

  PlayGroundItems({required this.id, required this.colorHint, this.targetColor});

  factory PlayGroundItems.fromJson(Map<String, dynamic> json) => PlayGroundItems(
    id: json["id"],
    colorHint: json["colorHint"] == null ? null : hexToColor(json["colorHint"]),
    targetColor: json["targetColor"] == null ? null : hexToColor(json["targetColor"]),
  );

  Map<String, dynamic> toJson() => {"id": id, "colorHint": colorToHex(colorHint), "targetColor": colorToHex(targetColor)};
}
