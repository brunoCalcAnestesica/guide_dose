import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPrilocaina {
  static const String nome = 'Prilocaína';
  static const String idBulario = 'prilocaina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/prilocaina.json');
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
      conteudo: _buildCardPrilocaina(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Prilocaína tem indicações para todas as faixas, mas com cautela em neonatos
    return true;
  }

  static Widget _buildCardPrilocaina(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Anestésico Local Tipo Amida',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPrilocaina._linhaPreparo(
            '• Solução injetável 1% (10 mg/mL) - 20 mL'),
        MedicamentoPrilocaina._linhaPreparo(
            '• Solução injetável 2% (20 mg/mL) - 20 mL'),
        MedicamentoPrilocaina._linhaPreparo(
            '• Solução injetável 3% (30 mg/mL) - tubetes 1,8 mL'),
        MedicamentoPrilocaina._linhaPreparo(
            '• Creme EMLA 2,5% (com lidocaína 2,5%) - 5g, 30g'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPrilocaina._linhaPreparo(
            '• Usar solução pronta (não requer diluição)'),
        MedicamentoPrilocaina._linhaPreparo(
            '• Pode adicionar vasoconstritor se necessário'),
        MedicamentoPrilocaina._linhaPreparo(
            '• EMLA: aplicar camada espessa, ocluir por 60-90 min'),
        MedicamentoPrilocaina._linhaPreparo(
            '• Sempre aspirar antes de injetar'),
        const SizedBox(height: 16),
        const Text('Indicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPrilocaina._textoObs(
            '• Dose máxima: 400 mg (sem), 600 mg (com vasoconstritor)'),
        MedicamentoPrilocaina._textoObs(
            '• RISCO: metemoglobinemia (doses >600 mg ou neonatos)'),
        MedicamentoPrilocaina._textoObs(
            '• Ter azul de metileno disponível (1-2 mg/kg IV)'),
        MedicamentoPrilocaina._textoObs(
            '• Contraindicado: G6PD, metemoglobinemia'),
        MedicamentoPrilocaina._textoObs(
            '• Evitar em neonatos (preferir lidocaína)'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(
      String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Neonato':
        indicacoes.addAll([
          MedicamentoPrilocaina._linhaIndicacaoDoseCalculada(
            titulo: 'Anestesia local (uso cauteloso)',
            descricaoDose:
                'Dose máxima: 2-3 mg/kg (EVITAR - preferir lidocaína)',
            unidade: 'mg',
            dosePorKgMinima: 2,
            dosePorKgMaxima: 3,
            peso: peso,
          ),
        ]);
        break;
      case 'Lactente':
      case 'Criança':
        indicacoes.addAll([
          MedicamentoPrilocaina._linhaIndicacaoDoseCalculada(
            titulo: 'Infiltração anestésica',
            descricaoDose: 'Dose máxima: 5-7 mg/kg (solução 0,5-1%)',
            unidade: 'mg',
            dosePorKgMinima: 5,
            dosePorKgMaxima: 7,
            peso: peso,
          ),
          MedicamentoPrilocaina._linhaIndicacaoDoseFixa(
            titulo: 'EMLA tópico',
            descricaoDose: 'Aplicar 60 min antes, dose conforme idade/peso',
            doseFixa: 'Conforme protocolo EMLA',
          ),
        ]);
        break;
      case 'Adolescente':
      case 'Adulto':
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoPrilocaina._linhaIndicacaoDoseFixa(
            titulo: 'Infiltração anestésica',
            descricaoDose: 'Dose máxima: 400 mg (sem vasoconstritor)',
            doseFixa: '400 mg (sem vasoconstritor)',
          ),
          MedicamentoPrilocaina._linhaIndicacaoDoseFixa(
            titulo: 'Com vasoconstritor',
            descricaoDose: 'Dose máxima: 600 mg (com vasoconstritor)',
            doseFixa: '600 mg (com vasoconstritor)',
          ),
          MedicamentoPrilocaina._linhaIndicacaoDoseFixa(
            titulo: 'Bloqueio de Bier',
            descricaoDose: 'Solução 0,5%, máximo 3 mg/kg (máx 200 mg)',
            doseFixa: '3 mg/kg (máx 200 mg)',
          ),
        ]);
        break;
    }

    return indicacoes;
  }

  static Widget _linhaPreparo(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaxima,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose =
          '${doseCalculada.toStringAsFixed(0)} ${unidade?.replaceAll('/kg', '')}';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} ${unidade?.replaceAll('/kg', '')}';
    }

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
          if (textoDose != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'Dose máxima: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
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
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
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
