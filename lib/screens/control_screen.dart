import 'package:flutter/material.dart';
import '../controllers/control_controller.dart';
import '../widgets/control_header.dart';
import '../widgets/custom_toggle_tab_bar.dart';
import '../widgets/sensor_grid_widget.dart';
import '../widgets/control_panel_widget.dart';
import 'sensor_overview_page.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final ControlController _controller = ControlController();
  int _selectedTabIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTabChangedInView(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _onTabChangedInBar(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FA),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: ControlHeader(
              selectedTabIndex: _selectedTabIndex,
              controller: _controller,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onTabChangedInView,
              children: [
                _ControlContent(controller: _controller),
                const SensorOverviewContent(),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: CustomToggleTabBar(
              selectedIndex: _selectedTabIndex,
              onTabSelected: _onTabChangedInBar,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlContent extends StatefulWidget {
  final ControlController controller;

  const _ControlContent({required this.controller});

  @override
  State<_ControlContent> createState() => _ControlContentState();
}

class _ControlContentState extends State<_ControlContent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return StreamBuilder<Map<String, dynamic>>(
          stream: widget.controller.sensorsStream,
          builder: (context, sensorSnapshot) {
            return StreamBuilder<Map<String, dynamic>>(
              stream: widget.controller.relayStream,
              builder: (context, relaySnapshot) {
                return StreamBuilder<Map<String, dynamic>>(
                  stream: widget.controller.settingsStream,
                  builder: (context, settingsSnapshot) {
                    final sensorData = sensorSnapshot.data ?? {};
                    final relayData = relaySnapshot.data ?? {};
                    final settingsData = settingsSnapshot.data ?? {};

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16.0),
                            SensorGridWidget(sensorData: sensorData),
                            const SizedBox(height: 24.0),
                            ControlPanelWidget(
                              controller: widget.controller,
                              relayData: relayData,
                              settingsData: settingsData,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      }
    );
  }
}
