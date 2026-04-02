// File: data_service.dart (ฉบับอัปเดตแกไขตามคำแนะนำ)

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class DataService {
  DataService._privateConstructor();
  static final DataService instance = DataService._privateConstructor();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  final ValueNotifier<Map<String, dynamic>> sensors = ValueNotifier({});
  final ValueNotifier<Map<String, dynamic>> relay = ValueNotifier({});
  final ValueNotifier<Map<String, dynamic>> settings = ValueNotifier({});

  StreamSubscription? _sensorSub;
  StreamSubscription? _relaySub;
  StreamSubscription? _settingsSub;

  Future<void> initialize() async {
    try {
      final initialSensor = await _db.child('sensors').get();
      if (initialSensor.exists && initialSensor.value is Map) {
        sensors.value = Map<String, dynamic>.from(initialSensor.value as Map);
      }
      
      final initialRelay = await _db.child('relay').get();
      if (initialRelay.exists && initialRelay.value is Map) {
        relay.value = Map<String, dynamic>.from(initialRelay.value as Map);
      }
      
      final initialSettings = await _db.child('settings').get();
      if (initialSettings.exists && initialSettings.value is Map) {
        settings.value = Map<String, dynamic>.from(initialSettings.value as Map);
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
    }
    
    _listenForUpdates();
  }

  void _listenForUpdates() {
    _sensorSub?.cancel();
    _relaySub?.cancel();
    _settingsSub?.cancel();

    _sensorSub = _db.child('sensors').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        try {
          sensors.value = Map<String, dynamic>.from(event.snapshot.value as Map);
        } catch (e) {
          debugPrint('Error parsing sensors data: $e');
        }
      }
    }, onError: (error) {
      debugPrint('Error listening to sensors: $error');
    });

    _relaySub = _db.child('relay').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        try {
          relay.value = Map<String, dynamic>.from(event.snapshot.value as Map);
        } catch (e) {
          debugPrint('Error parsing relay data: $e');
        }
      }
    }, onError: (error) {
      debugPrint('Error listening to relay: $error');
    });

    _settingsSub = _db.child('settings').onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        try {
          settings.value = Map<String, dynamic>.from(event.snapshot.value as Map);
        } catch (e) {
          debugPrint('Error parsing settings data: $e');
        }
      }
    }, onError: (error) {
      debugPrint('Error listening to settings: $error');
    });
  }

  void updateRelay(String key, bool isOn) {
    try {
      _db.child('relay').child(key).set(isOn);
    } catch (e) {
      debugPrint('Error updating relay: $e');
    }
  }

  void updateFeedTime(String time) {
    try {
      _db.child('settings').child('feed').update({
        'time': time,
        'mode': 'auto',
      });
    } catch (e) {
      debugPrint('Error updating feed time: $e');
    }
  }

  void updateFeedMode(String mode) {
    try {
      _db.child('settings').child('feed').update({'mode': mode});
    } catch (e) {
      debugPrint('Error updating feed mode: $e');
    }
  }

  void updateLampTime({required String startTime, required String endTime}) {
    try {
      _db.child('settings').child('lamp').update({
        'startTime': startTime,
        'endTime': endTime,
        'mode': 'auto',
      });
    } catch (e) {
      debugPrint('Error updating lamp time: $e');
    }
  }

  void updateLampMode(String mode) {
    try {
      _db.child('settings').child('lamp').update({'mode': mode});
    } catch (e) {
      debugPrint('Error updating lamp mode: $e');
    }
  }

  void dispose() {
    _sensorSub?.cancel();
    _relaySub?.cancel();
    _settingsSub?.cancel();
    
    // สำคัญ: ป้องกัน Memory leak
    sensors.dispose();
    relay.dispose();
    settings.dispose();
  }
}
