// File: control_page.dart (ฉบับสมบูรณ์ - แก้ไขสีไอคอนปุ่มสั่งงาน)

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'sensor_overview_page.dart';
import '../services/data_service.dart';

enum CardType { toggle, actionButton }

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  int _selectedPondIndex = 0;
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
    super.dispose();
  }

  void _onPondSelected(int index) {
    setState(() {
      _selectedPondIndex = index;
    });
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

  void _showPondSelector(BuildContext context) {
    final ponds = ['บ่อกุ้งที่ 1', 'บ่อกุ้งที่ 2'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'เลือกบ่อ',
                style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 22,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ...List.generate(ponds.length, (index) {
                final isSelected = index == _selectedPondIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      _onPondSelected(index);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1D2A3A) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ponds[index],
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isSelected ? 1.0 : 0.0,
                            child: const Icon(Icons.check_circle, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPond1Selected = _selectedPondIndex == 0;

    final Widget pond1Control = _ControlContent(
      key: const ValueKey('pond1_control'),
      dataService: DataService.instance,
    );

    final Widget pond2Control = _ControlContent(
      key: const ValueKey('pond2_control'),
      firebasePathPrefix: 'V2',
    );

    const Widget sensorOverviewPage = SensorOverviewContent();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FA),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _Header(
              selectedTabIndex: _selectedTabIndex,
              selectedPondIndex: _selectedPondIndex,
              onPondSelectPressed: () => _showPondSelector(context),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onTabChangedInView,
              children: [
                Stack(
                  children: [
                    Visibility(
                      maintainState: true,
                      visible: isPond1Selected,
                      child: pond1Control,
                    ),
                    Visibility(
                      maintainState: true,
                      visible: !isPond1Selected,
                      child: pond2Control,
                    ),
                  ],
                ),
                sensorOverviewPage,
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

class _Header extends StatelessWidget {
  final int selectedTabIndex;
  final int selectedPondIndex;
  final VoidCallback onPondSelectPressed;

  const _Header({
    required this.selectedTabIndex,
    required this.selectedPondIndex,
    required this.onPondSelectPressed,
  });

  @override
  Widget build(BuildContext context) {
    final title = selectedTabIndex == 0 ? 'ควบคุมระบบ' : 'ภาพรวมเซ็นเซอร์';
    final pondLabel = 'บ่อกุ้งที่ ${selectedPondIndex + 1}';

    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Text(
                  title,
                  key: ValueKey<String>(title),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Kanit'),
                ),
              ),
              Text(
                pondLabel,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.black54, size: 28),
              tooltip: 'เลือกบ่อ',
              onPressed: onPondSelectPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlContent extends StatefulWidget {
  final DataService? dataService;
  final String firebasePathPrefix;

  const _ControlContent({
    super.key,
    this.dataService,
    this.firebasePathPrefix = '',
  });

  @override
  State<_ControlContent> createState() => _ControlContentState();
}

class _ControlContentState extends State<_ControlContent> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.dataService != null) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: widget.dataService!.sensors,
                builder: (context, sensorData, child) {
                  return Rectangle1(sensorData: sensorData);
                },
              ),
              const SizedBox(height: 24.0),
              ControlGrid(dataService: widget.dataService!),
            ],
          ),
        ),
      );
    }

    final db = FirebaseDatabase.instance.ref();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            StreamBuilder(
              stream: db.child('sensors${widget.firebasePathPrefix}').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.exists) {
                  final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                  final normalizedData = Map<String, dynamic>.from(data);
                  if (normalizedData.containsKey('pH')) {
                    normalizedData['pH'] = normalizedData.remove('pH');
                  }

                  return Rectangle1(sensorData: normalizedData);
                }
                return const Rectangle1(sensorData: {});
              },
            ),
            const SizedBox(height: 24.0),
            ControlGrid(firebasePathPrefix: widget.firebasePathPrefix),
          ],
        ),
      ),
    );
  }
}

class CustomToggleTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomToggleTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['ควบคุมระบบ', 'ภาพรวมเซ็นเซอร์'];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: 4 + (selectedIndex * tabWidth),
                top: 4,
                child: Container(
                  width: tabWidth,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2AFFF9), Color(0xFF79D5AC)],
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (index) {
                  final isSelected = selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTabSelected(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.black : Colors.black54,
                            ),
                            child: Text(labels[index]),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Rectangle1 extends StatelessWidget {
  final Map<String, dynamic> sensorData;

  const Rectangle1({super.key, required this.sensorData});

  @override
  Widget build(BuildContext context) {
    List<String> icons = ['assets/thermometer.png', 'assets/ph2.png', 'assets/tds.png', 'assets/washing-liquid.png'];
    List<String> titles = ["อุณหภูมิ", "pH", "TDS", "ความขุ่นน้ำ"];
    List<String> values = [
      "${sensorData['temperature'] ?? 'N/A'}°C",
      "${sensorData['pH'] ?? 'N/A'}",
      "${sensorData['tds'] ?? 'N/A'} ppm",
      "${sensorData['turbidity'] ?? 'N/A'} NTU"
    ];
    const double spacing = 15.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2AFFF9), Color(0xFF79D5AC)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Color(0x3F000000), blurRadius: 6, offset: Offset(3, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: AspectRatio(aspectRatio: 1.8, child: SensorTile(imagePath: icons[0], title: titles[0], value: values[0]))),
              const SizedBox(width: spacing),
              Expanded(child: AspectRatio(aspectRatio: 1.8, child: SensorTile(imagePath: icons[1], title: titles[1], value: values[1]))),
            ],
          ),
          const SizedBox(height: spacing),
          Row(
            children: [
              Expanded(child: AspectRatio(aspectRatio: 1.8, child: SensorTile(imagePath: icons[2], title: titles[2], value: values[2]))),
              const SizedBox(width: spacing),
              Expanded(child: AspectRatio(aspectRatio: 1.8, child: SensorTile(imagePath: icons[3], title: titles[3], value: values[3]))),
            ],
          ),
        ],
      ),
    );
  }
}

class SensorTile extends StatelessWidget {
  final String imagePath, title, value;

