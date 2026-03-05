/// Exemplo de como configurar o main.dart para usar a IA Médica.
/// 
/// Este arquivo mostra a configuração mínima necessária.
/// Adapte conforme a estrutura do seu projeto.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Descomente se usar Supabase para autenticação:
// import 'package:supabase_flutter/supabase_flutter.dart';

// Importe a tela da IA:
// import 'medical_ai/medical_ai_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Carregar variáveis de ambiente
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Arquivo .env não encontrado. Usando variáveis do sistema.');
  }

  // 2. Inicializar Supabase (opcional - necessário apenas se usar auth/database)
  // await Supabase.initialize(
  //   url: dotenv.env['SUPABASE_URL'] ?? '',
  //   anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App com IA Médica',
      theme: ThemeData(
        // Use a cor primária da IA ou a sua própria
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu App'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            // Navegue para a tela da IA:
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (_) => const MedicalAIScreen()),
            // );
            
            // Por enquanto, apenas mostra um snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Descomente o código para navegar para a IA Médica'),
              ),
            );
          },
          icon: const Icon(Icons.medical_services),
          label: const Text('Abrir IA Médica'),
        ),
      ),
    );
  }
}
