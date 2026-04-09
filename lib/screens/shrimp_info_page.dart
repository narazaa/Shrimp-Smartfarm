import 'package:flutter/material.dart';
import '../controllers/shrimp_info_controller.dart';
import '../widgets/key_fact_card.dart';
import '../widgets/info_section_card.dart';

class ShrimpInfoPage extends StatelessWidget {
  const ShrimpInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ShrimpInfoController();
    final keyFacts = controller.getKeyFacts();
    final infoSections = controller.getInfoSections();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
                  children: keyFacts
                      .map((fact) => Expanded(child: KeyFactCard(fact: fact)))
                      .toList(),
                ),
                const SizedBox(height: 24),
                ...infoSections.map(
                  (section) => InfoSectionCard(section: section),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
