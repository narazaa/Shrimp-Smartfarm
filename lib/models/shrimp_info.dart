import 'package:flutter/material.dart';

class KeyFact {
  final IconData icon;
  final String value;
  final String label;

  KeyFact({required this.icon, required this.value, required this.label});
}

class InfoSectionData {
  final IconData icon;
  final String title;
  final String content;

  InfoSectionData({
    required this.icon,
    required this.title,
    required this.content,
  });
}
