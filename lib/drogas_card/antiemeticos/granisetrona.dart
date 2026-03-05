import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoGranisetrona {
  static const String nome = 'Granisetrona';
  static const String idBulario = 'granisetrona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/granisetrona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Granisetrona tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardGranisetrona(
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

    return _buildCardGranisetrona(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardGranisetrona(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGranisetrona._textoObs(
            'Antiemético - Antagonista seletivo dos receptores 5-HT3'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGranisetrona._linhaPreparo('Ampola 1mg/1mL (1mg/mL)', ''),
        MedicamentoGranisetrona._linhaPreparo('Ampola 3mg/3mL (1mg/mL)', ''),
        MedicamentoGranisetrona._linhaPreparo('Comprimido 1mg', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGranisetrona._linhaPreparo(
            'Bolus IV', 'Usar direto da ampola em 2-5 minutos'),
        MedicamentoGranisetrona._linhaPreparo('Infusão IV',
            'Diluir em 20-50mL SF 0,9% ou SG 5%, infundir em 5-30 min'),
        MedicamentoGranisetrona._linhaPreparo(
            'Via oral', 'Comprimido com ou sem alimentos'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoGranisetrona._linhaIndicacaoDoseFixa(
            titulo: 'Náuseas/vômitos por quimioterapia',
            descricaoDose: '1-3mg IV dose única, 30min antes da quimioterapia',
            doseFixa: '1-3 mg',
          ),
          MedicamentoGranisetrona._linhaIndicacaoDoseFixa(
            titulo: 'Náuseas/vômitos pós-operatórios (prevenção)',
            descricaoDose: '1mg IV antes da indução anestésica',
            doseFixa: '1 mg',
          ),
          MedicamentoGranisetrona._linhaIndicacaoDoseFixa(
            titulo: 'Náuseas/vômitos pós-operatórios (tratamento)',
            descricaoDose: '1mg IV em dose única',
            doseFixa: '1 mg',
          ),
          MedicamentoGranisetrona._linhaIndicacaoDoseFixa(
            titulo: 'Náuseas/vômitos por radioterapia',
            descricaoDose: '1mg IV antes da radioterapia',
            doseFixa: '1 mg',
          ),
        ] else ...[
          MedicamentoGranisetrona._linhaIndicacaoDoseCalculada(
            titulo: 'Náuseas/vômitos pediátricos (>2 anos)',
            descricaoDose:
                '10-40 mcg/kg (0,01-0,04 mg/kg) IV dose única (máx 1mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.04,
            peso: peso,
            doseMaxima: 1.0,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGranisetrona._textoObs('Início de ação: 5-10 minutos'),
        MedicamentoGranisetrona._textoObs('Pico de efeito: 30-60 minutos'),
        MedicamentoGranisetrona._textoObs('Duração: 24 horas (dose única)'),
        MedicamentoGranisetrona._textoObs('Meia-vida: 4-9 horas'),
        MedicamentoGranisetrona._textoObs(
            'Antagonista seletivo de receptores 5-HT3'),
        MedicamentoGranisetrona._textoObs(
            'Bloqueio periférico (trato GI) e central (área postrema)'),
        MedicamentoGranisetrona._textoObs('Mais eficaz que ondansetrona'),
        MedicamentoGranisetrona._textoObs(
            'Controle antiemético prolongado com dose única'),
        MedicamentoGranisetrona._textoObs('Não causa sedação significativa'),
        MedicamentoGranisetrona._textoObs(
            'Administrar bolus LENTO (2-5 minutos)'),
        MedicamentoGranisetrona._textoObs(
            'Dose máxima adultos: 3mg/dose; 9mg/dia'),
        MedicamentoGranisetrona._textoObs('Dose máxima pediátrica: 1mg/dose'),
        MedicamentoGranisetrona._textoObs(
            'Efeitos adversos: cefaleia (mais comum), constipação'),
        MedicamentoGranisetrona._textoObs('Leve prolongamento do intervalo QT'),
        MedicamentoGranisetrona._textoObs(
            'Menor risco de prolongamento QT que ondansetrona'),
        MedicamentoGranisetrona._textoObs(
            'Monitorar ECG em pacientes de risco'),
        MedicamentoGranisetrona._textoObs(
            'Cautela em cardiopatas ou uso de antiarrítmicos'),
        MedicamentoGranisetrona._textoObs('CONTRAINDICADO com apomorfina'),
        MedicamentoGranisetrona._textoObs(
            'Risco de hipotensão severa com apomorfina'),
        MedicamentoGranisetrona._textoObs(
            'Cautela com outros fármacos que prolongam QT'),
        MedicamentoGranisetrona._textoObs(
            'Inibidores CYP3A4 aumentam níveis séricos'),
        MedicamentoGranisetrona._textoObs('Indutores CYP3A4 reduzem eficácia'),
        MedicamentoGranisetrona._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoGranisetrona._textoObs(
            'Incompatível com soluções alcalinas'),
        MedicamentoGranisetrona._textoObs(
            'Monitorar função hepática em uso prolongado'),
        MedicamentoGranisetrona._textoObs('Categoria B na gravidez'),
        MedicamentoGranisetrona._textoObs(
            'Contraindicado em prolongamento QT congênito'),
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
      textoDose = '${doseCalculada.toStringAsFixed(2)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
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
