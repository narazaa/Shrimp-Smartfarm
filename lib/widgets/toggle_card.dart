import 'package:flutter/material.dart';

enum CardType { toggle, actionButton }

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
                      ? _buildSwitchControl(textColor, isManualOn)
                      : _buildActionControl(context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchControl(Color textColor, bool isManualOn) {
    return Row(
      children: [
        Expanded(
          child: Text(isManualOn ? 'On' : 'Off',
              style: TextStyle(
                  color: textColor,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold)),
        ),
        Switch(
          value: isManualOn,
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
              ? null
              : [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
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
            children: const [
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
