import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const appName = 'FitStrike';
  static const appTagline = 'Strike Your Fitness Goals. Own Your Streets.';

  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://localhost:3000/v1');

  static String get socketUrl =>
      dotenv.get('SOCKET_URL', fallback: 'http://localhost:3000');
}
