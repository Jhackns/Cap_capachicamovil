import 'package:flutter/material.dart';

class IconUtils {
  static IconData getIconData(String iconCode) {
    switch (iconCode.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'free_breakfast':
        return Icons.free_breakfast;
      case 'tour':
        return Icons.tour;
      case 'pets':
        return Icons.pets;
      default:
        return Icons.error; // Fallback icon for unrecognized codes
    }
  }
}