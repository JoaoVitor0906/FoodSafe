import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_safe/services/preferences_service.dart';

void main() {
  late PreferencesService preferencesService;
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    preferencesService = PreferencesService(preferences);
  });

  group('PreferencesService', () {
    test('should save and retrieve user photo path', () async {
      const testPath = '/test/path/photo.jpg';
      await preferencesService.setUserPhotoPath(testPath);
      
      expect(preferencesService.getUserPhotoPath(), equals(testPath));
      expect(preferencesService.getUserPhotoUpdatedAt(), isNotNull);
    });

    test('should clear photo path and timestamp when setting null path', () async {
      // First set a path
      await preferencesService.setUserPhotoPath('/test/path/photo.jpg');
      
      // Then clear it
      await preferencesService.setUserPhotoPath(null);
      
      expect(preferencesService.getUserPhotoPath(), isNull);
      expect(preferencesService.getUserPhotoUpdatedAt(), isNull);
    });

    test('should save and retrieve user name', () async {
      const testName = 'John Doe';
      await preferencesService.setUserName(testName);
      
      expect(preferencesService.getUserName(), equals(testName));
    });

    test('should save and retrieve user email', () async {
      const testEmail = 'john@example.com';
      await preferencesService.setUserEmail(testEmail);
      
      expect(preferencesService.getUserEmail(), equals(testEmail));
    });
  });
}