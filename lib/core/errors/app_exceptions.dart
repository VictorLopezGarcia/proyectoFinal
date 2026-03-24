class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class ReservationException extends AppException {
  const ReservationException(super.message, {super.code});
}

class OverlappingReservationException extends ReservationException {
  const OverlappingReservationException()
      : super(
          'Las fechas seleccionadas se solapan con una reserva existente',
          code: 'overlapping-reservation',
        );
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}
