import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPlasmaLyte {
  static const String nome = 'Plasma-Lyte';
  static const String idBulario = 'plasmalyte';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/plasmalyte.json');
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
      conteudo: _buildCardPlasmaLyte(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Plasma-Lyte tem indicações para todas as faixas etárias
    return true;
  }

  static Widget _buildCardPlasmaLyte(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Solução Cristaloide Balanceada Isotônica',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPlasmaLyte._linhaPreparo('• Bolsa 250 mL, 500 mL, 1000 mL'),
        MedicamentoPlasmaLyte._linhaPreparo(
            '• Osmolaridade: 294 mOsm/L (isotônica)'),
        MedicamentoPlasmaLyte._linhaPreparo(
            '• Composição: Na⁺ 140, K⁺ 5, Mg²⁺ 3, Cl⁻ 98, acetato 27, gluconato 23 mEq/L'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPlasmaLyte._linhaPreparo('• Solução pronta para uso'),
        MedicamentoPlasmaLyte._linhaPreparo(
            '• Não requer diluição ou reconstituição'),
        MedicamentoPlasmaLyte._linhaPreparo('• Técnica asséptica na conexão'),
        const SizedBox(height: 16),
        const Text('Indicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPlasmaLyte._textoObs(
            '• Evita acidose hiperclorêmica (vs SF 0,9%)'),
        MedicamentoPlasmaLyte._textoObs(
            '• Monitorar K⁺ e Mg²⁺ em insuficiência renal'),
        MedicamentoPlasmaLyte._textoObs(
            '• Contraindicado em hipercalemia >5,5 mEq/L'),
        MedicamentoPlasmaLyte._textoObs(
            '• Preferível ao SF 0,9% em pacientes críticos'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(
      String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Neonato':
      case 'Lactente':
      case 'Criança':
        indicacoes.addAll([
          MedicamentoPlasmaLyte._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção (regra 4:2:1)',
            descricaoDose:
                'Primeiros 10 kg: 4 mL/kg/h; próximos 10 kg: 2 mL/kg/h; acima 20 kg: 1 mL/kg/h',
            unidade: 'mL/h',
            dosePorKg: _calcularReposicao421(peso),
            peso: peso,
          ),
          MedicamentoPlasmaLyte._linhaIndicacaoDoseCalculada(
            titulo: 'Reposição volêmica',
            descricaoDose: 'Bolus: 10-20 mL/kg IV em hipovolemia aguda',
            unidade: 'mL',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 20,
            peso: peso,
          ),
        ]);
        break;
      case 'Adolescente':
      case 'Adulto':
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoPlasmaLyte._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção',
            descricaoDose: 'Dose: 25-40 mL/kg/dia',
            unidade: 'mL/dia',
            dosePorKgMinima: 25,
            dosePorKgMaxima: 40,
            peso: peso,
          ),
          MedicamentoPlasmaLyte._linhaIndicacaoDoseFixa(
            titulo: 'Reposição volêmica',
            descricaoDose: 'Bolus: 500-1000 mL IV conforme status hemodinâmico',
            doseFixa: '500-1000 mL',
          ),
        ]);
        break;
    }

    return indicacoes;
  }

  static double _calcularReposicao421(double peso) {
    // Regra 4:2:1
    if (peso <= 10) {
      return 4.0; // mL/kg/h
    } else if (peso <= 20) {
      return 2.0; // mL/kg/h para os próximos 10 kg
    } else {
      return 1.0; // mL/kg/h acima de 20 kg
    }
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
                'Volume: $textoDose',
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
              'Volume: $doseFixa',
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
