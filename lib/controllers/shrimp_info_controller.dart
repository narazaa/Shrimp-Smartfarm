import 'package:flutter/material.dart';
import '../models/shrimp_info.dart';

class ShrimpInfoController {
  List<KeyFact> getKeyFacts() {
    return [
      KeyFact(icon: Icons.straighten, value: '3-5 cm', label: 'ขนาด'),
      KeyFact(icon: Icons.autorenew, value: '~1 ปี', label: 'วงจรชีวิต'),
      KeyFact(icon: Icons.waves, value: 'น้ำจืด', label: 'ประเภท'),
    ];
  }

  List<InfoSectionData> getInfoSections() {
    return [
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
  }
}
