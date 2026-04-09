import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../repositories/sensor_history_repository.dart';

class SensorHistoryController extends ChangeNotifier {
  final SensorHistoryRepository _repository = SensorHistoryRepository();

  int selectedSensorIndex = 0;
  String selectedTimeRange = '1H';
  bool useMockData = true;
  bool isLoading = true;

  final List<String> sensorLabels = ['อุณหภูมิ', 'pH', 'TDS', 'ความขุ่น', 'WQI'];
  final List<String> timeRangeOptions = ['1H', '1D', '7D'];

  final Map<String, Map<String, double>> sensorRanges = {
    'อุณหภูมิ': {'min': 20, 'max': 36},
    'pH': {'min': 5.5, 'max': 9},
    'TDS': {'min': 100, 'max': 450},
    'ความขุ่น': {'min': 0, 'max': 40},
    'WQI': {'min': 0, 'max': 100},
  };

  Map<String, List<FlSpot>> chartData = {
    'อุณหภูมิ': [],
    'pH': [],
    'TDS': [],
    'ความขุ่น': [],
    'WQI': [],
  };
  List<Map<String, dynamic>> rawData = [];
  DateTime? lastDataTimestamp;

  SensorHistoryController() {
    fetchData();
  }

  void setSensorIndex(int index) {
    selectedSensorIndex = index;
    notifyListeners();
  }

  void setTimeRange(String range) {
    if (selectedTimeRange != range) {
      selectedTimeRange = range;
      notifyListeners();
      fetchData();
    }
  }

  void setMockDataMode(bool value) {
    useMockData = value;
    notifyListeners();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    if (useMockData) {
      _generateMockData();
    } else {
      await _fetchRealData();
    }
  }

  void _generateMockData() {
    int dataPoints;
    switch (selectedTimeRange) {
      case '1D':
        dataPoints = 24 * 4;
        break; // 15-min intervals
      case '7D':
        dataPoints = 7 * 24;
        break; // 1-hour intervals
      case '1H':
      default:
        dataPoints = 60;
        break;
    }

    final random = math.Random();

    List<FlSpot> generateSeries(
        double min, double max, double startPhase, double variance) {
      final List<FlSpot> spots = [];
      final mid = (max + min) / 2;
      final amplitude = (max - min) / 2 * 0.7; // 70% of max range
      for (int i = 0; i < dataPoints; i++) {
        double val = mid +
            amplitude * math.sin(startPhase + i * 0.1) +
            variance * (random.nextDouble() - 0.5);
        spots.add(FlSpot(i.toDouble(), val.clamp(min, max)));
      }
      return spots;
    }

    final tempData = generateSeries(
        sensorRanges['อุณหภูมิ']!['min']!, sensorRanges['อุณหภูมิ']!['max']!, 0, 1.0);
    final phData = generateSeries(
        sensorRanges['pH']!['min']!, sensorRanges['pH']!['max']!, 2, 0.2);
    final tdsData = generateSeries(
        sensorRanges['TDS']!['min']!, sensorRanges['TDS']!['max']!, 1, 10.0);
    final turbidityData = generateSeries(sensorRanges['ความขุ่น']!['min']!,
        sensorRanges['ความขุ่น']!['max']!, 3, 2.0);
    final wqiData = generateSeries(
        sensorRanges['WQI']!['min']!, sensorRanges['WQI']!['max']!, 4, 3.0);

    final now = DateTime.now();
    DateTime startTime;
    Duration interval;
    if (selectedTimeRange == '1H') {
      startTime = now.subtract(const Duration(hours: 1));
      interval = const Duration(minutes: 1);
    } else if (selectedTimeRange == '1D') {
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

    lastDataTimestamp = DateTime.now();
    chartData = {
      'อุณหภูมิ': tempData,
      'pH': phData,
      'TDS': tdsData,
      'ความขุ่น': turbidityData,
      'WQI': wqiData,
    };
    rawData = mockRaw;
    
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 600), () {
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchRealData() async {
    try {
      final now = DateTime.now();
      DateTime startTime;

      switch (selectedTimeRange) {
        case '7D':
          startTime = now.subtract(const Duration(days: 7));
          break;
        case '1D':
          startTime = now.subtract(const Duration(days: 1));
          break;
        case '1H':
        default:
          startTime = now.subtract(const Duration(hours: 1));
          break;
      }

      final fetchedRawData = await _repository.fetchHistoricalData(startTime);

      if (fetchedRawData.isNotEmpty) {
        lastDataTimestamp = DateTime.parse(fetchedRawData.last['created_at']);
      } else {
        lastDataTimestamp = DateTime.now();
      }

      final List<FlSpot> tempData = [];
      final List<FlSpot> phData = [];
      final List<FlSpot> tdsData = [];
      final List<FlSpot> turbidityData = [];
      final List<FlSpot> wqiData = [];

      int samplingFactor;
      if (fetchedRawData.isEmpty) {
        samplingFactor = 1;
      } else {
        switch (selectedTimeRange) {
          case '7D':
            samplingFactor = (fetchedRawData.length / 168).round();
            break;
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

          final tempRange = sensorRanges['อุณหภูมิ']!;
          final phRange = sensorRanges['pH']!;
          final tdsRange = sensorRanges['TDS']!;
          final turbidityRange = sensorRanges['ความขุ่น']!;
          final wqiRange = sensorRanges['WQI']!;

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
              turbidityValue.clamp(turbidityRange['min']!, turbidityRange['max']!)));

          final wqiValue = (row['wqi'] as num?)?.toDouble() ?? 0;
          wqiData.add(
              FlSpot(iDouble, wqiValue.clamp(wqiRange['min']!, wqiRange['max']!)));

          sampledIndex++;
        }
      }

      chartData = {
        'อุณหภูมิ': tempData,
        'pH': phData,
        'TDS': tdsData,
        'ความขุ่น': turbidityData,
        'WQI': wqiData,
      };
      rawData = fetchedRawData;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('Error fetching data: $e');
    }
  }
}
