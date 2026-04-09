import 'package:flutter/material.dart';

class SplashContentWidget extends StatelessWidget {
  const SplashContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: 'shrimp-logo',
          child: Image.asset("assets/logo.png", width: 120, height: 120),
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
    );
  }
}
