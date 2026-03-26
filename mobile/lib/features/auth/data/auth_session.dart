import '../../profile/data/app_user.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  final String token;
  final DateTime expiresAt;
  final AppUser user;

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final session =
        Map<String, dynamic>.from(json['session'] as Map? ?? const {});

    return AuthSession(
      token: session['token'] as String? ?? '',
      expiresAt: DateTime.parse(
        session['expiresAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      user: AppUser.fromJson(
          Map<String, dynamic>.from(json['user'] as Map? ?? const {})),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session': {
        'token': token,
        'expiresAt': expiresAt.toIso8601String(),
      },
      'user': user.toJson(),
    };
  }
}
