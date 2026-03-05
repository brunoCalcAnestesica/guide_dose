import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart' show buildMedicamentoExpansivel;
import '../../shared_data.dart';

class MedicamentoCetorolaco {
  static const String nome = 'Cetorolaco';
  static const String idBulario = 'cetorolaco';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/cetorolaco.json');
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
      conteudo: _buildCardCetorolaco(
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

    return _buildCardCetorolaco(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardCetorolaco(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('AINE', 'Derivado do ácido pirrolizina-carboxílico'),
        _linhaPreparo('Inibidor não-seletivo COX-1/COX-2', 'Potente analgésico'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 30mg/mL (1mL)', 'Toradol®, Toragesic®'),
        _linhaPreparo('Ampola 10mg/mL (1mL)', 'Apresentação pediátrica'),
        _linhaPreparo('Comprimido 10mg', 'VO'),
        _linhaPreparo('Comprimido sublingual 10mg', 'Toragesic SL®'),
        
        // 3. PREPARO
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('IV: puro ou diluído em SF/SG', 'Infusão em 15 segundos ou mais'),
        _linhaPreparo('IM: sem diluição', 'Injeção profunda no músculo'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda moderada/severa - Adulto',
            descricaoDose: '30 mg IV/IM dose única ou 30 mg a cada 6h (máx 120 mg/dia)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda - Idoso (>65 anos)',
            descricaoDose: '15 mg IV/IM a cada 6h (máx 60 mg/dia)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda - VO (após IV/IM)',
            descricaoDose: '10 mg VO a cada 4-6h (máx 40 mg/dia)',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor aguda - Pediátrico (>2 anos)',
            descricaoDose: '0,5 mg/kg IV/IM dose única (máx 30 mg)',
            unidade: 'mg',
            dosePorKg: 0.5,
            doseMaxima: 30,
            peso: peso,
          ),
        ],
        
        // 5. OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 10-30 min IV | Duração: 4-6h'),
        _textoObs('USO MÁXIMO: 5 dias (risco GI/renal aumentado)'),
        _textoObs('CI: úlcera GI ativa, IR grave, gestação 3º tri'),
        _textoObs('CI: cirurgia com alto risco de sangramento'),
        _textoObs('Cautela em hipovolemia, HAS, ICC, hepatopatia'),
        _textoObs('Equivalência: 30mg cetorolaco ≈ 10mg morfina'),
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
    
    final textoDose = '${doseCalc.toStringAsFixed(1)} $unidade';

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
                    'Dose limitada (máx ${doseMaxima?.toStringAsFixed(0)} mg)',
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
