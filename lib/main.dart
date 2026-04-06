import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'screens/auth/welcome.dart';
import 'enums/user_role.dart';
import 'screens/medical/dashboard_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/doctor/doctor_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const MyChartApp());
}

class MyChartApp extends StatelessWidget {
  const MyChartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: Consumer2<LanguageService, ThemeService>(
        builder: (context, languageService, themeService, child) {
          final isRTL = languageService.isRTL;
          
          return MaterialApp(
            themeMode: themeService.themeMode,
            debugShowCheckedModeBanner: false,
            title: 'MyChart',
            locale: Locale(languageService.currentLanguage),
            supportedLocales: const [
              Locale('en', ''),
              Locale('ar', ''),
              Locale('ku', ''),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              KurdishMaterialLocalizationsDelegate(),
              KurdishCupertinoLocalizationsDelegate(),
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale?.languageCode == 'ku') {
                return const Locale('ku', '');
              }
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              // Ensure color scheme and fonts are consistent
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2D5F4C),
                primary: const Color(0xFF2D5F4C),
                secondary: const Color(0xFFCBD77E),
                surface: Colors.white,
                background: const Color(0xFFF8FAF8),
              ),
              scaffoldBackgroundColor: const Color(0xFFF8FAF8),
              cardColor: Colors.white,
              fontFamily: 'SF Pro Display',
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2D5F4C),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF0F1210),
              cardColor: const Color(0xFF1A1F1C),
              fontFamily: 'SF Pro Display',
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
            home: _getHome(context),
          );
        },
      ),
    );
  }

  Widget _getHome(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (!auth.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
          );
        }

        if (!auth.isAuthenticated) {
          return const WelcomeScreen();
        }

        // Redirect based on role
        final user = auth.currentUser!;
        switch (user.role) {
          case UserRole.student:
            return const StudentDashboardScreen();
          case UserRole.doctor:
            return const DoctorDashboardScreen();
          case UserRole.patient:
            return const ModernDashboardScreen();
        }
      },
    );
  }
}

class KurdishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const KurdishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return await GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
  }

  @override
  bool shouldReload(KurdishMaterialLocalizationsDelegate old) => false;
}

class KurdishCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const KurdishCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return await GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));
  }

  @override
  bool shouldReload(KurdishCupertinoLocalizationsDelegate old) => false;
}
