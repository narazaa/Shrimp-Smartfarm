import 'package:flutter/material.dart';
import '../controllers/sensor_history_controller.dart';

class SensorHistoryFilterWidget extends StatelessWidget {
  final SensorHistoryController controller;

  const SensorHistoryFilterWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSensorSelectionChips(),
        const SizedBox(height: 24),
        _buildTimeDropdown(),
      ],
    );
  }

  Widget _buildSensorSelectionChips() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(controller.sensorLabels.length, (index) {
          final isSelected = controller.selectedSensorIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.setSensorIndex(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black87 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    controller.sensorLabels[index],
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Switch(
              value: controller.useMockData,
              onChanged: (val) => controller.setMockDataMode(val),
              activeColor: const Color(0xFF79D5AC),
            ),
            const Text('Mock Data',
                style: TextStyle(
                    fontFamily: 'Kanit', color: Colors.black87, fontSize: 14)),
          ],
        ),
        MenuAnchor(
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.all(8.0),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          builder: (context, menuController, child) {
            return TextButton(
              onPressed: () => menuController.isOpen
                  ? menuController.close()
                  : menuController.open(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.selectedTimeRange,
                    style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      color: Colors.black54, size: 20),
                ],
              ),
            );
          },
          menuChildren: List<MenuItemButton>.generate(
            controller.timeRangeOptions.length,
            (int index) => MenuItemButton(
              onPressed: () => controller.setTimeRange(controller.timeRangeOptions[index]),
              child: Text(controller.timeRangeOptions[index],
                  style: const TextStyle(fontFamily: 'Kanit')),
            ),
          ),
        ),
      ],
    );
  }
}
