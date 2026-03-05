import 'package:flutter/material.dart';
import 'medical_ai_page.dart';

class MedicalAIScreen extends StatelessWidget {
  const MedicalAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IA Médica'),
      ),
      body: const MedicalAIPage(),
    );
  }
}
