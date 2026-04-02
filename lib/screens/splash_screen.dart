import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // ✅ แก้ไข: รอให้การโหลดข้อมูลเสร็จสิ้นเพียงอย่างเดียว
    await DataService.instance.initialize();

    // เมื่อข้อมูลพร้อมแล้ว ก็ไปหน้าถัดไปได้เลย
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (context, animation, secondaryAnimation) =>
          const GradientBackgroundScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Align(alignment: Alignment.center, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ส่วน UI ของหน้านี้เหมือนเดิม
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2AFFF9), Color(0xFF79D5AC)],
            stops: [0.0, 0.24],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'shrimp-logo',
                child: Image.asset(
                  "assets/logo.png",
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 24),
              Hero(
                tag: 'app-title',
                child: const Material(
                  color: Colors.transparent,
                  child: Text(
                    'สมาร์ทฟาร์มกุ้งฝอย',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 6,
                          color: Color(0x99000000),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}