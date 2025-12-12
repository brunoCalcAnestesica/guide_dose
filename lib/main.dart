import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'splash_screen.dart';
import 'consentimento_page.dart';
import 'bulario_page.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GuideDoseApp());
}

class GuideDoseApp extends StatelessWidget {
  const GuideDoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuideDose',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', ''), // Português
        Locale('en', ''), // Inglês
        Locale('es', ''), // Espanhol
        Locale('zh', ''), // Chinês
      ],
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/consentimento': (context) => const ConsentimentoPage(),
        '/home': (context) => const HomePage(),
        '/bulario': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          return BularioPage(principioAtivo: args ?? 'adrenalina');
        },
      },
    );
  }
}
