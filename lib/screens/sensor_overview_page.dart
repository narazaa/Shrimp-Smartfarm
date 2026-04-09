import 'package:flutter/material.dart';
import '../controllers/sensor_history_controller.dart';
import '../widgets/sensor_history_filter_widget.dart';
import '../widgets/sensor_history_chart_widget.dart';

class SensorOverviewContent extends StatefulWidget {
  const SensorOverviewContent({super.key});

  @override
  State<SensorOverviewContent> createState() => _SensorOverviewContentState();
}

class _SensorOverviewContentState extends State<SensorOverviewContent> {
  late final SensorHistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SensorHistoryController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Column(
              children: [
                const SizedBox(height: 16),
                SensorHistoryFilterWidget(controller: _controller),
                const SizedBox(height: 48),
                SensorHistoryChartWidget(controller: _controller),
              ],
            );
          },
        ),
      ),
    );
  }
}