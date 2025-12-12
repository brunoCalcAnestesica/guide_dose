import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPropofol {
  static const String nome = 'Propofol';
  static const String idBulario = 'propofol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/propofol.json');
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
      conteudo: _buildCardPropofol(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Propofol não é recomendado em neonatos
    return faixaEtaria != 'Neonato';
  }

  static Widget _buildCardPropofol(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Anestésico Geral Intravenoso - Hipnótico Sedativo',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPropofol._linhaPreparo(
            '• Ampola/Frasco 10 mg/mL (10 mL, 20 mL, 50 mL, 100 mL)'),
        MedicamentoPropofol._linhaPreparo(
            '• Emulsão lipídica estéril (óleo soja, lecitina, glicerol)'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPropofol._linhaPreparo(
            '• Usar direto do frasco (não diluir)'),
        MedicamentoPropofol._linhaPreparo('• Agitar suavemente antes do uso'),
        MedicamentoPropofol._linhaPreparo(
            '• Técnica asséptica rigorosa (emulsão lipídica)'),
        MedicamentoPropofol._linhaPreparo('• Descartar em 6h após abertura'),
        const SizedBox(height: 16),
        const Text('Indicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPropofol._buildConversorInfusao(peso, faixaEtaria),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPropofol._textoObs(
            '• Causa hipotensão e bradicardia (dose-dependente)'),
        MedicamentoPropofol._textoObs(
            '• Dor à injeção (usar veia calibrosa, pré-tratar com lidocaína)'),
        MedicamentoPropofol._textoObs(
            '• Descartar frasco 6h após abertura (risco de contaminação)'),
        MedicamentoPropofol._textoObs(
            '• Contraindicado em alergia a ovo, soja ou amendoim'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(
      String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Lactente':
      case 'Criança':
        indicacoes.addAll([
          MedicamentoPropofol._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica (>3 anos)',
            descricaoDose: 'Dose: 2,5-3,5 mg/kg IV lento',
            unidade: 'mg',
            dosePorKgMinima: 2.5,
            dosePorKgMaxima: 3.5,
            peso: peso,
          ),
          MedicamentoPropofol._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação para procedimentos',
            descricaoDose: 'Dose: 1-2 mg/kg IV',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
          ),
        ]);
        break;
      case 'Adolescente':
      case 'Adulto':
        indicacoes.addAll([
          MedicamentoPropofol._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica',
            descricaoDose: 'Dose: 1,5-2,5 mg/kg IV lento (30-60 segundos)',
            unidade: 'mg',
            dosePorKgMinima: 1.5,
            dosePorKgMaxima: 2.5,
            peso: peso,
          ),
          MedicamentoPropofol._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação para procedimentos',
            descricaoDose: 'Dose: 0,5-1 mg/kg IV lento',
            unidade: 'mg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1,
            peso: peso,
          ),
        ]);
        break;
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoPropofol._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica (reduzir dose)',
            descricaoDose: 'Dose: 1-1,5 mg/kg IV lento (redução de 30-50%)',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 1.5,
            peso: peso,
          ),
          MedicamentoPropofol._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação para procedimentos',
            descricaoDose: 'Dose: 0,5-1 mg/kg IV lento',
            unidade: 'mg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1,
            peso: peso,
          ),
        ]);
        break;
    }

    return indicacoes;
  }

  static Widget _buildConversorInfusao(double peso, String faixaEtaria) {
    final opcoesConcentracoes = {
      '200mg em 100mL SF 0,9% (2 mg/mL)': 2.0,
      '500mg em 50mL SF 0,9% (10 mg/mL)': 10.0,
      '1000mg em 100mL SF 0,9% (10 mg/mL)': 10.0,
    };

    double doseMin;
    double doseMax;

    switch (faixaEtaria) {
      case 'Lactente':
      case 'Criança':
        doseMin = 1.0;
        doseMax = 15.0;
        break;
      case 'Adolescente':
      case 'Adulto':
        doseMin = 0.3;
        doseMax = 12.0;
        break;
      case 'Idoso':
        doseMin = 0.3;
        doseMax = 6.0;
        break;
      default:
        doseMin = 0.3;
        doseMax = 12.0;
    }

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mg/kg/h',
      doseMin: doseMin,
      doseMax: doseMax,
    );
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
          '${doseCalculada.toStringAsFixed(1)} ${unidade?.replaceAll('/kg', '')}';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} ${unidade?.replaceAll('/kg', '')}';
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
                'Dose: $textoDose',
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

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(texto, style: const TextStyle(fontSize: 14)),
    );
  }
}
