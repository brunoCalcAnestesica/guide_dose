import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart' show buildMedicamentoExpansivel;
import '../../shared_data.dart';

class MedicamentoMeloxicam {
  static const String nome = 'Meloxicam';
  static const String idBulario = 'meloxicam';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/meloxicam.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Meloxicam: uso limitado em pediatria
    if (!isAdulto && (faixaEtaria == 'Recém-nascido' || faixaEtaria == 'Lactente')) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMeloxicam(
        context,
        peso,
        faixaEtaria,
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

    return _buildCardMeloxicam(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardMeloxicam(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('AINE', 'Derivado oxicam (enólico)'),
        _linhaPreparo('Inibidor COX-2 preferencial', 'Menor toxicidade GI'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimido 7,5mg, 15mg', 'Movatec®, Meloxil®'),
        _linhaPreparo('Ampola 15mg/1,5mL (10mg/mL)', 'IM'),
        _linhaPreparo('Suspensão oral 7,5mg/5mL', 'Pediátrico'),
        _linhaPreparo('Supositório 15mg', 'Retal'),
        
        // 3. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda - Adulto',
            descricaoDose: '7,5-15 mg VO 1x/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Osteoartrite - Adulto',
            descricaoDose: '7,5 mg VO 1x/dia (pode aumentar para 15 mg se necessário)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Artrite reumatoide - Adulto',
            descricaoDose: '15 mg VO 1x/dia (reduzir para 7,5 mg após controle)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda - Adulto IM',
            descricaoDose: '15 mg IM 1x/dia (máx 1-2 dias, depois passar VO)',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Artrite juvenil (>2 anos)',
            descricaoDose: '0,125 mg/kg/dia VO 1x/dia (máx 7,5 mg/dia)',
            unidade: 'mg',
            dosePorKg: 0.125,
            doseMaxima: 7.5,
            peso: peso,
          ),
        ],
        
        // 4. OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 1-2h | Pico: 5-6h | Duração: 24h'),
        _textoObs('MEIA-VIDA LONGA: 15-20h (dose única diária)'),
        _textoObs('COX-2 preferencial: menor risco GI que AINEs clássicos'),
        _textoObs('CI: úlcera GI ativa, IR grave, gestação 3º tri'),
        _textoObs('Cautela em cardiopatia, HAS, idosos'),
        _textoObs('Dose máxima: 15 mg/dia (não aumenta eficácia)'),
      ],
    );
  }

  static Widget _linhaIndicacaoDoseFixa({
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              descricaoDose,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    required String unidade,
    required double dosePorKg,
    double? doseMaxima,
    required double peso,
  }) {
    double doseCalc = dosePorKg * peso;
    bool doseLimite = false;
    
    if (doseMaxima != null && doseCalc > doseMaxima) {
      doseCalc = doseMaxima;
      doseLimite = true;
    }
    
    final textoDose = '${doseCalc.toStringAsFixed(2)} $unidade';

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
              color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Dose calculada: $textoDose',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (doseLimite) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Dose limitada (máx ${doseMaxima?.toStringAsFixed(1)} mg)',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
