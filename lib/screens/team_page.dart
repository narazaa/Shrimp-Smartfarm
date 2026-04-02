import 'package:flutter/material.dart';

// Data Model สำหรับสมาชิกแต่ละคน
class TeamMember {
  final String imagePath;
  final String name;
  final String studentId;
  final String role;

  TeamMember({
    required this.imagePath,
    required this.name,
    required this.studentId,
    required this.role,
  });
}

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ข้อมูลสมาชิกในทีม (คุณสามารถแก้ไขตรงนี้ได้เลย)
    final List<TeamMember> members = [
      TeamMember(
        imagePath: 'assets/avartar1.jpg', // รูป Avatar ของคนที่ 1
        name: 'นายนารา ปองรักษ์',
        studentId: '66543206048-1',
        role: '',
      ),
      TeamMember(
        imagePath: 'assets/avartar2.jpeg', // รูป Avatar ของคนที่ 2
        name: 'นางสาววิลาสิณี  พรมมา',
        studentId: ' 66543206087-9',
        role: '',
      ),
      TeamMember(
        imagePath: 'assets/avartar3.png', // รูป Avatar ของคนที่ 3
        name: 'นายบุญพัฒน์	 สมเพชร',
        studentId: '66543206046-5',
        role: '',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            backgroundColor: const Color(0xFF2C3E50),
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'ทีมผู้จัดทำ',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    // *** อย่าลืมเพิ่มรูปภาพ team_bg.jpg ใน assets นะครับ ***
                    image: const AssetImage('assets/team_bg.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // สร้าง List ของการ์ดสมาชิก
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _TeamMemberCard(member: members[index]);
              }, childCount: members.length),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget สำหรับสร้างการ์ดสมาชิกแต่ละคน
class _TeamMemberCard extends StatelessWidget {
  final TeamMember member;

  const _TeamMemberCard({required this.member});

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
                // *** อย่าลืมเพิ่มรูป avatar1.png, avatar2.png, avatar3.png ใน assets ***
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
          ],
        ),
      ),
    );
  }
}
