import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:food_safe/repositories/profile_repository.dart';

// Classe base para mock do ProfileRepository
@GenerateNiceMocks([MockSpec<ProfileRepository>()])
class BaseProfileRepositoryMock extends Mock implements ProfileRepository {
  BaseProfileRepositoryMock() {
    // Configure default responses
    when(getInitials()).thenReturn('JD');
    when(getUserName()).thenReturn('John Doe');
    when(getUserEmail()).thenReturn('john@example.com');
    when(getPhoto()).thenAnswer((_) async => null);
  }
}