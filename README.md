# 🦐 สมาร์ทฟาร์มกุ้งฝอย (Shrimp Smartfarm)

แอปพลิเคชันบนมือถือสำหรับการติดตามและจัดการฟาร์มกุ้งฝอยอัจฉริยะ (Smartfarm) พัฒนาด้วย **Flutter** โดยมุ่งเน้นที่การแสดงผลข้อมูลสภาพแวดล้อมภายในฟาร์มแบบเรียลไทม์ และมี UI/UX ที่ใช้งานง่าย สวยงาม และทันสมัย

## ✨ ฟีเจอร์หลัก (Key Features)

- **หน้าปัดแดชบอร์ด (Dashboard)**: สรุปข้อมูลสำคัญต่าง ๆ เช่น อุณหภูมิ, ค่า pH, และระดับน้ำแบบเรียลไทม์
- **กราฟแสดงสถิติ (Analytics Charts)**: แสดงแนวโน้มสถานะของบ่อกุ้ง เพื่อการวิเคราะห์ที่แม่นยำยิ่งขึ้น
- **ฐานข้อมูลและคลาวด์ (Backend & Database)**: เชื่อมต่อเชื่อมโยงข้อมูลกับ **Supabase** และ Firebase
- **ข้อมูลพันธุ์กุ้ง (Shrimp Info)**: แหล่งความรู้เพิ่มเติมเกี่ยวกับกุ้งฝอย
- **สถาปัตยกรรมแบบ Clean Architecture**: แบ่งแยกหน้าที่การทำงานอย่างชัดเจนเพื่อการดูแลรักษาที่ง่ายต่อยอด (Maintainability)

## 🛠️ โครงสร้างสถาปัตยกรรม (Project Architecture)

โปรเจกต์นี้ได้รับการออกแบบโดยใช้หลักการแยกส่วน (Layered Architecture) เพื่อให้โค้ดเป็นระเบียบและอ่านง่าย:
- `lib/models/`: จัดการโครงสร้างของข้อมูล (Data Models)
- `lib/controllers/`: จัดการลอจิกหรือการทำงานของแอป (Business Logic/State Management)
- `lib/screens/`: จัดการหน้า UI หลักของแอป
- `lib/widgets/`: แหล่งรวม UI component ย่อย ๆ ที่สามารถนำไปใช้ซ้ำได้ (Reusable Components)
- `lib/services/`: จัดการกับการติดต่อสื่อสารภายนอก เช่น APIs, Supabase หรือ Firebase
- `lib/repositories/`: ชั้นของ Repository สำหรับจัดการแหล่งที่มาของข้อมูล
- `lib/utils/`: ฟังก์ชันเครื่องมือหรือตัวแปรค่าคงที่ เช่น RouteObserver 

## 📦 เทคโนโลยีที่ใช้งาน (Tech Stack)

- **Framework**: Flutter (^3.7.2 SDK)
- **Backend**: Supabase (`supabase_flutter`), Firebase (`firebase_core`, `firebase_database`)
- **Charts**: `fl_chart`
- **Environment**: `flutter_dotenv` (ซ่อน API Key อย่างปลอดภัยด้วยไฟล์ `.env`)
- **Fonts & UX**: พัฒนาอินเทอร์เฟซด้วยฟอนต์ Kanit

## 🚀 การติดตั้งและเริ่มใช้งาน (Getting Started)

1. **โคลนโปรเจกต์ (Clone the repository)**
   ```bash
   git clone <repository_url>
   cd shrimpsmart_project
   ```

2. **ติดตั้ง Dependencies**
   ```bash
   flutter pub get
   ```

3. **ตั้งค่า Environment Variables**
   - ให้สร้างไฟล์ `.env` ไว้ที่โฟลเดอร์ root ของโปรเจกต์ (ระดับเดียวกับ pubspec.yaml)
   - เพิ่มตัวแปรที่จำเป็นจาก Supabase เช่น:
     ```env
     SUPABASE_URL=your_supabase_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **รันทดสอบบนอุปกรณ์หรืออีมูเลเตอร์**
   ```bash
   flutter run
   ```

## 🤝 การพัฒนาและปรับปรุงเพิ่มเติม
- โครงการนี้มีการใช้ `flutter_lints` เพื่อกวดขันรูปแบบของโค้ดให้มีมาตรฐาน 
- ห้าม Commit ไฟล์ `.env` ขึ้น Repository เด็ดขาด เพื่อความปลอดภัยของข้อมูล

---

*โปรเจกต์นี้เริ่มต้นจาก Flutter template และได้รับการต่อยอดเพื่อจัดการสมาร์ทฟาร์มโดยเฉพาะ หากต้องการเรียนรู้เพิ่มเติมเกี่ยวกับ Flutter สามารถดูได้ที่ [Online Documentation](https://docs.flutter.dev/)*
