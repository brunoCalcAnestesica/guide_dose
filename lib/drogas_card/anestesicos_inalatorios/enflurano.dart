import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoEnflurano {
  static const String nome = 'Enflurano';
  static const String idBulario = 'enflurano';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/enflurano.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
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
      conteudo: _buildCardEnflurano(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Enflurano tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardEnflurano(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Classe
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('• Anestésico inalatório halogenado'),
        const Text('• Éter fluorado'),
        
        const SizedBox(height: 16),
        
        // Apresentações
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('• Enflurano líquido - Frasco 100 mL'),
        const Text('• Enflurano líquido - Frasco 250 mL'),
        
        const SizedBox(height: 16),
        
        // Preparo
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('• Administrar via vaporizador de precisão'),
        const Text('• Calibrar vaporizador antes do uso'),
        const Text('• Usar circuito fechado ou semi-fechado'),
        const Text('• Monitorar concentração expirada (FAC)'),
        
        const SizedBox(height: 16),
        
        // Indicações por faixa etária
        _buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        
        const SizedBox(height: 16),
        
        // Observações
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEnflurano._textoObs('Anestésico inalatório de uso hospitalar'),
        MedicamentoEnflurano._textoObs('MAC: 1,68% (adultos), 2,2% (crianças)'),
        MedicamentoEnflurano._textoObs('Indução: 3-4%, Manutenção: 1,5-3%'),
        MedicamentoEnflurano._textoObs('Cautela em epilepsia (pode causar convulsões)'),
        MedicamentoEnflurano._textoObs('Metabolização hepática (2-8%)'),
        MedicamentoEnflurano._textoObs('Contraindicado em hipertensão intracraniana'),
        MedicamentoEnflurano._textoObs('Monitorar função renal em uso prolongado'),
      ],
    );
  }

  static Widget _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        
        if (isAdulto) ...[
          MedicamentoEnflurano._linhaIndicacaoSemCalculo(
            titulo: 'Anestesia geral - Indução',
            descricaoDose: 'Concentração inicial: 3-4%',
          ),
          const SizedBox(height: 8),
          MedicamentoEnflurano._linhaIndicacaoSemCalculo(
            titulo: 'Anestesia geral - Manutenção',
            descricaoDose: 'Concentração: 1,5-3%',
          ),
          const SizedBox(height: 8),
          MedicamentoEnflurano._linhaIndicacaoSemCalculo(
            titulo: 'Anestesia ambulatorial',
            descricaoDose: 'Concentração: 1-2%',
          ),
        ] else ...[
          MedicamentoEnflurano._linhaIndicacaoSemCalculo(
            titulo: 'Anestesia pediátrica - Indução',
            descricaoDose: 'Concentração inicial: 2,5-3,5%',
          ),
          const SizedBox(height: 8),
          MedicamentoEnflurano._linhaIndicacaoSemCalculo(
            titulo: 'Anestesia pediátrica - Manutenção',
            descricaoDose: 'Concentração: 1-2,5%',
          ),
        ],
      ],
    );
  }


  static Widget _linhaIndicacaoSemCalculo({
    required String titulo,
    required String descricaoDose,
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
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }


  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}