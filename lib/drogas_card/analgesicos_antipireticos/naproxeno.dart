import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart' show buildMedicamentoExpansivel;
import '../../shared_data.dart';

class MedicamentoNaproxeno {
  static const String nome = 'Naproxeno';
  static const String idBulario = 'naproxeno';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/naproxeno.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardNaproxeno(
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

    return _buildCardNaproxeno(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardNaproxeno(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('AINE', 'Derivado do ácido propiônico'),
        _linhaPreparo('Inibidor não-seletivo COX-1/COX-2', 'Meia-vida longa'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimido 250mg, 500mg', 'Flanax®, Naprosyn®'),
        _linhaPreparo('Comprimido 550mg (naproxeno sódico)', 'Flanax®'),
        _linhaPreparo('Suspensão oral 25mg/mL', 'Pediátrico'),
        _linhaPreparo('Supositório 500mg', 'Retal'),
        
        // 3. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda - Adulto',
            descricaoDose: '500 mg inicial, depois 250 mg a cada 6-8h (máx 1250 mg/dia)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Artrite/Inflamação - Adulto',
            descricaoDose: '250-500 mg VO 2x/dia (máx 1500 mg/dia)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Gota aguda - Adulto',
            descricaoDose: '750 mg inicial, depois 250 mg a cada 8h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dismenorreia - Adulto',
            descricaoDose: '500 mg inicial, depois 250 mg a cada 6-8h',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor/Febre - Pediátrico (>2 anos)',
            descricaoDose: '5-7 mg/kg/dose VO a cada 8-12h (máx 1000 mg/dia)',
            unidade: 'mg',
            dosePorKgMinima: 5,
            dosePorKgMaxima: 7,
            doseMaxima: 500,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Artrite juvenil',
            descricaoDose: '10-15 mg/kg/dia dividido em 2 doses',
            unidade: 'mg/dia',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 15,
            doseMaxima: 1000,
            peso: peso,
          ),
        ],
        
        // 4. OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 1h | Pico: 2-4h | Duração: até 12h'),
        _textoObs('MEIA-VIDA LONGA: 12-17h (dose 2x/dia)'),
        _textoObs('Naproxeno sódico: absorção mais rápida'),
        _textoObs('CI: úlcera GI, IR/IH grave, gestação 3º tri'),
        _textoObs('Menor risco CV que outros AINEs (exceto AAS)'),
        _textoObs('Tomar com alimentos para reduzir irritação GI'),
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
    required double dosePorKgMinima,
    required double dosePorKgMaxima,
    double? doseMaxima,
    required double peso,
  }) {
    double doseMin = dosePorKgMinima * peso;
    double doseMax = dosePorKgMaxima * peso;
    bool doseLimite = false;
    
    if (doseMaxima != null && doseMax > doseMaxima) {
      doseMax = doseMaxima;
      doseLimite = true;
    }
    if (doseMin > doseMax) doseMin = doseMax;
    
    final textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';

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
                    'Dose limitada (máx ${doseMaxima?.toStringAsFixed(0)} $unidade)',
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
