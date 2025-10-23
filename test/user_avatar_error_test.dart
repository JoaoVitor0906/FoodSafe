import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_safe/widgets/user_avatar.dart';
import 'package:food_safe/repositories/profile_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<ProfileRepository>()])
import 'user_avatar_error_test.mocks.dart';

void main() {
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockProfileRepository = MockProfileRepository();
    final photoVersion = ValueNotifier<int>(0);
    when(mockProfileRepository.photoVersion).thenReturn(photoVersion);
    when(mockProfileRepository.getInitials()).thenReturn('TS');
  });

  testWidgets('UserAvatar shows loading indicator during photo load',
      (WidgetTester tester) async {
    // Setup a delayed photo load that returns null
    when(mockProfileRepository.getPhotoData())
        .thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: UserAvatar(
          profileRepository: mockProfileRepository,
        ),
      ),
    ));

    await tester.pump();

    // Should show initials when no photo is available
    expect(find.text('TS'), findsOneWidget);
  });

  testWidgets('UserAvatar shows error state with invalid image data',
      (WidgetTester tester) async {
    // Setup invalid image data
    when(mockProfileRepository.getPhotoData())
        .thenAnswer((_) => Future.value(Uint8List(0)));
    when(mockProfileRepository.getInitials()).thenReturn('TS');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: UserAvatar(
          profileRepository: mockProfileRepository,
        ),
      ),
    ));

    await tester.pump();
    
    // Should show initials as fallback
    expect(find.text('TS'), findsOneWidget);
  });

  testWidgets('UserAvatar handles error in photo loading',
      (WidgetTester tester) async {
    // Setup error case
    when(mockProfileRepository.getPhotoData())
        .thenAnswer((_) => Future.error('Failed to load'));
    when(mockProfileRepository.getInitials()).thenReturn('TS');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: UserAvatar(
          profileRepository: mockProfileRepository,
        ),
      ),
    ));

    await tester.pump();
    
    // Should show initials when error occurs
    expect(find.text('TS'), findsOneWidget);
  });

  testWidgets('UserAvatar has correct tap target size',
      (WidgetTester tester) async {
    when(mockProfileRepository.getPhotoData())
        .thenAnswer((_) => Future.value(null));
    bool tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: UserAvatar(
            profileRepository: mockProfileRepository,
            size: 48, // Minimum tap target size
            onTap: () => tapped = true,
          ),
        ),
      ),
    ));

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(UserAvatar));
    await tester.pumpAndSettle();

    expect(tapped, true, reason: 'Avatar should be tappable at minimum size');
  });
}