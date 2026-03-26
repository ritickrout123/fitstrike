import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'auth_session.dart';

final authSessionStorageProvider = Provider<AuthSessionStorage>((ref) {
  return const AuthSessionStorage();
});

class AuthSessionStorage {
  const AuthSessionStorage();

  static const _boxName = 'fitstrike_auth';
  static const _sessionKey = 'session_payload';

  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  Future<AuthSession?> readSession() async {
    final box = Hive.box<String>(_boxName);
    final raw = box.get(_sessionKey);

    if (raw == null || raw.isEmpty) {
      return null;
    }

    return AuthSession.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> saveSession(AuthSession session) async {
    final box = Hive.box<String>(_boxName);
    await box.put(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clearSession() async {
    final box = Hive.box<String>(_boxName);
    await box.delete(_sessionKey);
  }
}
