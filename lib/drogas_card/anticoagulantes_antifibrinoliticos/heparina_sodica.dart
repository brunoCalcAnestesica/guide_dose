import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoHeparinaSodica {
  static const String nome = 'Heparina Sódica';
  static const String idBulario = 'heparina_sodica';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/heparina_sodica.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Heparina tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardHeparinaSodica(
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

    return _buildCardHeparinaSodica(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardHeparinaSodica(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHeparinaSodica._textoObs(
            'Anticoagulante parenteral - Heparina não fracionada (HNF)'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHeparinaSodica._linhaPreparo('Ampola 5000 UI/mL', ''),
        MedicamentoHeparinaSodica._linhaPreparo('Ampola 10000 UI/mL', ''),
        MedicamentoHeparinaSodica._linhaPreparo('Frasco 25000 UI/5mL', ''),
        MedicamentoHeparinaSodica._linhaPreparo(
            'Frasco 25000 UI/250mL (100 UI/mL)', 'Infusão contínua'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHeparinaSodica._linhaPreparo(
            'Profilaxia SC', 'Usar direto da ampola'),
        MedicamentoHeparinaSodica._linhaPreparo(
            'Bolus IV', 'Diluir em 10-20mL SF 0,9%'),
        MedicamentoHeparinaSodica._linhaPreparo('Infusão contínua',
            'Diluir dose prescrita em 50-500mL SF 0,9% ou SG 5%'),
        MedicamentoHeparinaSodica._linhaPreparo(
            'Bomba de infusão', 'Obrigatória para infusão contínua'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoHeparinaSodica._linhaIndicacaoDoseFixa(
            titulo: 'Profilaxia de TVP/TEP',
            descricaoDose: '5000 UI SC a cada 8-12h',
            doseFixa: '5000 UI',
          ),
          MedicamentoHeparinaSodica._linhaIndicacaoDoseCalculada(
            titulo: 'Anticoagulação plena (bolus)',
            descricaoDose: '60-70 UI/kg IV (máx 5000 UI)',
            unidade: 'UI',
            dosePorKgMinima: 60,
            dosePorKgMaxima: 70,
            peso: peso,
            doseMaxima: 5000,
          ),
          MedicamentoHeparinaSodica._linhaIndicacaoDoseFixa(
            titulo: 'Trombólise assistida (bolus)',
            descricaoDose: '5000 UI IV',
            doseFixa: '5000 UI',
          ),
        ] else ...[
          MedicamentoHeparinaSodica._linhaIndicacaoDoseCalculada(
            titulo: 'Anticoagulação pediátrica (bolus)',
            descricaoDose: '75-100 UI/kg IV',
            unidade: 'UI',
            dosePorKgMinima: 75,
            dosePorKgMaxima: 100,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHeparinaSodica._textoObs('Início de ação: IMEDIATO (IV)'),
        MedicamentoHeparinaSodica._textoObs('Início SC: 20-60 minutos'),
        MedicamentoHeparinaSodica._textoObs('Duração IV: 4-6 horas'),
        MedicamentoHeparinaSodica._textoObs('Duração SC: 8-12 horas'),
        MedicamentoHeparinaSodica._textoObs(
            'Meia-vida: 30-150 minutos (dose-dependente)'),
        MedicamentoHeparinaSodica._textoObs('Cofator da antitrombina III'),
        MedicamentoHeparinaSodica._textoObs(
            'Inibe fatores IIa (trombina) e Xa'),
        MedicamentoHeparinaSodica._textoObs(
            'Acelera antitrombina em até 1000x'),
        MedicamentoHeparinaSodica._textoObs('REVERSÍVEL com protamina'),
        MedicamentoHeparinaSodica._textoObs(
            'Monitorar TTPa (objetivo: 1,5-2,5x o controle)'),
        MedicamentoHeparinaSodica._textoObs(
            'TTPa a cada 6h até estável, depois a cada 24h'),
        MedicamentoHeparinaSodica._textoObs(
            'Contraindicado IM (risco de hematoma)'),
        MedicamentoHeparinaSodica._textoObs('Bomba de infusão obrigatória'),
        MedicamentoHeparinaSodica._textoObs('RISCO: sangramento'),
        MedicamentoHeparinaSodica._textoObs(
            'RISCO: trombocitopenia induzida (HIT tipo II)'),
        MedicamentoHeparinaSodica._textoObs(
            'Monitorar plaquetas a cada 2-3 dias'),
        MedicamentoHeparinaSodica._textoObs(
            'Suspeitar HIT se queda >50% plaquetas'),
        MedicamentoHeparinaSodica._textoObs(
            'Se HIT confirmada: suspender IMEDIATAMENTE'),
        MedicamentoHeparinaSodica._textoObs(
            'Observar sinais de sangramento contínuo'),
        MedicamentoHeparinaSodica._textoObs(
            'Protamina disponível para reversão'),
        MedicamentoHeparinaSodica._textoObs(
            'Potencializa sangramento com AINEs'),
        MedicamentoHeparinaSodica._textoObs(
            'Potencializa sangramento com antiagregantes'),
        MedicamentoHeparinaSodica._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoHeparinaSodica._textoObs(
            'Incompatível com soluções alcalinas'),
        MedicamentoHeparinaSodica._textoObs(
            'Segura na gravidez (não atravessa placenta)'),
        MedicamentoHeparinaSodica._textoObs('Segura na lactação'),
        MedicamentoHeparinaSodica._textoObs(
            'Contraindicado em sangramento ativo'),
        MedicamentoHeparinaSodica._textoObs('Contraindicado em HIT prévia'),
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
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 13,
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
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
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 13,
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
}
