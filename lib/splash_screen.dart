import 'package:flutter/material.dart';
import 'storage_manager.dart';
import 'home.dart';
import 'consentimento_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _checkConsentAndNavigate);
  }

  void _checkConsentAndNavigate() async {
    if (!mounted) return;
    
    try {
      await StorageManager.instance.initialize();
      final termoAceito = StorageManager.instance.getBool('termoAceito');
      
      if (termoAceito) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ConsentimentoPage()),
        );
      }
    } catch (e) {
      // Em caso de erro, vai para a página de consentimento
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ConsentimentoPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.medical_information_outlined,
              size: 100,
              color: Colors.indigo,
            ),
            SizedBox(height: 20),
            Text(
              'GuideDose',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }
}