  const SensorTile({super.key, required this.imagePath, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white30),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Kanit', fontSize: 14, color: Color(0xFF2C3E50)), overflow: TextOverflow.ellipsis),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A), fontFamily: 'Kanit'),
                    overflow: TextOverflow.ellipsis,
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

class ControlGrid extends StatefulWidget {
  final DataService? dataService;
  final String firebasePathPrefix;

  const ControlGrid({super.key, this.dataService, this.firebasePathPrefix = ''});

  @override
  State<ControlGrid> createState() => _ControlGridState();
}

class _ControlGridState extends State<ControlGrid> {
  final List<String> names = ["ออกซิเจน", "หลอดไฟ", "ให้อาหาร", "กรองน้ำ"];
  final List<String> locations = ["เปิดออกซิเจนให้กุ้ง", "เปิดไฟบ่อกุ้ง", "กดเพื่อให้อาหาร", "กรองน้ำบ่อกุ้ง"];
  final List<IconData> icons = [Icons.bubble_chart_outlined, Icons.lightbulb_outline, Icons.restaurant_menu, Icons.water_drop_outlined];

  bool _isFeeding = false;

  @override
  Widget build(BuildContext context) {
    if (widget.dataService != null) {
      return ValueListenableBuilder(
        valueListenable: widget.dataService!.relay,
        builder: (context, relayData, child) {
          return ValueListenableBuilder(
            valueListenable: widget.dataService!.settings,
            builder: (context, settingsData, child) {
              return _buildGridView(context, relayData, settingsData);
            },
          );
        },
      );
    }

    final db = FirebaseDatabase.instance.ref();
    return StreamBuilder(
      stream: db.child('relay${widget.firebasePathPrefix}').onValue,
      builder: (context, relaySnapshot) {
        return StreamBuilder(
          stream: db.child('settings${widget.firebasePathPrefix}').onValue,
          builder: (context, settingsSnapshot) {
            final relayData = relaySnapshot.hasData && relaySnapshot.data!.snapshot.exists
                ? Map<String, dynamic>.from(relaySnapshot.data!.snapshot.value as Map)
                : <String, dynamic>{};
            final settingsData = settingsSnapshot.hasData && settingsSnapshot.data!.snapshot.exists
                ? Map<String, dynamic>.from(settingsSnapshot.data!.snapshot.value as Map)
                : <String, dynamic>{};

            return _buildGridView(context, relayData, settingsData);
          },
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, Map<String, dynamic> relayData, Map<String, dynamic> settingsData) {
    final status = [
      relayData['Oxy'] as bool? ?? false,
      relayData['Lamp'] as bool? ?? false,
      relayData['Feed'] as bool? ?? false,
      relayData['Pump1'] as bool? ?? false,
    ];

    final lampSettings = settingsData['lamp'] as Map?;
    final lampMode = lampSettings?['mode'] as String? ?? 'manual';

    final feedSettings = settingsData['feed'] as Map?;
    final feedMode = feedSettings?['mode'] as String? ?? 'manual';
    final feedTime = feedSettings?['time'] as String?;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: names.length,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 225,
      ),
      itemBuilder: (context, index) {
        String locationText = locations[index];
        if (index == 1) {
          bool isLampAuto = lampMode == 'auto';
          bool showSettings = isLampAuto;
          if (showSettings && lampSettings != null && lampSettings['startTime'] != null && lampSettings['endTime'] != null) {
            locationText = 'เวลา: ${lampSettings['startTime']} - ${lampSettings['endTime']} น.';
          } else {
            locationText = 'ควบคุมด้วยตนเอง';
          }
          bool displayStatus = isLampAuto ? true : status[index];
          return ToggleCard(
            title: names[index],
            location: locationText,
            icon: icons[index],
            isOn: displayStatus,
            onChanged: (value) => _onValueChanged(index, value),
            isModeSelectorVisible: true,
            mode: lampMode,
            onModeChanged: (newMode) => _updateLampMode(newMode),
            showSettingsButton: showSettings,
            onSettingsPressed: () => _showLampTimeRangePicker(context),
          );
        }

        if (index == 2) {
          bool isFeedAuto = feedMode == 'auto';
          bool showSettings = isFeedAuto;
          if (showSettings && feedTime != null) {
            locationText = 'เวลา: $feedTime น.';
          } else {
            locationText = 'กดเพื่อให้อาหาร';
          }
          bool displayStatus = isFeedAuto ? true : status[index];
          return ToggleCard(
            title: names[index],
            location: locationText,
            icon: icons[index],
            isOn: displayStatus,
            onChanged: (value) => _onValueChanged(index, value),
            isModeSelectorVisible: true,
            mode: feedMode,
            onModeChanged: (newMode) => _updateFeedMode(newMode),
            showSettingsButton: showSettings,
            onSettingsPressed: () => _showFeedTimePicker(context),
            cardType: CardType.actionButton,
            onActionPressed: _isFeeding ? null : () => _triggerFeed(context),
            isLoading: _isFeeding,
          );
        }

        return ToggleCard(
          title: names[index],
          location: locationText,
          icon: icons[index],
          isOn: status[index],
          onChanged: (value) => _onValueChanged(index, value),
        );
      },
    );
  }

  void _triggerFeed(BuildContext context) async {
    setState(() { _isFeeding = true; });

    if (widget.dataService != null) {
      widget.dataService!.updateRelay('Feed', true);
    } else {
      FirebaseDatabase.instance.ref('relay${widget.firebasePathPrefix}/Feed').set(true);
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('กำลังให้อาหาร...'),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 4),
    ));

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() { _isFeeding = false; });
    }
  }

  void _onValueChanged(int index, bool value) {
    if (widget.dataService != null) {
      String relayKey;
      switch (index) {
        case 0: relayKey = 'Oxy'; break;
        case 1: relayKey = 'Lamp'; break;
        case 2: relayKey = 'Feed'; break;
        case 3: relayKey = 'Pump1'; break;
        default: return;
      }
      widget.dataService!.updateRelay(relayKey, value);
      return;
    }
    String relayKey;
    switch (index) {
      case 0: relayKey = 'Oxy'; break;
      case 1: relayKey = 'Lamp'; break;
      case 2: relayKey = 'Feed'; break;
      case 3: relayKey = 'Pump1'; break;
      default: return;
    }
    FirebaseDatabase.instance.ref('relay${widget.firebasePathPrefix}/$relayKey').set(value);
  }

  void _updateLampMode(String newMode) {
    if (widget.dataService != null) {
      widget.dataService!.updateLampMode(newMode);
      return;
    }
    FirebaseDatabase.instance.ref('settings${widget.firebasePathPrefix}/lamp').update({'mode': newMode});
  }

  void _updateFeedMode(String newMode) {
    if (widget.dataService != null) {
      widget.dataService!.updateFeedMode(newMode);
      return;
    }
    FirebaseDatabase.instance.ref('settings${widget.firebasePathPrefix}/feed').update({'mode': newMode});
  }

  Future<void> _showFeedTimePicker(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now(), helpText: 'ตั้งเวลาให้อาหาร');
    if (pickedTime != null && context.mounted) {
      final String formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      if (widget.dataService != null) {
        widget.dataService!.updateFeedTime(formattedTime);
      } else {
        FirebaseDatabase.instance.ref('settings${widget.firebasePathPrefix}/feed').set({'time': formattedTime, 'mode': 'auto'});
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('บันทึกเวลาให้อาหารเป็น $formattedTime เรียบร้อยแล้ว'), backgroundColor: Colors.green));
    }
  }

  Future<void> _showLampTimeRangePicker(BuildContext context) async {
    final TimeOfDay? startTime = await showTimePicker(context: context, initialTime: TimeOfDay.now(), helpText: 'เลือกเวลาเปิดไฟ');
    if (startTime == null || !context.mounted) return;

    final TimeOfDay? endTime = await showTimePicker(context: context, initialTime: TimeOfDay(hour: (startTime.hour + 8) % 24, minute: startTime.minute), helpText: 'เลือกเวลาปิดไฟ');
    if (endTime != null && context.mounted) {
      final String formattedStartTime = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      final String formattedEndTime = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      if (widget.dataService != null) {
        widget.dataService!.updateLampTime(startTime: formattedStartTime, endTime: formattedEndTime);
      } else {
        FirebaseDatabase.instance.ref('settings${widget.firebasePathPrefix}/lamp').set({'startTime': formattedStartTime, 'endTime': formattedEndTime, 'mode': 'auto'});
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ตั้งเวลาเปิด-ปิดไฟเป็น $formattedStartTime - $formattedEndTime'), backgroundColor: Colors.green));
    }
  }
}

