import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  AppUser? get currentUser => _remote.currentUser;

  @override
  Future<AppUser> signIn(String email, String password) =>
      _guard(() => _remote.signIn(email, password));

  @override
  Future<AppUser> signUp(String name, String email, String password) =>
      _guard(() => _remote.signUp(name, email, password));

  @override
  Future<void> signOut() => _guard(_remote.signOut);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(switch (error.code) {
        'invalid-email' => AuthFailureType.invalidEmail,
        'email-already-in-use' => AuthFailureType.emailInUse,
        'weak-password' => AuthFailureType.weakPassword,
        'wrong-password' ||
        'user-not-found' ||
        'invalid-credential' => AuthFailureType.invalidCredentials,
        'too-many-requests' => AuthFailureType.tooManyRequests,
        'network-request-failed' => AuthFailureType.network,
        _ => AuthFailureType.generic,
      });
    } on FirebaseException catch (error) {
      throw AuthFailure(switch (error.code) {
        'unavailable' ||
        'deadline-exceeded' => AuthFailureType.serviceUnavailable,
        'permission-denied' => AuthFailureType.accountSave,
        _ => AuthFailureType.accountSave,
      });
    } on SocketException {
      throw const AuthFailure(AuthFailureType.network);
    } on PlatformException {
      throw const AuthFailure(AuthFailureType.serviceUnavailable);
    } catch (_) {
      throw const AuthFailure(AuthFailureType.generic);
    }
  }
}
