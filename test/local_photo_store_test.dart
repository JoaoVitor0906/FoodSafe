// ignore: unused_import
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_safe/services/local_photo_store.dart';
import 'package:food_safe/services/image_service.dart';
// ignore: unused_import
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<ImageService>()])
import 'local_photo_store_test.mocks.dart';

void main() {
  late LocalPhotoStore localPhotoStore;
  late MockImageService mockImageService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockImageService = MockImageService();
    localPhotoStore = LocalPhotoStore(imageService: mockImageService);
  });

  group('LocalPhotoStore', () {
    test('isValidPhotoPath returns false for null path', () {
      final result = localPhotoStore.isValidPhotoPath(null);
      expect(result, false);
    });

    test('getPhoto returns null for non-existent file', () async {
      final testPath = '/non/existent/path/file.jpg';
      final result = await localPhotoStore.getPhoto(testPath);
      expect(result, isNull);
    });

    test('getPhotoBytes returns null for non-existent file', () async {
      final testPath = '/non/existent/path/file.jpg';
      final result = await localPhotoStore.getPhotoBytes(testPath);
      expect(result, isNull);
    });
  });
}