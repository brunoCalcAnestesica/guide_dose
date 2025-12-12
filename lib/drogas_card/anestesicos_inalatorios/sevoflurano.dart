import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoSevoflurano {
  static const String nome = 'Sevoflurano';
  static const String idBulario = 'sevoflurano';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/sevoflurano.json');
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
      conteudo: _buildCardSevoflurano(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardSevoflurano(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSevoflurano._textoObs('Anestésico geral inalatório halogenado - Éter fluorado'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSevoflurano._linhaPreparo('Líquido volátil 100% (frasco 250mL)', 'Uso em vaporizador calibrado'),
        MedicamentoSevoflurano._linhaPreparo('Densidade: 1,52 g/mL a 20°C', 'Pressão vapor: 160 mmHg'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSevoflurano._linhaPreparo('Preencher vaporizador calibrado específico', 'Sevoflurano Tec 5/7'),
        MedicamentoSevoflurano._linhaPreparo('Conectar ao circuito anestésico', 'Fluxo gás fresco 1-6 L/min'),
        MedicamentoSevoflurano._linhaPreparo('Calibrar monitor gases anestésicos', 'Fração inspirada/expirada'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoSevoflurano._linhaIndicacaoDoseFixa(
            titulo: 'Indução anestésica (máscara)',
            descricaoDose: 'Concentração: 5-8% em O₂ 100% ou O₂/N₂O 50/50',
            doseFixa: '5-8%',
          ),
          MedicamentoSevoflurano._linhaIndicacaoDoseFixa(
            titulo: 'Manutenção anestésica',
            descricaoDose: 'CAM: 0,5-3% (0,5-1,5 CAM típico) com O₂ ou N₂O',
            doseFixa: '0,5-3%',
          ),
          MedicamentoSevoflurano._linhaIndicacaoDoseFixa(
            titulo: 'Manutenção balanceada (com opioide)',
            descricaoDose: 'Concentração: 0,5-2% (reduzir CAM com fentanil/remifentanil)',
            doseFixa: '0,5-2%',
          ),
        ] else ...[
          MedicamentoSevoflurano._linhaIndicacaoDoseFixa(
            titulo: 'Indução pediátrica (máscara)',
            descricaoDose: 'Concentração: 5-8% em O₂ 100% (aumentar gradualmente)',
            doseFixa: '5-8%',
          ),
          MedicamentoSevoflurano._linhaIndicacaoDoseFixa(
            titulo: 'Manutenção pediátrica',
            descricaoDose: 'Neonatos: 3-3,5%. Lactentes: 2,5-3%. Crianças: 2-2,5%',
            doseFixa: '2-3,5% (conforme idade)',
          ),
          MedicamentoSevoflurano._linhaIndicacaoDoseFixa(
            titulo: 'CAM pediátrico (1 CAM)',
            descricaoDose: 'Neonato: 3,3%. Lactente: 3,2%. Criança: 2,5%. Adolescente: 2,0%',
            doseFixa: '2-3,3% (1 CAM)',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSevoflurano._textoObs('Anestésico inalatório moderno - baixa solubilidade sangue/gás (0,65)'),
        MedicamentoSevoflurano._textoObs('Indução/despertar rápidos (2-4 min vs 10-15 min isoflurano)'),
        MedicamentoSevoflurano._textoObs('CAM adulto: 2,05% em O₂, 0,66% em N₂O 70%'),
        MedicamentoSevoflurano._textoObs('Odor agradável - ideal indução inalatória pediátrica'),
        MedicamentoSevoflurano._textoObs('Não irritante vias aéreas (vs desflurano)'),
        MedicamentoSevoflurano._textoObs('Mínima biotransformação (2-5%) - seguro hepatopatas'),
        MedicamentoSevoflurano._textoObs('ATENÇÃO: Evitar cal sodada ressecada (produz composto A - nefrotóxico)'),
        MedicamentoSevoflurano._textoObs('Usar fluxo gás fresco ≥2 L/min (evitar acúmulo composto A)'),
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
              'Concentração: $doseFixa',
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
