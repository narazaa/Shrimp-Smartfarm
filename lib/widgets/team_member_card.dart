import 'package:flutter/material.dart';
import '../models/team_member.dart';

class TeamMemberCard extends StatelessWidget {
  final TeamMember member;

  const TeamMemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF2AFFF9), Color(0xFF79D5AC)],
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(member.imagePath),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              member.name,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'รหัสนักศึกษา: ${member.studentId}',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (member.role.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                member.role,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
