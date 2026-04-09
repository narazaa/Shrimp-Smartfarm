import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/main_menu_screen.dart';

class SplashController {
  Future<void> initializeApp(BuildContext context) async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Allow the splash animation to render for 1.5 seconds.
    await Future.delayed(const Duration(milliseconds: 1500));

    if (context.mounted) {
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
}
