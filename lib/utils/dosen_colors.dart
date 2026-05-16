import 'package:flutter/material.dart';

const List<Color> _kPalette = [
  Color(0xFF1976D2),
  Color(0xFF7B1FA2),
  Color(0xFF2E7D32),
  Color(0xFFC62828),
  Color(0xFF00838F),
  Color(0xFFBF360C),
  Color(0xFF00695C),
  Color(0xFFF9A825),
];

Color dosenAvatarColor(String name) =>
    _kPalette[name.codeUnitAt(0) % _kPalette.length];
