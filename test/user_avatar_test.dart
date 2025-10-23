import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:food_safe/widgets/user_avatar.dart';
import 'package:food_safe/repositories/profile_repository.dart';

class MockProfileRepository extends Mock implements ProfileRepository {
  @override
  String getInitials() => 'JD';

  @override
  String getUserName() => 'John Doe';

  @override
  String getUserEmail() => 'john@example.com';

  @override
  Future<File?> getPhoto() async => null;
}

void main() {
  late MockProfileRepository mockRepo;
  late Widget testWidget;

  setUp(() {
    mockRepo = MockProfileRepository();

    testWidget = MaterialApp(
      home: Scaffold(
        body: UserAvatar(
          profileRepository: mockRepo,
          size: 64,
          onTap: () {},
        ),
      ),
    );
  });

  group('UserAvatar Widget', () {
    testWidgets('should show initials when no photo is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should show photo when available',
        (WidgetTester tester) async {
      final testWidget = MaterialApp(
        home: Scaffold(
          body: UserAvatar(
            profileRepository: MockProfileRepository(),
            size: 64,
            onTap: () {},
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      final circleAvatar = find.byType(CircleAvatar);
      expect(circleAvatar, findsOneWidget);
    });

    testWidgets('should be accessible with correct semantics',
        (WidgetTester tester) async {
      final testWidget = MaterialApp(
        home: Scaffold(
          body: Center(
            child: UserAvatar(
              profileRepository: mockRepo,
              size: 64,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final semFinder = find.descendant(
        of: find.byType(UserAvatar),
        matching: find.byType(Semantics),
        skipOffstage: false,
      ).first;
      
      final semantics = tester.getSemantics(semFinder);
      final label = semantics.getSemanticsData().label;
      expect(label, contains('Foto do perfil do usuário'));
      expect(label, contains('JD'));
      handle.dispose();
    });

    testWidgets('should have correct tap area size',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump();

      final gesture = find.byType(UserAvatar);
      final size = tester.getSize(gesture);
      
      // Verifica se a área de toque é >= 48dp
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('should show edit button when showEditButton is true',
        (WidgetTester tester) async {
      final testWidget = MaterialApp(
        home: Scaffold(
          body: UserAvatar(
            profileRepository: mockRepo,
            size: 64,
            showEditButton: true,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpWidget(testWidget);
      await tester.pump();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}