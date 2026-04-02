import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

// Initialize Supabase client
final supabase = Supabase.instance.client;

class SensorOverviewContent extends StatefulWidget {
  const SensorOverviewContent({super.key});

  @override
  State<SensorOverviewContent> createState() => _SensorOverviewContentState();
}

class _SensorOverviewContentState extends State<SensorOverviewContent> {
  int _selectedSensorIndex = 0;
  String _selectedTimeRange = '1H';
  bool _useMockData = true; // เปิดใช้งาน Mock Data เป็นค่าเริ่มต้น

  // [MODIFIED] Added 'WQI' to the list of sensor labels.
  final List<String> _sensorLabels = ['อุณหภูมิ', 'pH', 'TDS', 'ความขุ่น', 'WQI'];
  final List<String> _timeRange = ['1H', '1D', '7D'];

  Map<String, List<FlSpot>> _chartData = {};
  List<Map<String, dynamic>> _rawData = [];
  bool _isLoading = true;
  DateTime? _lastDataTimestamp;

  // [MODIFIED] Added ranges for the new 'WQI' sensor.
  final Map<String, Map<String, double>> _sensorRanges = {
    'อุณหภูมิ': {'min': 20, 'max': 36},
    'pH': {'min': 5.5, 'max': 9},
    'TDS': {'min': 100, 'max': 450},
    'ความขุ่น': {'min': 0, 'max': 40},
    'WQI': {'min': 0, 'max': 100},
  };

  @override
  void initState() {
    super.initState();
    _fetchDataForRange(_selectedTimeRange);
  }

