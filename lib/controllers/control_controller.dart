import 'package:flutter/material.dart';
import '../repositories/control_repository.dart';
import '../repositories/firebase_control_repository.dart';

class ControlController extends ChangeNotifier {
  final ControlRepository _repository;
  
  String _currentPondId = 'pond1';
  String get currentPondId => _currentPondId;

  int get currentPondIndex => _currentPondId == 'pond1' ? 0 : 1;
  
  bool _isFeeding = false;
  bool get isFeeding => _isFeeding;

  ControlController({ControlRepository? repository}) 
    : _repository = repository ?? FirebaseControlRepository();

  void selectPond(int index) {
    _currentPondId = index == 0 ? 'pond1' : 'pond2';
    notifyListeners();
  }

  Stream<Map<String, dynamic>> get sensorsStream => _repository.getSensorsStream(_currentPondId);
  Stream<Map<String, dynamic>> get relayStream => _repository.getRelayStream(_currentPondId);
  Stream<Map<String, dynamic>> get settingsStream => _repository.getSettingsStream(_currentPondId);

  Future<void> toggleRelay(String key, bool isOn) async {
    await _repository.updateRelay(_currentPondId, key, isOn);
  }

  Future<void> updateLampMode(String mode) async {
    await _repository.updateLampMode(_currentPondId, mode);
  }

  Future<void> updateLampTime({required String startTime, required String endTime}) async {
    await _repository.updateLampTime(_currentPondId, startTime: startTime, endTime: endTime);
  }

  Future<void> updateFeedMode(String mode) async {
    await _repository.updateFeedMode(_currentPondId, mode);
  }

  Future<void> updateFeedTime(String time) async {
    await _repository.updateFeedTime(_currentPondId, time);
  }

  Future<void> triggerFeed() async {
    if (_isFeeding) return;
    
    _isFeeding = true;
    notifyListeners();

    await _repository.updateRelay(_currentPondId, 'Feed', true);
    
    // Simulate feeding duration
    await Future.delayed(const Duration(seconds: 4));
    
    _isFeeding = false;
    notifyListeners();
  }
}
