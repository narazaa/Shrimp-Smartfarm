abstract class ControlRepository {
  Stream<Map<String, dynamic>> getSensorsStream(String pondId);
  Stream<Map<String, dynamic>> getRelayStream(String pondId);
  Stream<Map<String, dynamic>> getSettingsStream(String pondId);

  Future<void> updateRelay(String pondId, String key, bool isOn);
  Future<void> updateLampTime(String pondId, {required String startTime, required String endTime});
  Future<void> updateLampMode(String pondId, String mode);
  Future<void> updateFeedTime(String pondId, String time);
  Future<void> updateFeedMode(String pondId, String mode);
}
