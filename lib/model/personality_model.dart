import 'package:flutter/material.dart';

class PersonalityModel {
  final String id;
  final String kategori;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> characteristic;
  final String deskripsi;

  PersonalityModel({
    required this.id,
    required this.kategori,
    required this.strengths,
    required this.weaknesses,
    required this.characteristic,
    required this.deskripsi,
  });

  // Helper method to get color based on personality type
  static Color getTypeColor(String personalityType) {
    switch (personalityType) {
      case 'Realistic':
        return Colors.blue.shade700;
      case 'Investigative':
        return Colors.teal.shade700;
      case 'Artistic':
        return Colors.purple.shade700;
      case 'Social':
        return Colors.orange.shade700;
      case 'Enterprising':
        return Colors.red.shade700;
      case 'Conventional':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // Helper method to get icon based on personality type
  static IconData getTypeIcon(String personalityType) {
    switch (personalityType) {
      case 'Realistic':
        return Icons.build;
      case 'Investigative':
        return Icons.science;
      case 'Artistic':
        return Icons.palette;
      case 'Social':
        return Icons.people;
      case 'Enterprising':
        return Icons.emoji_people;
      case 'Conventional':
        return Icons.calendar_today;
      default:
        return Icons.help_outline;
    }
  }
}
