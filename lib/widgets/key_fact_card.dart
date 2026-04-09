import 'package:flutter/material.dart';
import '../models/shrimp_info.dart';

class KeyFactCard extends StatelessWidget {
  final KeyFact fact;

  const KeyFactCard({super.key, required this.fact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF79D5AC).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(fact.icon, color: const Color(0xFF79D5AC), size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            fact.value,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fact.label,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
