/// Sealed class hierarchy for typed failures across all layers.
/// Each feature can extend this with domain-specific failures.
sealed class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});

  @override
  String toString() => '$runtimeType: $message';
}

// ── Auth failures ──────────────────────────────────────────────────────────
final class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause});
}

final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super('Email o password non corretti.');
}

final class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure()
      : super('Questa email è già registrata.');
}

final class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
      : super('La password deve essere di almeno 6 caratteri.');
}

final class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure() : super('Utente non trovato.');
}

// ── Network / server failures ──────────────────────────────────────────────
final class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Nessuna connessione a internet.'])
      : super(message);
}

final class ServerFailure extends Failure {
  const ServerFailure([String message = 'Errore del server. Riprova più tardi.'])
      : super(message);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('La richiesta ha impiegato troppo tempo.');
}

// ── Permission failures ────────────────────────────────────────────────────
final class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permesso negato.'])
      : super(message);
}

final class LocationPermissionFailure extends PermissionFailure {
  const LocationPermissionFailure()
      : super('Permesso di localizzazione negato. Abilitalo nelle impostazioni.');
}

// ── Storage failures ───────────────────────────────────────────────────────
final class StorageFailure extends Failure {
  const StorageFailure([String message = 'Errore durante il caricamento del file.'])
      : super(message);
}

final class FileTooLargeFailure extends StorageFailure {
  const FileTooLargeFailure() : super('Il file supera la dimensione massima consentita (10 MB).');
}

final class InvalidFileTypeFailure extends StorageFailure {
  const InvalidFileTypeFailure() : super('Tipo di file non supportato. Carica un PDF.');
}

// ── Business logic failures ────────────────────────────────────────────────
final class AlreadyAppliedFailure extends Failure {
  const AlreadyAppliedFailure() : super('Hai già inviato la candidatura per questa posizione.');
}

final class JobExpiredFailure extends Failure {
  const JobExpiredFailure() : super('Questa offerta è scaduta e non è più candidabile.');
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Non sei autorizzato a eseguire questa operazione.');
}

final class NotFoundFailure extends Failure {
  final String resource;
  const NotFoundFailure(this.resource) : super('$resource non trovato.');
}

// ── Unknown failure (fallback) ─────────────────────────────────────────────
final class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Si è verificato un errore inaspettato.'])
      : super(message);
}
