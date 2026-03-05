import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPalonosetrona {
  static const String nome = 'Palonosetrona';
  static const String idBulario = 'palonosetrona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/palonosetrona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Palonosetrona tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardPalonosetrona(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return _buildCardPalonosetrona(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardPalonosetrona(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Antiemético - Antagonista seletivo 5-HT3 de 2ª geração'),
        _textoObs('Maior afinidade e meia-vida longa vs ondansetrona'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 0,25mg/5mL (0,05mg/mL)', 'Aloxi®'),
        _linhaPreparo('Cápsula 0,5mg', 'Aloxi®'),
        const SizedBox(height: 16),
        _vantagensPalonosetrona(),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Bolus IV', 'Administrar em 30 segundos'),
        _linhaPreparo('Diluição opcional', 'Até 50mL SF 0,9% ou SG 5%'),
        _linhaPreparo('Via oral', 'Cápsula 1h antes da quimioterapia'),
        const SizedBox(height: 16),
        const Text('Indicações e Doses',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Quimioterapia (prevenção NVIQ)',
            descricaoDose: '0,25mg IV dose única, 30min antes',
            doseFixa: '0,25mg (250mcg)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Quimioterapia (via oral)',
            descricaoDose: '0,5mg VO dose única, 1h antes',
            doseFixa: '0,5mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'NVPO (prevenção pós-operatória)',
            descricaoDose: '0,075mg IV dose única, na indução',
            doseFixa: '0,075mg (75mcg)',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico (1 mês - 17 anos)',
            descricaoDose: '20mcg/kg IV dose única (máx 1,5mg)',
            unidade: 'mcg',
            dosePorKg: 20,
            peso: peso,
            doseMaxima: 1500,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Farmacocinética',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início de ação: 30 minutos'),
        _textoObsDestaque('Meia-vida: 40 horas (muito longa!)'),
        _textoObs('Duração do efeito: até 5 dias (dose única)'),
        _textoObs('Ligação proteica: 62%'),
        _textoObs('Metabolismo: CYP2D6 (50%), CYP3A4, CYP1A2'),
        _textoObs('Excreção: Renal (80%) e fecal'),
        const SizedBox(height: 16),
        _comparacao5HT3(),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Dose única eficaz por vários dias'),
        _textoObs('Não repetir dose no mesmo ciclo de quimioterapia'),
        _textoObs('Eficaz tanto na fase aguda quanto tardia'),
        _textoObs('Efeitos adversos: cefaleia, constipação'),
        _textoObs('Prolongamento QTc (menor que outros 5-HT3)'),
        _textoObs('Categoria B na gravidez'),
        const SizedBox(height: 16),
        const Text('Contraindicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Hipersensibilidade ao fármaco'),
        _textoObs('Síndrome do QT longo congênito'),
        _textoObsDestaque('CONTRAINDICADO com apomorfina'),
      ],
    );
  }

  static Widget _vantagensPalonosetrona() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vantagens da Palonosetrona:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 4),
          Text('• Meia-vida 40h (vs 4-9h da ondansetrona)',
              style: TextStyle(fontSize: 12)),
          Text('• Dose única cobre todo o ciclo',
              style: TextStyle(fontSize: 12)),
          Text('• Maior afinidade pelo receptor 5-HT3',
              style: TextStyle(fontSize: 12)),
          Text('• Eficaz na êmese tardia (24-120h)',
              style: TextStyle(fontSize: 12)),
          Text('• Menor potencial de prolongamento QT',
              style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static Widget _comparacao5HT3() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Comparação com outros 5-HT3:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 8),
          Text('Meia-vida:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text('• Palonosetrona: 40 horas', style: TextStyle(fontSize: 12)),
          Text('• Granisetrona: 4-9 horas', style: TextStyle(fontSize: 12)),
          Text('• Ondansetrona: 3-6 horas', style: TextStyle(fontSize: 12)),
          SizedBox(height: 4),
          Text('Afinidade receptor 5-HT3:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text('• Palonosetrona: 100x maior que ondansetrona',
              style: TextStyle(fontSize: 12)),
        ],
      ),
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
                    const TextSpan(
                        text: ' | ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: marca,
                        style: const TextStyle(fontStyle: FontStyle.italic)),
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
          Text(titulo,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? dosePorKg,
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
          if (textoDose != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }

  static Widget _textoObsDestaque(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          Expanded(
            child: Text(texto,
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