  void _generateMockData(String range) {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    int dataPoints;
    switch (range) {
      case '1H': dataPoints = 60; break;
      case '1D': dataPoints = 24 * 4; break; // 15-min intervals
      case '7D': dataPoints = 7 * 24; break; // 1-hour intervals
      default: dataPoints = 60; break;
    }

    final random = math.Random();
    
    List<FlSpot> generateSeries(double min, double max, double startPhase, double variance) {
      final List<FlSpot> spots = [];
      final mid = (max + min) / 2;
      final amplitude = (max - min) / 2 * 0.7; // 70% of available range
      for (int i = 0; i < dataPoints; i++) {
        // Create a wave that drifts over time plus some random noise
        double val = mid + amplitude * math.sin(startPhase + i * 0.1) + variance * (random.nextDouble() - 0.5);
        spots.add(FlSpot(i.toDouble(), val.clamp(min, max)));
      }
      return spots;
    }

    final tempData = generateSeries(_sensorRanges['อุณหภูมิ']!['min']!, _sensorRanges['อุณหภูมิ']!['max']!, 0, 1.0);
    final phData = generateSeries(_sensorRanges['pH']!['min']!, _sensorRanges['pH']!['max']!, 2, 0.2);
    final tdsData = generateSeries(_sensorRanges['TDS']!['min']!, _sensorRanges['TDS']!['max']!, 1, 10.0);
    final turbidityData = generateSeries(_sensorRanges['ความขุ่น']!['min']!, _sensorRanges['ความขุ่น']!['max']!, 3, 2.0);
    final wqiData = generateSeries(_sensorRanges['WQI']!['min']!, _sensorRanges['WQI']!['max']!, 4, 3.0);

    // mock raw data timestamp calculation based on selection
    final now = DateTime.now();
    DateTime startTime;
    Duration interval;
    if (range == '1H') {
      startTime = now.subtract(const Duration(hours: 1));
      interval = const Duration(minutes: 1);
    } else if (range == '1D') {
      startTime = now.subtract(const Duration(days: 1));
      interval = const Duration(minutes: 15);
    } else {
      startTime = now.subtract(const Duration(days: 7));
      interval = const Duration(hours: 1);
    }
    
    List<Map<String, dynamic>> mockRaw = [];
    for (int i = 0; i < dataPoints; i++) {
        mockRaw.add({
          'created_at': startTime.add(interval * i).toIso8601String(),
          'temperature': tempData[i].y,
          'ph': phData[i].y,
          'tds': tdsData[i].y,
          'turbidity': turbidityData[i].y,
          'wqi': wqiData[i].y,
        });
    }

    _lastDataTimestamp = DateTime.now();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _chartData = {
            'อุณหภูมิ': tempData,
            'pH': phData,
            'TDS': tdsData,
            'ความขุ่น': turbidityData,
            'WQI': wqiData,
          };
          _rawData = mockRaw;
          _isLoading = false;
        });
      }
    });
  }

  /// Handles fetching and processing data specifically for the 7-day range.
  Future<void> _fetch7DData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 7));

      final response = await supabase
          .from('pond_data')
          .select()
          .gte('created_at', startTime.toIso8601String())
          .order('created_at', ascending: true);

      final fetchedRawData = List<Map<String, dynamic>>.from(response as List);

      if (fetchedRawData.isNotEmpty) {
        _lastDataTimestamp = DateTime.parse(fetchedRawData.last['created_at']);
      } else {
        _lastDataTimestamp = DateTime.now();
      }

      final List<FlSpot> tempData = [];
      final List<FlSpot> phData = [];
      final List<FlSpot> tdsData = [];
      final List<FlSpot> turbidityData = [];
      // [ADDED] List to hold WQI data points.
      final List<FlSpot> wqiData = [];

      int samplingFactor = (fetchedRawData.length / 168).round();
      if (samplingFactor < 1) samplingFactor = 1;

      int sampledIndex = 0;
      for (int i = 0; i < fetchedRawData.length; i++) {
        if (i % samplingFactor == 0) {
          final row = fetchedRawData[i];
          final iDouble = sampledIndex.toDouble();

          final tempRange = _sensorRanges['อุณหภูมิ']!;
          final phRange = _sensorRanges['pH']!;
          final tdsRange = _sensorRanges['TDS']!;
          final turbidityRange = _sensorRanges['ความขุ่น']!;
          // [ADDED] Get the defined range for WQI.
          final wqiRange = _sensorRanges['WQI']!;

          // ** FIX: Removed conditional checks to ensure all lists have the same length. **
          // The .clamp() function handles zero/null values by setting them to the minimum valid range.
          final tempValue = (row['temperature'] as num?)?.toDouble() ?? 0;
          tempData.add(FlSpot(
              iDouble, tempValue.clamp(tempRange['min']!, tempRange['max']!)));

          final phValue = (row['ph'] as num?)?.toDouble() ?? 0;
          phData.add(
              FlSpot(iDouble, phValue.clamp(phRange['min']!, phRange['max']!)));

          final tdsValue = (row['tds'] as num?)?.toDouble() ?? 0;
          tdsData.add(
              FlSpot(iDouble, tdsValue.clamp(tdsRange['min']!, tdsRange['max']!)));

          final turbidityValue = (row['turbidity'] as num?)?.toDouble() ?? 0;
          turbidityData.add(FlSpot(iDouble,
              turbidityValue.clamp(
                  turbidityRange['min']!, turbidityRange['max']!)));

          // [ADDED] Process and add WQI data.
          final wqiValue = (row['wqi'] as num?)?.toDouble() ?? 0;
          wqiData.add(
              FlSpot(iDouble, wqiValue.clamp(wqiRange['min']!, wqiRange['max']!)));

          sampledIndex++;
        }
      }

      if (mounted) {
        setState(() {
          _chartData = {
            'อุณหภูมิ': tempData,
            'pH': phData,
            'TDS': tdsData,
            'ความขุ่น': turbidityData,
            // [ADDED] Add the WQI data to the chart map.
            'WQI': wqiData,
          };
          _rawData = fetchedRawData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error fetching 7D data: $e');
    }
  }

  /// Main data fetching function. Delegates to [_fetch7DData] for the 7D case.
  Future<void> _fetchDataForRange(String range) async {
    if (_useMockData) {
      _generateMockData(range);
      return;
    }

    if (range == '7D') {
      await _fetch7DData();
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    DateTime startTime;
    switch (range) {
      case '1D':
        startTime = now.subtract(const Duration(days: 1));
        break;
      case '1H':
      default:
        startTime = now.subtract(const Duration(hours: 1));
        break;
    }

    try {
      final response = await supabase
          .from('pond_data')
          .select()
          .gte('created_at', startTime.toIso8601String())
          .order('created_at', ascending: true);

      final fetchedRawData = List<Map<String, dynamic>>.from(response as List);

      if (fetchedRawData.isNotEmpty) {
        _lastDataTimestamp = DateTime.parse(fetchedRawData.last['created_at']);
      } else {
        _lastDataTimestamp = DateTime.now();
      }

      final List<FlSpot> tempData = [];
      final List<FlSpot> phData = [];
      final List<FlSpot> tdsData = [];
      final List<FlSpot> turbidityData = [];
      // [ADDED] List to hold WQI data points.
      final List<FlSpot> wqiData = [];

      int samplingFactor;
      if (fetchedRawData.isEmpty) {
        samplingFactor = 1;
      } else {
        switch (range) {
          case '1D':
            samplingFactor = (fetchedRawData.length / 96).round();
            break;
          case '1H':
          default:
            samplingFactor = (fetchedRawData.length / 30).round();
            break;
        }
      }
      if (samplingFactor < 1) samplingFactor = 1;

      int sampledIndex = 0;
      for (int i = 0; i < fetchedRawData.length; i++) {
        if (i % samplingFactor == 0) {
          final row = fetchedRawData[i];
          final iDouble = sampledIndex.toDouble();

          final tempRange = _sensorRanges['อุณหภูมิ']!;
          final phRange = _sensorRanges['pH']!;
          final tdsRange = _sensorRanges['TDS']!;
          final turbidityRange = _sensorRanges['ความขุ่น']!;
          // [ADDED] Get the defined range for WQI.
          final wqiRange = _sensorRanges['WQI']!;

          // ** FIX: Removed conditional checks to ensure all lists have the same length. **
          final tempValue = (row['temperature'] as num?)?.toDouble() ?? 0;
          tempData.add(FlSpot(
              iDouble, tempValue.clamp(tempRange['min']!, tempRange['max']!)));

          final phValue = (row['ph'] as num?)?.toDouble() ?? 0;
          phData.add(
              FlSpot(iDouble, phValue.clamp(phRange['min']!, phRange['max']!)));

          final tdsValue = (row['tds'] as num?)?.toDouble() ?? 0;
          tdsData.add(
              FlSpot(iDouble, tdsValue.clamp(tdsRange['min']!, tdsRange['max']!)));

          final turbidityValue = (row['turbidity'] as num?)?.toDouble() ?? 0;
          turbidityData.add(FlSpot(iDouble,
              turbidityValue.clamp(
                  turbidityRange['min']!, turbidityRange['max']!)));

          // [ADDED] Process and add WQI data.
          final wqiValue = (row['wqi'] as num?)?.toDouble() ?? 0;
          wqiData.add(
              FlSpot(iDouble, wqiValue.clamp(wqiRange['min']!, wqiRange['max']!)));

          sampledIndex++;
        }
      }

      if (mounted) {
        setState(() {
          _chartData = {
            'อุณหภูมิ': tempData,
            'pH': phData,
            'TDS': tdsData,
            'ความขุ่น': turbidityData,
            // [ADDED] Add the WQI data to the chart map.
            'WQI': wqiData,
          };
          _rawData = fetchedRawData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSensorSelectionChips(),
            const SizedBox(height: 24),
            _buildTimeDropdown(),
            const SizedBox(height: 48),
            _buildChartContainer(),
          ],
        ),
      ),
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
        children: List.generate(_sensorLabels.length, (index) {
          final isSelected = _selectedSensorIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSensorIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color:
                  isSelected ? Colors.black87 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _sensorLabels[index],
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
              value: _useMockData,
              onChanged: (val) {
                setState(() => _useMockData = val);
                _fetchDataForRange(_selectedTimeRange);
              },
              activeColor: const Color(0xFF79D5AC),
            ),
            const Text('Mock Data', style: TextStyle(fontFamily: 'Kanit', color: Colors.black87, fontSize: 14)),
          ],
        ),
        MenuAnchor(
          style: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            elevation: MaterialStateProperty.all(8.0),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          builder: (context, controller, child) {
            return TextButton(
              onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedTimeRange,
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
            _timeRange.length,
                (int index) => MenuItemButton(
              onPressed: () {
                if (_selectedTimeRange != _timeRange[index]) {
                  setState(() => _selectedTimeRange = _timeRange[index]);
                  _fetchDataForRange(_timeRange[index]);
                }
              },
              child: Text(_timeRange[index],
                  style: const TextStyle(fontFamily: 'Kanit')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartContainer() {
    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_chartData.values.every((list) => list.isEmpty)
            ? const Center(child: Text('ไม่พบข้อมูล'))
            : LineChart(_buildChartData())),
      ),
    );
  }

  LineChartData _buildChartData() {
    final selectedLabel = _sensorLabels[_selectedSensorIndex];
    final chartData = _chartData[selectedLabel] ?? [];
    final minY = _sensorRanges[selectedLabel]!['min']!;
    final maxY = _sensorRanges[selectedLabel]!['max']!;

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
      // [ADDED] Specific axis configuration for the WQI chart.
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
      switch (_selectedTimeRange) {
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
              switch (_selectedTimeRange) {
                case '1D': totalMinutes = 1440; break;
                case '7D': totalMinutes = 10080; break;
                default: totalMinutes = 60; break;
              }

              final maxIndex = chartData.length > 1 ? chartData.length - 1 : 1;
              final double percentFromEnd = (maxIndex - barSpot.x) / maxIndex;
              final minutesAgo = (percentFromEnd * totalMinutes).toInt();

              final labelTime = referenceTime.subtract(Duration(minutes: minutesAgo));

              String timeText;
              if (_selectedTimeRange == '7D' || _selectedTimeRange == '1D') {
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
              switch (_selectedTimeRange) {
                case '1D': totalMinutes = 1440; break;
                case '7D': totalMinutes = 10080; break;
                default: totalMinutes = 60; break;
              }

              final double percentFromEnd = (meta.max - value) / meta.max;
              final minutesAgo = (percentFromEnd * totalMinutes).toInt();
              final labelTime = referenceTime.subtract(Duration(minutes: minutesAgo));

              String timeText;
              String dateText;

              if (_selectedTimeRange == '7D') {
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
                        style:
                        const TextStyle(color: Colors.black54, fontSize: 9)),
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