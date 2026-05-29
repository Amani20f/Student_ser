import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

// ── SharedPreferences provider ──
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

// ── ApiClient provider ──
final apiClientProvider = Provider<ApiClient>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ApiClient(prefs);
});

// ── AuthRepository provider ──
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return AuthRepository(apiClient, prefs);
});

// ── Auth State ──
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  String get primaryRole => user?.primaryRole ?? '';

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Auth Notifier ──
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _tryAutoLogin();
  }

  void _tryAutoLogin() {
    final user = _repository.getStoredUser();
    if (user != null && _repository.isLoggedIn) {
      state = AuthState(user: user);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(user: user);
    } on UnauthorizedException {
      state = state.copyWith(isLoading: false, error: 'Invalid credentials');
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Connection error. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  /// Called when a 401 is detected anywhere in the app.
  void handleUnauthorized() {
    _repository.logout();
    state = const AuthState();
  }
}

// ── Auth Provider ──
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
