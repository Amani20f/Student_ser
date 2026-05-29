import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_repository.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final Map<String, dynamic> user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;

  AuthCubit(this._authRepository, this._prefs) : super(AuthInitial()) {
    checkAuthStatus();
  }

  /// Check if the user is already logged in on app startup
  void checkAuthStatus() {
    final token = _prefs.getString('auth_token');
    final userJson = _prefs.getString('cached_user');

    if (token != null && userJson != null) {
      try {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        emit(Authenticated(user));
      } catch (_) {
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  /// Perform login and save session data
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(email, password);
      
      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>;

      // Check if user is a student
      final role = user['role'] as String?;
      final isStudent = role == 'student' || (user['roles'] as List?)?.contains('student') == true;

      if (!isStudent) {
        emit(const AuthError('هذه البوابة مخصصة للطلاب فقط.'));
        return;
      }

      // Save token and user details to SharedPreferences
      await _prefs.setString('auth_token', token);
      await _prefs.setString('cached_user', jsonEncode(user));

      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('ApiException:', '').replaceAll('Exception:', '').trim()));
    }
  }

  /// Update password (mandatory change password flow or settings)
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    emit(AuthLoading());
    try {
      await _authRepository.changePassword(currentPassword, newPassword);
      
      // Keep user authenticated, retrieve cached user
      final userJson = _prefs.getString('cached_user');
      if (userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
      return true;
    } catch (e) {
      final userJson = _prefs.getString('cached_user');
      if (userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        emit(Authenticated(user)); // restore authenticated state
      } else {
        emit(Unauthenticated());
      }
      // Re-emit error for screen to show toast/snackbar
      throw Exception(e.toString().replaceAll('ApiException:', '').replaceAll('Exception:', '').trim());
    }
  }

  /// Log out and clear preferences
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
    } catch (_) {
      // Even if API logout fails, clear local session
    } finally {
      await _prefs.remove('auth_token');
      await _prefs.remove('cached_user');
      emit(Unauthenticated());
    }
  }
}
