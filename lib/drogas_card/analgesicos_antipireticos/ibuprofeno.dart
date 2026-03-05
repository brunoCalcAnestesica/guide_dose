import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart' show buildMedicamentoExpansivel;
import '../../shared_data.dart';

class MedicamentoIbuprofeno {
  static const String nome = 'Ibuprofeno';
  static const String idBulario = 'ibuprofeno';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/ibuprofeno.json');
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
      conteudo: _buildCardIbuprofeno(
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

    return _buildCardIbuprofeno(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardIbuprofeno(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('AINE', 'Derivado do ácido propiônico'),
        _linhaPreparo('Inibidor não-seletivo COX-1/COX-2', 'Analgésico, antipirético, anti-inflamatório'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 400mg/4mL (100mg/mL)', 'Caldolor® IV'),
        _linhaPreparo('Frasco 800mg/8mL (100mg/mL)', 'Caldolor® IV'),
        _linhaPreparo('Comprimido 200mg, 400mg, 600mg', 'Advil®, Alivium®'),
        _linhaPreparo('Suspensão 50mg/mL, 100mg/5mL', 'Pediátrico'),
        _linhaPreparo('Gotas 50mg/mL', 'Pediátrico'),
        
        // 3. PREPARO
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('IV: diluir 400mg em 100mL SF/SG', 'Infundir em 30 min'),
        _linhaPreparo('IV: diluir 800mg em 200mL SF/SG', 'Infundir em 30 min'),
        _linhaPreparo('Concentração mínima: 4mg/mL', 'Para infusão'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor/Febre - Adulto IV',
            descricaoDose: '400-800 mg IV a cada 6h (máx 3200 mg/dia)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor/Febre - Adulto VO',
            descricaoDose: '200-400 mg VO a cada 4-6h (máx 1200 mg/dia OTC)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Anti-inflamatório - Adulto VO',
            descricaoDose: '400-800 mg VO a cada 6-8h (máx 3200 mg/dia)',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor/Febre - Pediátrico (>6 meses)',
            descricaoDose: '5-10 mg/kg/dose VO a cada 6-8h (máx 40 mg/kg/dia)',
            unidade: 'mg',
            dosePorKgMinima: 5,
            dosePorKgMaxima: 10,
            doseMaxima: 400,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor/Febre - Pediátrico IV (>6 meses)',
            descricaoDose: '10 mg/kg IV a cada 4-6h (máx 400 mg/dose)',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 10,
            doseMaxima: 400,
            peso: peso,
          ),
        ],
        
        // 5. OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 30 min VO / 15 min IV | Duração: 4-6h'),
        _textoObs('Perfil de segurança favorável entre AINEs'),
        _textoObs('CI: úlcera GI ativa, IR grave, gestação 3º tri'),
        _textoObs('Cautela em asma, HAS, ICC, hepatopatia'),
        _textoObs('Fechamento PCA em neonatos: uso específico'),
        _textoObs('Interação com AAS (reduz efeito cardioprotetor)'),
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
