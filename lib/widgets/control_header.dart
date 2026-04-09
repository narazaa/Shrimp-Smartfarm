import 'package:flutter/material.dart';
import '../controllers/control_controller.dart';

class ControlHeader extends StatelessWidget {
  final int selectedTabIndex;
  final ControlController controller;

  const ControlHeader({
    super.key,
    required this.selectedTabIndex,
    required this.controller,
  });

  void _showPondSelector(BuildContext context) {
    final ponds = ['บ่อกุ้งที่ 1', 'บ่อกุ้งที่ 2'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
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
                    final isSelected = index == controller.currentPondIndex;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          controller.selectPond(index);
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
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = selectedTabIndex == 0 ? 'ควบคุมระบบ' : 'ภาพรวมเซ็นเซอร์';
    
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
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final pondLabel = 'บ่อกุ้งที่ ${controller.currentPondIndex + 1}';
              return Column(
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
              );
            }
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.black54, size: 28),
              tooltip: 'เลือกบ่อ',
              onPressed: () => _showPondSelector(context),
            ),
          ),
        ],
      ),
    );
  }
}
