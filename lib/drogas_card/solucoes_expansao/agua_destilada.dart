import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAguaDestilada {
  static const String nome = 'Água Destilada';
  static const String idBulario = 'aguadestilada';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/aguadestilada.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardAguaDestilada(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardAguaDestilada(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAguaDestilada._textoObs('• Solução estéril - Veículo para diluição'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAguaDestilada._linhaPreparo('Frasco 250mL', 'Água destilada estéril'),
        MedicamentoAguaDestilada._linhaPreparo('Frasco 500mL', 'Água destilada estéril'),
        MedicamentoAguaDestilada._linhaPreparo('Frasco 1000mL', 'Água destilada estéril'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAguaDestilada._linhaPreparo('Para diluição de medicamentos', 'Usar conforme instruções específicas'),
        MedicamentoAguaDestilada._linhaPreparo('Para limpeza de feridas', 'Aplicar diretamente ou com gaze'),
        MedicamentoAguaDestilada._linhaPreparo('Para esterilização', 'Usar em equipamentos e instrumentos'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoAguaDestilada._linhaIndicacaoDoseFixa(
            titulo: 'Diluição de medicamentos',
            descricaoDose: 'Conforme necessidade e instruções específicas',
            doseFixa: 'Variável conforme medicamento',
          ),
          MedicamentoAguaDestilada._linhaIndicacaoDoseFixa(
            titulo: 'Limpeza de feridas',
            descricaoDose: 'Irrigação e limpeza conforme necessário',
            doseFixa: 'Conforme necessidade',
          ),
          MedicamentoAguaDestilada._linhaIndicacaoDoseFixa(
            titulo: 'Esterilização de equipamentos',
            descricaoDose: 'Para limpeza e esterilização de instrumentos',
            doseFixa: 'Conforme protocolo',
          ),
        ] else ...[
          MedicamentoAguaDestilada._linhaIndicacaoDoseFixa(
            titulo: 'Diluição de medicamentos pediátricos',
            descricaoDose: 'Conforme necessidade e instruções específicas',
            doseFixa: 'Variável conforme medicamento',
          ),
          MedicamentoAguaDestilada._linhaIndicacaoDoseFixa(
            titulo: 'Limpeza de feridas pediátricas',
            descricaoDose: 'Irrigação e limpeza conforme necessário',
            doseFixa: 'Conforme necessidade',
          ),
          MedicamentoAguaDestilada._linhaIndicacaoDoseFixa(
            titulo: 'Preparo de soluções pediátricas',
            descricaoDose: 'Para diluição de medicamentos infantis',
            doseFixa: 'Conforme protocolo',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAguaDestilada._textoObs('• Solução estéril para uso médico e farmacêutico'),
        MedicamentoAguaDestilada._textoObs('• Não contém conservantes ou aditivos'),
        MedicamentoAguaDestilada._textoObs('• Armazenar em local fresco e seco'),
        MedicamentoAguaDestilada._textoObs('• Verificar data de validade antes do uso'),
        MedicamentoAguaDestilada._textoObs('• Usar apenas para fins médicos indicados'),
        MedicamentoAguaDestilada._textoObs('• Não ingerir - uso tópico e diluição apenas'),
      ],
    );
  }

  static Widget _linhaPreparo(String texto, String marca) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(text: texto),
                  if (marca.isNotEmpty) ...[
                    const TextSpan(text: ' | ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: marca, style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoDoseFixa({
    required String titulo,
    required String descricaoDose,
    required String doseFixa,
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
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
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
