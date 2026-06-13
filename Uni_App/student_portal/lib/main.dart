import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:university_app/l10n/app_localizations.dart';

import 'core/bloc/language_cubit.dart';
import 'core/bloc/theme_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/main_screen.dart';
import 'features/requests/data/requests_repository.dart';
import 'features/announcements/cubit/announcements_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient(prefs);
  final authRepository = AuthRepository(apiClient);
  final requestsRepository = RequestsRepository(apiClient);

  if (!kIsWeb) {
    try {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const WindowOptions(
        size: Size(393, 852), // iPhone 14 Pro
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (e) {
      debugPrint('Window manager init failed: $e');
    }
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>.value(value: prefs),
        RepositoryProvider<ApiClient>.value(value: apiClient),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<RequestsRepository>.value(value: requestsRepository),
      ],
      child: const UniversityApp(),
    ),
  );
}

class UniversityApp extends StatelessWidget {
  const UniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(
          create: (context) => AuthCubit(
            context.read<AuthRepository>(),
            context.read<SharedPreferences>(),
          ),
        ),
        BlocProvider(
          create: (context) => AnnouncementsCubit(
            context.read<ApiClient>(),
          ),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              title: 'University App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  reverseDuration: const Duration(milliseconds: 800),
                  switchInCurve: Curves.easeOutQuart,
                  switchOutCurve: Curves.easeInQuart,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        final offset = locale.languageCode == 'ar'
                            ? const Offset(-0.05, 0.0)
                            : const Offset(0.05, 0.0);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: offset,
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: Directionality(
                    key: ValueKey(locale),
                    textDirection: Directionality.of(context),
                    child: child ?? const SizedBox(),
                  ),
                );
              },
              home: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return const MainScreen();
                  }
                  return const LoginScreen();
                },
              ),
            );
          },
        );
      },
    );
  }
}
