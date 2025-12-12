import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPicadaCobra {
  static const String nome = 'Picada de Cobra';
  static const String idBulario = 'picadacobra';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/picadacobra.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardPicadaCobra(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Soro antiofídico tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardPicadaCobra(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Imunobiológico - Soro Heterólogo Antiofídico',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPicadaCobra._linhaPreparo(
            '• Soro Antibotrópico: 10 mL (5.000-10.000 UI)'),
        MedicamentoPicadaCobra._linhaPreparo(
            '• Soro Anticrotálico: 10 mL (5.000-10.000 UI)'),
        MedicamentoPicadaCobra._linhaPreparo(
            '• Soro Antilaquético: 10 mL (5.000-10.000 UI)'),
        MedicamentoPicadaCobra._linhaPreparo(
            '• Soro Antielapídico: 10 mL (5.000-10.000 UI)'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPicadaCobra._linhaPreparo(
            '• Diluir as ampolas em 250-500 mL de SF 0,9%'),
        MedicamentoPicadaCobra._linhaPreparo(
            '• Homogeneizar suavemente (não agitar)'),
        MedicamentoPicadaCobra._linhaPreparo('• Infundir em 20-60 minutos'),
        MedicamentoPicadaCobra._linhaPreparo(
            '• Iniciar lentamente (20-30 gotas/min primeiros 15 min)'),
        const SizedBox(height: 16),
        const Text('Indicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('ATENÇÃO: Doses são FIXAS, NÃO dependem do peso!',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 8),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Botrópico (Jararaca) - Leve',
          descricaoDose: 'Edema local <50% do membro',
          dose: '2-4 ampolas',
        ),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Botrópico (Jararaca) - Moderado',
          descricaoDose: 'Edema 50-100%, sem complicações',
          dose: '4-8 ampolas',
        ),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Botrópico (Jararaca) - Grave',
          descricaoDose: 'Edema todo membro + sistêmico',
          dose: '12 ampolas',
        ),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Crotálico (Cascavel) - Leve',
          descricaoDose: 'Fácies miastênica inicial',
          dose: '5 ampolas',
        ),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Crotálico (Cascavel) - Moderado',
          descricaoDose: 'Ptose, diplopia, rabdomiólise',
          dose: '10 ampolas',
        ),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Crotálico (Cascavel) - Grave',
          descricaoDose: 'Insuficiência renal, paralisia',
          dose: '20 ampolas',
        ),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Laquético (Surucucu) - Leve',
          descricaoDose: 'Edema local moderado',
          dose: '5 ampolas',
        ),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Laquético (Surucucu) - Moderado',
          descricaoDose: 'Edema + hipotensão/bradicardia',
          dose: '10 ampolas',
        ),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Laquético (Surucucu) - Grave',
          descricaoDose: 'Choque, manifestações vagais',
          dose: '20 ampolas',
        ),
        MedicamentoPicadaCobra._linhaIndicacaoSoro(
          titulo: 'Elapídico (Coral) - Qualquer',
          descricaoDose: 'Paralisia flácida progressiva',
          dose: '10 ampolas',
        ),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPicadaCobra._textoObs(
            '• Dose NÃO depende do peso (mesma dose para crianças e adultos)'),
        MedicamentoPicadaCobra._textoObs(
            '• Administrar o mais precoce possível (ideal <6h)'),
        MedicamentoPicadaCobra._textoObs(
            '• Ter adrenalina, anti-histamínico, O₂ disponível'),
        MedicamentoPicadaCobra._textoObs('• Hidratação vigorosa (3-4 L/dia)'),
        MedicamentoPicadaCobra._textoObs(
            '• Repetir soro se coagulopatia persistente'),
      ],
    );
  }

  static Widget _linhaPreparo(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
    );
  }

  static Widget _linhaIndicacaoSoro({
    required String titulo,
    required String descricaoDose,
    required String dose,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            descricaoDose,
            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Text(
              'Dose: $dose IV',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
    );
  }
}
