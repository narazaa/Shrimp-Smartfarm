import 'package:flutter/material.dart';
import '../controllers/control_controller.dart';
import 'toggle_card.dart';

class ControlPanelWidget extends StatelessWidget {
  final ControlController controller;
  final Map<String, dynamic> relayData;
  final Map<String, dynamic> settingsData;

  const ControlPanelWidget({
    super.key,
    required this.controller,
    required this.relayData,
    required this.settingsData,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> names = ["ออกซิเจน", "หลอดไฟ", "ให้อาหาร", "กรองน้ำ"];
    final List<String> locations = ["เปิดออกซิเจนให้กุ้ง", "เปิดไฟบ่อกุ้ง", "กดเพื่อให้อาหาร", "กรองน้ำบ่อกุ้ง"];
    final List<IconData> icons = [Icons.bubble_chart_outlined, Icons.lightbulb_outline, Icons.restaurant_menu, Icons.water_drop_outlined];

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
        if (index == 1) { // Lamp
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
            onModeChanged: (newMode) => controller.updateLampMode(newMode),
            showSettingsButton: showSettings,
            onSettingsPressed: () => _showLampTimeRangePicker(context),
          );
        }

        if (index == 2) { // Feed
          bool isFeedAuto = feedMode == 'auto';
          bool showSettings = isFeedAuto;
          if (showSettings && feedTime != null) {
            locationText = 'เวลา: $feedTime น.';
          } else {
            locationText = 'กดเพื่อให้อาหาร';
          }
          bool displayStatus = isFeedAuto ? true : status[index];
          return ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return ToggleCard(
                title: names[index],
                location: locationText,
                icon: icons[index],
                isOn: displayStatus,
                onChanged: (value) => _onValueChanged(index, value),
                isModeSelectorVisible: true,
                mode: feedMode,
                onModeChanged: (newMode) => controller.updateFeedMode(newMode),
                showSettingsButton: showSettings,
                onSettingsPressed: () => _showFeedTimePicker(context),
                cardType: CardType.actionButton,
                onActionPressed: controller.isFeeding ? null : () => _triggerFeed(context),
                isLoading: controller.isFeeding,
              );
            }
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

  void _onValueChanged(int index, bool value) {
    String relayKey;
    switch (index) {
      case 0: relayKey = 'Oxy'; break;
      case 1: relayKey = 'Lamp'; break;
      case 2: relayKey = 'Feed'; break;
      case 3: relayKey = 'Pump1'; break;
      default: return;
    }
    controller.toggleRelay(relayKey, value);
  }

  void _triggerFeed(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('กำลังให้อาหาร...'),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 4),
    ));
    await controller.triggerFeed();
  }

  Future<void> _showFeedTimePicker(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now(), helpText: 'ตั้งเวลาให้อาหาร');
    if (pickedTime != null && context.mounted) {
      final String formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      await controller.updateFeedTime(formattedTime);
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
      await controller.updateLampTime(startTime: formattedStartTime, endTime: formattedEndTime);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ตั้งเวลาเปิด-ปิดไฟเป็น $formattedStartTime - $formattedEndTime'), backgroundColor: Colors.green));
    }
  }
}