class ToggleCard extends StatelessWidget {
  final String title, location;
  final IconData icon;
  final bool isOn;
  final ValueChanged<bool> onChanged;
  final bool showSettingsButton;
  final VoidCallback? onSettingsPressed;
  final bool isModeSelectorVisible;
  final String? mode;
  final ValueChanged<String>? onModeChanged;
  final CardType cardType;
  final VoidCallback? onActionPressed;
  final bool isLoading;

  const ToggleCard({
    super.key,
    required this.title,
    required this.location,
    required this.icon,
    required this.isOn,
    required this.onChanged,
    this.showSettingsButton = false,
    this.onSettingsPressed,
    this.isModeSelectorVisible = false,
    this.mode,
    this.onModeChanged,
    this.cardType = CardType.toggle,
    this.onActionPressed,
    this.isLoading = false,
  });

  Widget _buildModeButton(BuildContext context, {
    required String buttonMode,
    required bool isDarkMode,
  }) {
    final bool isSelected = mode == buttonMode;

    Color bgColor = Colors.transparent;
    Color textColor = isDarkMode ? Colors.white70 : Colors.black54;
    Color borderColor = isDarkMode ? Colors.white38 : Colors.grey.shade400;

    if (isSelected) {
      bgColor = isDarkMode ? Colors.white : Colors.black87;
      textColor = isDarkMode ? Colors.black87 : Colors.white;
      borderColor = isDarkMode ? Colors.white : Colors.black87;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged?.call(buttonMode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                buttonMode.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const animationDuration = Duration(milliseconds: 400);

    final bool isAutoMode = mode == 'auto';
    final bool isManualOn = !isAutoMode && isOn;

    Color textColor;
    Color subTextColor;
    Color iconColor;
    BoxDecoration decoration;

    if (isAutoMode) {
      textColor = Colors.white.withOpacity(0.9);
      subTextColor = Colors.white.withOpacity(0.7);
      iconColor =
      isOn ? const Color(0xFF2AFFF9) : Colors.white.withOpacity(0.7);

      decoration = BoxDecoration(
        color: const Color(0xFF1D2A3A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(4, 4),
          )
        ],
      );
    } else {
      textColor = const Color(0xFF0D1B2A);
      subTextColor = const Color(0xFF2C3E50);

      // ✅ [แก้ไข] ทำให้ไอคอนของปุ่มสั่งงานเป็นสีเขียวเสมอ
      if (cardType == CardType.actionButton) {
        iconColor = Colors.greenAccent;
      } else {
        iconColor = isManualOn ? Colors.greenAccent : Colors.grey.shade600;
      }

      decoration = BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, 4)),
          ]
      );
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      decoration: decoration,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: animationDuration,
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(icon,
                          key: ValueKey<String>(iconColor.toString()),
                          size: 30,
                          color: iconColor),
                    ),
                    Visibility(
                      visible: showSettingsButton,
                      maintainState: true,
                      maintainAnimation: true,
                      maintainSize: true,
                      child: IconButton(
                        icon: Icon(
                            Icons.settings_outlined, color: subTextColor),
                        onPressed: onSettingsPressed,
                        tooltip: 'ตั้งเวลา',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit',
                            color: textColor))),
                FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(location,
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Kanit',
                            color: subTextColor))),
                const Spacer(),
                Visibility(
                  visible: isModeSelectorVisible,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildModeButton(context, buttonMode: 'manual',
                              isDarkMode: isAutoMode),
                          const SizedBox(width: 8),
                          _buildModeButton(context, buttonMode: 'auto',
                              isDarkMode: isAutoMode),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                if (!isAutoMode)
                  cardType == CardType.toggle
                      ? _buildSwitchControl(textColor)
                      : _buildActionControl(context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchControl(Color textColor) {
    return Row(
      children: [
        Expanded(
          child: Text(isOn ? 'On' : 'Off',
              style: TextStyle(
                  color: textColor,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold)),
        ),
        Switch(
          value: isOn,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.greenAccent,
          inactiveThumbColor: Colors.grey.shade300,
          inactiveTrackColor: Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildActionControl(BuildContext context) {
    final cardBackgroundColor = isOn ? Colors.white : const Color(0xFFE0E0E0);

    return GestureDetector(
      onTap: isLoading ? null : onActionPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isLoading
              ? null // No shadow when pressed/loading
              : [
            //เงาเข้มด้านล่างขวา
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            //เงาสว่างด้านบนซ้าย
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.cyan.shade700,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ให้อาหาร',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}