import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'control_repository.dart';

class FirebaseControlRepository implements ControlRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String _getPrefix(String pondId) {
    // If pond1, it returns '', if pond2 it returns 'V2'.
    return pondId == 'pond1' ? '' : 'V2';
  }

  @override
  Stream<Map<String, dynamic>> getSensorsStream(String pondId) {
    return _db.child('sensors${_getPrefix(pondId)}').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return <String, dynamic>{};
    });
  }

  @override
  Stream<Map<String, dynamic>> getRelayStream(String pondId) {
    return _db.child('relay${_getPrefix(pondId)}').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return <String, dynamic>{};
    });
  }

  @override
  Stream<Map<String, dynamic>> getSettingsStream(String pondId) {
    return _db.child('settings${_getPrefix(pondId)}').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> updateRelay(String pondId, String key, bool isOn) async {
    await _db.child('relay${_getPrefix(pondId)}').child(key).set(isOn);
  }

  @override
  Future<void> updateLampTime(String pondId, {required String startTime, required String endTime}) async {
    await _db.child('settings${_getPrefix(pondId)}').child('lamp').update({
      'startTime': startTime,
      'endTime': endTime,
      'mode': 'auto',
    });
  }

  @override
  Future<void> updateLampMode(String pondId, String mode) async {
    await _db.child('settings${_getPrefix(pondId)}').child('lamp').update({
      'mode': mode,
    });
  }

  @override
  Future<void> updateFeedTime(String pondId, String time) async {
    await _db.child('settings${_getPrefix(pondId)}').child('feed').update({
      'time': time,
      'mode': 'auto',
    });
  }

  @override
  Future<void> updateFeedMode(String pondId, String mode) async {
    await _db.child('settings${_getPrefix(pondId)}').child('feed').update({
      'mode': mode,
    });
  }
}
