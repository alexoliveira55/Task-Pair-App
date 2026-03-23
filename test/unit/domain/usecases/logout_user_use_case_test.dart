import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/usecases/logout_user_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late LogoutUserUseCase useCase;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    useCase = LogoutUserUseCase(mockAuthRepo);
  });

  group('LogoutUserUseCase', () {
    test('should call signOut on auth repository', () async {
      when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});

      await useCase.execute();

      verify(() => mockAuthRepo.signOut()).called(1);
    });

    test('should propagate exception when signOut fails', () async {
      when(() => mockAuthRepo.signOut())
          .thenThrow(Exception('Sign out failed'));

      expect(() => useCase.execute(), throwsException);
    });
  });
}
