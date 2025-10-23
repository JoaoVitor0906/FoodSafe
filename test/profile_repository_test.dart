import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:food_safe/repositories/profile_repository.dart';
import 'package:food_safe/services/preferences_service.dart';
import 'package:food_safe/services/local_photo_store.dart';

@GenerateNiceMocks([
  MockSpec<PreferencesService>(),
  MockSpec<LocalPhotoStore>(),
  MockSpec<File>()
])
import 'profile_repository_test.mocks.dart';

void main() {
  late ProfileRepository repository;
  late MockPreferencesService mockPreferencesService;
  late MockLocalPhotoStore mockLocalPhotoStore;
  late MockFile mockFile;

  setUp(() {
    mockPreferencesService = MockPreferencesService();
    mockLocalPhotoStore = MockLocalPhotoStore();
    mockFile = MockFile();
    repository = ProfileRepository(mockPreferencesService, mockLocalPhotoStore);
  });

  group('ProfileRepository', () {
    test('savePhoto should save photo and update preferences', () async {
      const savedPath = '/saved/photo/path.jpg';
      when(mockLocalPhotoStore.savePhoto(mockFile))
          .thenAnswer((_) async => savedPath);
      when(mockPreferencesService.setUserPhotoPath(savedPath))
          .thenAnswer((_) async {});

      final result = await repository.savePhoto(mockFile);

      expect(result, equals(savedPath));
      verify(mockLocalPhotoStore.savePhoto(mockFile)).called(1);
      verify(mockPreferencesService.setUserPhotoPath(savedPath)).called(1);
    });

    test('removePhoto should delete file and clear preferences', () async {
      const photoPath = '/photo/path.jpg';
      when(mockPreferencesService.getUserPhotoPath()).thenReturn(photoPath);
      when(mockLocalPhotoStore.deletePhoto(photoPath)).thenAnswer((_) async => true);
      when(mockPreferencesService.setUserPhotoPath(null))
          .thenAnswer((_) async {});

      final result = await repository.removePhoto();

      expect(result, isTrue);
      verify(mockLocalPhotoStore.deletePhoto(photoPath)).called(1);
      verify(mockPreferencesService.setUserPhotoPath(null)).called(1);
    });

    test('getInitials should return correct initials for full name', () {
      when(mockPreferencesService.getUserName()).thenReturn('John Doe');
      
      final initials = repository.getInitials();
      
      expect(initials, equals('JD'));
    });

    test('getInitials should return first letter for single name', () {
      when(mockPreferencesService.getUserName()).thenReturn('John');
      
      final initials = repository.getInitials();
      
      expect(initials, equals('J'));
    });

    test('getInitials should return empty string for empty name', () {
      when(mockPreferencesService.getUserName()).thenReturn('');
      
      final initials = repository.getInitials();
      
      expect(initials, equals(''));
    });

    test('getInitials should return empty string for null name', () {
      when(mockPreferencesService.getUserName()).thenReturn(null);
      
      final initials = repository.getInitials();
      
      expect(initials, equals(''));
    });
  });
}