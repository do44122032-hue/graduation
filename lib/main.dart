import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/auth_service.dart';
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
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MyChart',
            // Add supported locales for English, Arabic, and Kurdish
            supportedLocales: const [Locale('en'), Locale('ar'), Locale('ku')],
            // Add localization delegates for material widgets and cupertino
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              KurdishMaterialLocalizationsDelegate(),
              KurdishCupertinoLocalizationsDelegate(),
            ],
            theme: ThemeData(
              primarySwatch: Colors.green,
              useMaterial3: true,
              fontFamily: 'SF Pro Display',
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: languageService.textDirection,
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
