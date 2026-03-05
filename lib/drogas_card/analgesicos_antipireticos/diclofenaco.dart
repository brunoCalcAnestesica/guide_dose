import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart' show buildMedicamentoExpansivel;
import '../../shared_data.dart';

class MedicamentoDiclofenaco {
  static const String nome = 'Diclofenaco';
  static const String idBulario = 'diclofenaco';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/diclofenaco.json');
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
      conteudo: _buildCardDiclofenaco(
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

    return _buildCardDiclofenaco(
      context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardDiclofenaco(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('AINE', 'Derivado do ácido fenilacético'),
        _linhaPreparo('Inibidor não-seletivo COX-1/COX-2', 'Analgésico e anti-inflamatório'),
        
        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 75mg/3mL (25mg/mL)', 'Voltaren®, Cataflan®'),
        _linhaPreparo('Comprimido 50mg', 'Liberação imediata'),
        _linhaPreparo('Comprimido 75mg, 100mg', 'Liberação prolongada'),
        _linhaPreparo('Supositório 50mg, 100mg', 'Retal'),
        _linhaPreparo('Gel 1%', 'Uso tópico'),
        
        // 3. PREPARO
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('IV: diluir 75mg em 100-500mL SF/SG', 'Infundir em 30-120 min'),
        _linhaPreparo('IM: sem diluição', 'Injeção profunda no glúteo (preferencial)'),
        _linhaPreparo('Não misturar com outras drogas', 'Incompatibilidade'),
        
        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda - Adulto IM',
            descricaoDose: '75 mg IM 1-2x/dia (máx 150 mg/dia por 2 dias)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda - Adulto IV',
            descricaoDose: '75 mg IV infusão lenta (máx 150 mg/dia)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor crônica - Adulto VO',
            descricaoDose: '50 mg VO 2-3x/dia ou 75-100 mg 1x/dia (máx 150 mg/dia)',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor/Inflamação - Pediátrico (>1 ano)',
            descricaoDose: '1 mg/kg IM dose única ou 0,5-2 mg/kg/dia VO dividido 2-3x',
            unidade: 'mg',
            dosePorKg: 1,
            doseMaxima: 75,
            peso: peso,
          ),
        ],
        
        // 5. OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 15-30 min IM/IV | Duração: 8h'),
        _textoObs('IM: usar apenas por 2 dias, depois passar VO'),
        _textoObs('CI: úlcera GI ativa, IR/IH grave, gestação 3º tri'),
        _textoObs('RISCO CARDIOVASCULAR: evitar em cardiopatas'),
        _textoObs('Cautela em asma, hipertensão, idosos'),
        _textoObs('Interação com anticoagulantes, diuréticos, lítio'),
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
    
    final textoDose = '${doseCalc.toStringAsFixed(0)} $unidade';

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
