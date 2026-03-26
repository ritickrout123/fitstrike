import 'package:flutter_test/flutter_test.dart';
import 'package:fitstrike_mobile/core/errors/failures.dart';

void main() {
  group('Failures', () {
    test('ServerFailure should hold a message', () {
      const failure = Failure.server(message: 'Error');
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Error');
    });

    test('NetworkFailure should be identifiable', () {
      const failure = Failure.network();
      expect(failure, isA<NetworkFailure>());
    });
  });
}
