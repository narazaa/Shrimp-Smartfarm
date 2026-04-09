import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/route_observer.dart';
import '../controllers/main_menu_controller.dart';
import '../widgets/menu_bottom_sheet.dart';

class GradientBackgroundScreen extends StatefulWidget {
  const GradientBackgroundScreen({super.key});

  @override
  _GradientBackgroundScreenState createState() =>
      _GradientBackgroundScreenState();
}

class _GradientBackgroundScreenState extends State<GradientBackgroundScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final MainMenuController _menuController = MainMenuController();

  @override
  void initState() {
    super.initState();
    _setStatusBar();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _setStatusBar();
  }

  void _setStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2AFFF9), Color(0xFF79D5AC)],
                stops: [0.0, 0.24],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.11,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Hero(
                  tag: 'shrimp-logo',
                  child: Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/logo.png"),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Hero(
                  tag: 'app-title',
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: screenWidth * 0.7,
                      child: const Text(
                        'สมาร์ทฟาร์มกุ้งฝอย',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFFF9F9),
                          fontSize: 28,
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
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: MenuBottomSheet(controller: _menuController),
            ),
          ),
        ],
      ),
    );
  }
}
