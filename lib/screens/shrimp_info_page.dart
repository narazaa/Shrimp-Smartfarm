// File: shrimp_info_page.dart (เข้ากับธีมแอป)

import 'package:flutter/material.dart';

// --- Data Models ---
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

class ShrimpInfoPage extends StatelessWidget {
  const ShrimpInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- ข้อมูลสำหรับแสดงผล ---
    final List<KeyFact> keyFacts = [
      KeyFact(icon: Icons.straighten, value: '3-5 cm', label: 'ขนาด'),
      KeyFact(icon: Icons.autorenew, value: '~1 ปี', label: 'วงจรชีวิต'),
      KeyFact(icon: Icons.waves, value: 'น้ำจืด', label: 'ประเภท'),
    ];

    final List<InfoSectionData> infoSections = [
      InfoSectionData(
        icon: Icons.info_outline,
        title: 'กุ้งฝอยคืออะไร?',
        content:
            'กุ้งฝอย หรือ Macrobrachium lanchesteri คือ กุ้งน้ำจืดขนาดเล็กที่เปรียบเสมือน "อัญมณีแห่งสายน้ำ" ของไทย เป็นได้ทั้งแหล่งอาหารโปรตีนสำคัญและเป็นดัชนีชี้วัดความอุดมสมบูรณ์ของระบบนิเวศ',
      ),
      InfoSectionData(
        icon: Icons.visibility,
        title: 'ลักษณะทางกายภาพ',
        content:
            'มีลำตัวใสจนมองเห็นอวัยวะภายใน อาจมีสีแตกต่างกันไปตามแหล่งที่อยู่อาศัยและอาหารที่กิน มีกรี (หนามแหลมที่หัว) ยาวและชี้ตรง',
      ),
      InfoSectionData(
        icon: Icons.home_work_outlined,
        title: 'ถิ่นที่อยู่และพฤติกรรม',
        content:
            'อาศัยอยู่ตามแหล่งน้ำนิ่งหรือไหลเอื่อยๆ เช่น คลอง, บึง, และนาข้าว ชอบหลบซ่อนตามพืชน้ำในเวลากลางวัน และจะออกมาหากินในเวลากลางคืน',
      ),
      InfoSectionData(
        icon: Icons.restaurant_menu_outlined,
        title: 'อาหาร',
        content:
            'กินทั้งพืชและสัตว์ขนาดเล็กเป็นอาหาร (Omnivore) เช่น ตะไคร่น้ำ, สาหร่าย, ไรแดง, ตัวอ่อนของแมลง, รวมไปถึงซากพืชซากสัตว์ที่เน่าเปื่อย',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- SliverAppBar ---
          SliverAppBar(
            backgroundColor: const Color(0xFFF6F9FA),
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'เรื่องน่ารู้กุ้งฝอย',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),

          // --- ส่วนของเนื้อหา ---
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ✅ ส่วนสรุปข้อมูลสำคัญ (Key Facts)
                const Text(
                  'ข้อมูลสำคัญ',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      keyFacts
                          .map(
                            (fact) => Expanded(child: _KeyFactCard(fact: fact)),
                          )
                          .toList(),
                ),
                const SizedBox(height: 24),

                // ✅ ส่วนเนื้อหารายละเอียด
                ...infoSections.map(
                  (section) => _ContentSection(section: section),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Widget สำหรับแสดง Key Fact แต่ละอัน
class _KeyFactCard extends StatelessWidget {
  final KeyFact fact;
  const _KeyFactCard({required this.fact});

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
            color: Colors.black.withValues(alpha: 0.05),
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
              color: const Color(0xFF79D5AC).withValues(alpha: 0.2),
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

// ✅ Widget สำหรับแสดงเนื้อหาแต่ละหัวข้อ
class _ContentSection extends StatelessWidget {
  final InfoSectionData section;
  const _ContentSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2AFFF9), Color(0xFF79D5AC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(section.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.content,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
