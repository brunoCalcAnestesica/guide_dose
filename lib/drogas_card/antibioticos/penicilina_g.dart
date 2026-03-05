import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPenicilinaG {
  static const String nome = 'Penicilina G';
  static const String idBulario = 'penicilina_g';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/penicilina_g.json');
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
      conteudo: _buildCardContent(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardContent(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardContent(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Penicilina natural (benzilpenicilina)'),
        _textoObs('Bactericida - inibe síntese da parede celular'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 1.000.000 UI', 'Penicilina G Cristalina'),
        _linhaPreparo('Frasco 5.000.000 UI', ''),
        _linhaPreparo('Frasco 10.000.000 UI', ''),

        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Reconstituir em água estéril', ''),
        _linhaPreparo('Diluir em 50-100mL SF ou SG 5%', ''),
        _linhaPreparo('Infusão em 15-30 min', ''),
        _linhaPreparo('ATENÇÃO: 1,7 mEq K+/milhão UI', 'Risco hipercalemia'),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Neurossífilis',
            descricaoDose: '18-24 milhões UI/dia IV dividido 4/4h por 10-14 dias',
            doseFixa: '3-4 milhões UI IV 4/4h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Endocardite estreptocócica',
            descricaoDose: '12-18 milhões UI/dia IV dividido 4/4h por 4-6 semanas',
            doseFixa: '2-3 milhões UI IV 4/4h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Meningite meningocócica/pneumocócica',
            descricaoDose: '20-24 milhões UI/dia IV dividido 4/4h',
            doseFixa: '4 milhões UI IV 4/4h',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Fasciíte necrosante (Streptococcus)',
            descricaoDose: '24 milhões UI/dia IV contínua ou 4/4h',
            doseFixa: '4 milhões UI IV 4/4h',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico - Infecções graves',
            descricaoDose: '200.000-400.000 UI/kg/dia IV dividido 4/4-6/6h',
            unidade: 'UI/dia',
            dosePorKgMinima: 200000,
            dosePorKgMaxima: 400000,
            peso: peso,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Neonato - Sífilis congênita',
            descricaoDose: '50.000 UI/kg IV 12/12h (1ª semana) → 8/8h',
            unidade: 'UI',
            dosePorKg: 50000,
            peso: peso,
          ),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro ESTREITO: Streptococcus, Neisseria, Treponema, Clostridium'),
        _textoObs('Droga de escolha: sífilis, faringite estreptocócica, febre reumática'),
        _textoObs('ATENÇÃO: contém potássio (1,7 mEq K+/milhão UI)'),
        _textoObs('Ajuste renal: ClCr <10 → máx 10 milhões UI/dia'),
        _textoObs('Meia-vida curta: requer doses frequentes (4/4h)'),
        _textoObs('CONTRAINDICADO: alergia a penicilinas'),
        _textoObs('Reação de Jarisch-Herxheimer possível no tratamento de sífilis'),
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
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
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
              'Dose: $doseFixa',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13),
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
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    required double peso,
  }) {
    String? textoDose;
    if (dosePorKg != null) {
      double dose = dosePorKg * peso;
      textoDose = '${dose.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
          if (textoDose != null) ...[
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
                'Dose calculada: $textoDose',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13),
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
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
