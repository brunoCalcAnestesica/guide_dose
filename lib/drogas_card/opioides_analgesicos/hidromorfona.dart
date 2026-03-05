import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoHidromorfona {
  static const String nome = 'Hidromorfona';
  static const String idBulario = 'hidromorfona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/hidromorfona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isIdoso = faixaEtaria == 'Idoso';

    // Hidromorfona tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardHidromorfona(
        context,
        peso,
        isAdulto,
        isIdoso,
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
    final isIdoso = faixaEtaria == 'Idoso';

    return _buildCardHidromorfona(
      context,
        peso,
        isAdulto,
        isIdoso,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardHidromorfona(
      BuildContext context,
      double peso,
      bool isAdulto,
      bool isIdoso,
      bool isFavorito,
      VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _alertaControlado(),
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Opioide', 'Agonista mu semissintético'),
        _linhaPreparo('Potência', '~5-7x morfina (parenteral)'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Ampola 2mg/mL (1mL)', 'Dilaudid®'),
        _linhaPreparo('Ampola 10mg/mL (1mL)', 'Alta concentração'),
        _linhaPreparo('Comprimido 2mg, 4mg, 8mg', 'Liberação imediata'),
        _linhaPreparo(
            'Comprimido liberação prolongada', '8mg, 12mg, 16mg, 32mg'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Bolus IV', 'Diluir em 5mL SF, administrar em 2-3 min'),
        _linhaPreparo('Infusão', 'Diluir em 100-500mL SF ou SG 5%'),
        _linhaPreparo('SC/IM', 'Usar direto da ampola'),
        const SizedBox(height: 16),
        _conversaoOpioides(),
        const SizedBox(height: 16),
        const Text('Indicações e Doses',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor moderada a grave (bolus IV)',
            descricaoDose: isIdoso
                ? '5-10 mcg/kg IV (máx 1 mg) - IDOSO'
                : '10-20 mcg/kg IV (máx 2 mg)',
            unidade: 'mcg',
            dosePorKgMinima: isIdoso ? 5 : 10,
            dosePorKgMaxima: isIdoso ? 10 : 20,
            peso: peso,
            doseMaxima: isIdoso ? 1000 : 2000,
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'PCA (Patient-Controlled Analgesia)',
            descricaoDose: '0,2-0,4 mg IV por demanda',
            doseFixa: '0,2-0,4 mg (lockout 6-10 min)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor crônica (VO liberação imediata)',
            descricaoDose: '2-4 mg VO a cada 4-6h',
            doseFixa: '2-4 mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Dor crônica (VO liberação prolongada)',
            descricaoDose: '8-32 mg VO a cada 24h',
            doseFixa: '8-32 mg/dia',
          ),
          _textoObsDestaque('NÃO triturar formulação de liberação prolongada'),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor pediátrica (bolus IV)',
            descricaoDose: '10-15 mcg/kg IV a cada 4-6h (máx 1 mg)',
            unidade: 'mcg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 15,
            peso: peso,
            doseMaxima: 1000,
          ),
          _linhaIndicacaoDoseCalculada(
            titulo: 'Dor pediátrica (VO)',
            descricaoDose: '30-80 mcg/kg VO a cada 4-6h',
            unidade: 'mcg',
            dosePorKgMinima: 30,
            dosePorKgMaxima: 80,
            peso: peso,
          ),
        ],
        if (isIdoso) ...[
          const SizedBox(height: 16),
          _alertaIdoso(),
        ],
        const SizedBox(height: 16),
        const Text('Farmacocinética',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início IV: 5 minutos'),
        _textoObs('Início VO: 15-30 minutos'),
        _textoObs('Pico IV: 10-20 minutos'),
        _textoObs('Pico VO: 30-60 minutos'),
        _textoObs('Duração: 4-5 horas'),
        _textoObs('Meia-vida: 2-3 horas'),
        _textoObs('Metabolismo hepático (glicuronidação)'),
        _textoObs('Sem metabólitos ativos clinicamente significativos'),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObsDestaque('RECEITA AMARELA (A1) - Controlado'),
        _textoObs('Mais potente que morfina'),
        _textoObs('Útil em insuficiência renal (sem metabólitos ativos)'),
        _textoObs('Menos histaminoliberação que morfina'),
        _textoObs('Associar laxativo profilaticamente'),
        _textoObs('Naloxona para reversão'),
        _textoObs('Categoria C na gravidez'),
        const SizedBox(height: 16),
        const Text('Contraindicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObsDestaque('Depressão respiratória'),
        _textoObs('Íleo paralítico'),
        _textoObs('Asma aguda'),
        _textoObs('Hipersensibilidade'),
      ],
    );
  }

  static Widget _alertaControlado() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MEDICAMENTO CONTROLADO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Receita amarela (A1)\nAlto potencial de dependência',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _alertaIdoso() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATENÇÃO - PACIENTE IDOSO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reduzir dose em 25-50%\nTitular lentamente',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _conversaoOpioides() {
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
          Text('Equivalência aproximada:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 4),
          Text('• Hidromorfona 1,5 mg IV ≈ Morfina 10 mg IV',
              style: TextStyle(fontSize: 12)),
          Text('• Hidromorfona 4 mg VO ≈ Morfina 20 mg VO',
              style: TextStyle(fontSize: 12)),
          Text('• Hidromorfona : Morfina IV = 1 : 6-7',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;

    if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          Expanded(
            child: Text(texto,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
