import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/sensor_history_controller.dart';

class SensorHistoryChartWidget extends StatelessWidget {
  final SensorHistoryController controller;

  const SensorHistoryChartWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const SizedBox(
        height: 300,
        child: Padding(
          padding: EdgeInsets.only(right: 24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (controller.chartData.values.every((list) => list.isEmpty)) {
      return const SizedBox(
        height: 300,
        child: Padding(
          padding: EdgeInsets.only(right: 24.0),
          child: Center(child: Text('ไม่พบข้อมูล')),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: LineChart(_buildChartData()),
      ),
    );
  }

  LineChartData _buildChartData() {
    final selectedLabel = controller.sensorLabels[controller.selectedSensorIndex];
    final chartData = controller.chartData[selectedLabel] ?? [];
    final minY = controller.sensorRanges[selectedLabel]!['min']!;
    final maxY = controller.sensorRanges[selectedLabel]!['max']!;

    double yInterval;
    String Function(double) yLabelFormatter;

    if (selectedLabel == 'อุณหภูมิ') {
      yInterval = 2;
      yLabelFormatter = (value) => '${value.toStringAsFixed(1)}°';
    } else if (selectedLabel == 'pH') {
      yInterval = 0.5;
      yLabelFormatter = (value) {
        if (value == value.toInt().toDouble()) {
          return '${value.toInt()}';
        }
        return value.toStringAsFixed(1);
      };
    } else if (selectedLabel == 'TDS') {
      yInterval = 50;
      yLabelFormatter = (value) => '${value.toInt()}';
    } else if (selectedLabel == 'ความขุ่น') {
      yInterval = 5;
      yLabelFormatter = (value) => '${value.toInt()}';
    } else if (selectedLabel == 'WQI') {
      yInterval = 20;
      yLabelFormatter = (value) => '${value.toInt()}';
    } else {
      yInterval = ((maxY - minY) / 5).roundToDouble();
      if (yInterval < 1) yInterval = 1;
      yLabelFormatter = (value) => '${value.toInt()}';
    }

    double bottomTitleInterval;
    final double maxVal = chartData.isNotEmpty ? (chartData.length - 1).toDouble() : 1.0;
    
    if (maxVal == 0) {
      bottomTitleInterval = 1;
    } else {
      switch (controller.selectedTimeRange) {
        case '1H':
          bottomTitleInterval = (10.0 / 60.0) * maxVal;
          break;
        case '1D':
          bottomTitleInterval = (240.0 / 1440.0) * maxVal;
          break;
        case '7D':
        default:
          bottomTitleInterval = (1440.0 / 10080.0) * maxVal;
          break;
      }
    }
    if (bottomTitleInterval < 1) bottomTitleInterval = 1;

    return LineChartData(
      lineTouchData: LineTouchData(
        longPressDuration: Duration.zero,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final referenceTime = DateTime.now();
              double totalMinutes;
              switch (controller.selectedTimeRange) {
                case '1D':
                  totalMinutes = 1440;
                  break;
                case '7D':
                  totalMinutes = 10080;
                  break;
                default:
                  totalMinutes = 60;
                  break;
              }

              final maxIndex = chartData.length > 1 ? chartData.length - 1 : 1;
              final double percentFromEnd = (maxIndex - barSpot.x) / maxIndex;
              final minutesAgo = (percentFromEnd * totalMinutes).toInt();

              final labelTime =
                  referenceTime.subtract(Duration(minutes: minutesAgo));

              String timeText;
              if (controller.selectedTimeRange == '7D' ||
                  controller.selectedTimeRange == '1D') {
                timeText = DateFormat('d/M HH:mm').format(labelTime);
              } else {
                timeText = DateFormat('HH:mm').format(labelTime);
              }

              String yValueText;
              if (selectedLabel == 'pH') {
                yValueText = barSpot.y.toStringAsFixed(2);
              } else {
                yValueText = barSpot.y.toStringAsFixed(1);
              }

              final tooltipText = '$yValueText\n$timeText น.';

              return LineTooltipItem(
                tooltipText,
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kanit',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              );
            }).toList();
          },
        ),
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              const FlLine(
                color: Colors.blueGrey,
                strokeWidth: 1,
                dashArray: [3, 3],
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF79D5AC),
                  );
                },
              ),
            );
          }).toList();
        },
      ),
      maxX: chartData.isNotEmpty ? (chartData.length - 1).toDouble() : null,
      minY: minY,
      maxY: maxY + (yInterval * 0.2),
      clipData: const FlClipData(
        top: true,
        bottom: false,
        left: false,
        right: false,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: yInterval,
        getDrawingHorizontalLine: (value) =>
            const FlLine(color: Color(0xFFE8EBEB), strokeWidth: 1),
        checkToShowHorizontalLine: (value) => true,
      ),
      titlesData: FlTitlesData(
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: yInterval,
            getTitlesWidget: (value, meta) {
              if (value > maxY) {
                return const Text('');
              }
              return Text(
                yLabelFormatter(value),
                style: const TextStyle(color: Colors.black54, fontSize: 10),
                textAlign: TextAlign.left,
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            interval: bottomTitleInterval,
            getTitlesWidget: (value, meta) {
              if (value > meta.max || meta.max == 0) {
                return Container();
              }

              final referenceTime = DateTime.now();
              double totalMinutes;
              switch (controller.selectedTimeRange) {
                case '1D':
                  totalMinutes = 1440;
                  break;
                case '7D':
                  totalMinutes = 10080;
                  break;
                default:
                  totalMinutes = 60;
                  break;
              }

              final double percentFromEnd = (meta.max - value) / meta.max;
              final minutesAgo = (percentFromEnd * totalMinutes).toInt();
              final labelTime =
                  referenceTime.subtract(Duration(minutes: minutesAgo));

              String timeText;
              String dateText;

              if (controller.selectedTimeRange == '7D') {
                timeText = DateFormat.E('th_TH').format(labelTime);
                dateText = DateFormat('d/M').format(labelTime);
              } else {
                timeText = DateFormat('HH:mm').format(labelTime);
                dateText = DateFormat('d/M').format(labelTime);
              }

              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Column(
                  children: [
                    Text(timeText,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(dateText,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 9)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: chartData,
          isCurved: true,
          gradient: const LinearGradient(
              colors: [Color(0xFF2AFFF9), Color(0xFF79D5AC)]),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2AFFF9).withOpacity(0.3),
                const Color(0xFF79D5AC).withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
