import 'package:flutter/material.dart';
import 'sensor_tile.dart';

class SensorGridWidget extends StatelessWidget {
  final Map<String, dynamic> sensorData;

  const SensorGridWidget({super.key, required this.sensorData});

  @override
  Widget build(BuildContext context) {
    List<String> icons = [
      'assets/thermometer.png',
      'assets/ph2.png',
      'assets/tds.png',
      'assets/washing-liquid.png'
    ];
    List<String> titles = ["อุณหภูมิ", "pH", "TDS", "ความขุ่นน้ำ"];
    List<String> values = [
      "${sensorData['temperature'] ?? 'N/A'}°C",
      "${sensorData['ph'] ?? sensorData['pH'] ?? 'N/A'}",
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 6,
            offset: Offset(3, 3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.8,
                  child: SensorTile(
                      imagePath: icons[0], title: titles[0], value: values[0]),
                ),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.8,
                  child: SensorTile(
                      imagePath: icons[1], title: titles[1], value: values[1]),
                ),
              ),
            ],
          ),
          const SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.8,
                  child: SensorTile(
                      imagePath: icons[2], title: titles[2], value: values[2]),
                ),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.8,
                  child: SensorTile(
                      imagePath: icons[3], title: titles[3], value: values[3]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
