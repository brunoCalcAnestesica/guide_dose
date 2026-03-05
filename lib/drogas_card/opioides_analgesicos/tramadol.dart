import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoTramadol {
  static const String nome = 'Tramadol';
  static const String idBulario = 'tramadol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/tramadol.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  // Função para verificar se tem indicações para a faixa etária selecionada
  static bool _temIndicacoesParaFaixaEtaria() {
    final faixaEtaria = SharedData.faixaEtaria;
    // Tramadol é contraindicado <12 anos
    return faixaEtaria != 'Neonato' &&
        faixaEtaria != 'Lactente' &&
        faixaEtaria != 'Criança';
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    // Verificar se deve mostrar o card para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria()) {
      return const SizedBox.shrink();
    }

    final peso = SharedData.peso ?? 70;
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardTramadol(
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
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardTramadol(
      context,
      peso,
      isAdulto,
      isFavorito,
      () => onToggleFavorito(nome),
    );
  }

  static Widget _buildCardTramadol(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTramadol._textoObs(
            '• Opioide sintético fraco - Agonista μ-opioide - Inibidor recaptação 5-HT/NA'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTramadol._linhaPreparo(
            'Ampola 50mg/mL (1mL e 2mL)', 'Tramal® / Dorless®'),
        MedicamentoTramadol._linhaPreparo(
            'Início: 10-15 min IV / 30-60 min VO', 'Ação central dupla'),
        MedicamentoTramadol._linhaPreparo(
            'Pico: 0,5h IV / 1,5-2h VO', 'Duração: 6-8 horas'),
        MedicamentoTramadol._linhaPreparo(
            'Meia-vida: 5-6h (tramadol)', '6-8h (M1 ativo)'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTramadol._linhaPreparo(
            'IV bolus: 50-100mg lento ≥2 min', 'Pode usar direto da ampola'),
        MedicamentoTramadol._linhaPreparo(
            'IV infusão: diluir em 100mL SF/SG', 'Infundir em 15-30 min'),
        MedicamentoTramadol._linhaPreparo(
            'IM/SC: 50-100mg sem diluição', 'Pode ser doloroso'),
        MedicamentoTramadol._linhaPreparo(
            'Compatível: SF 0,9%, SG 5%', 'Incompatível: soluções alcalinas'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoTramadol._linhaIndicacaoDoseFixa(
            titulo: 'Dor moderada a intensa (pós-operatória, trauma)',
            descricaoDose: '50-100mg IV/IM/SC a cada 4-6h (máx 400mg/dia)',
            doseFixa: '50-100 mg',
          ),
          MedicamentoTramadol._linhaIndicacaoDoseFixa(
            titulo: 'Dor crônica (músculo-esquelética, neuropática)',
            descricaoDose: '50-100mg IV/IM a cada 6-8h (máx 400mg/dia)',
            doseFixa: '50-100 mg',
          ),
          MedicamentoTramadol._linhaIndicacaoDoseFixa(
            titulo: 'Idoso ≥75 anos',
            descricaoDose:
                '50mg IV/IM a cada 6-8h (máx 300mg/dia - reduzir dose)',
            doseFixa: '50 mg',
          ),
        ] else ...[
          MedicamentoTramadol._linhaIndicacaoDoseCalculada(
            titulo: 'Adolescente ≥12 anos - Dor moderada/intensa',
            descricaoDose: '1-2 mg/kg/dose IV/IM a cada 6-8h (máx 400mg/dia)',
            unidade: 'mg',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 2.0,
            doseMaxima: 100.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTramadol._textoObs(
            '• Mecanismo duplo: agonista μ-opioide fraco + inibição recaptação serotonina/noradrenalina'),
        MedicamentoTramadol._textoObs(
            '• Metabólito M1 (200x mais potente) - depende metabolismo CYP2D6'),
        MedicamentoTramadol._textoObs(
            '• Analgesia leve-moderada - eficácia similar codeína, menor que morfina'),
        MedicamentoTramadol._textoObs(
            '• Vantagem: menor depressão respiratória vs opioides puros'),
        MedicamentoTramadol._textoObs(
            '• Indicação: dor mista (nociceptiva + neuropática), pós-op leve-moderada'),
        MedicamentoTramadol._textoObs(
            '• CONTRAINDICADO: <12 anos, epilepsia não controlada, uso IMAO'),
        MedicamentoTramadol._textoObs(
            '• CONTRAINDICADO: <18 anos após adenoide/amigdalectomia'),
        MedicamentoTramadol._textoObs(
            '• ATENÇÃO: Risco CONVULSÕES (dose-dependente) - baixa limiar convulsivo'),
        MedicamentoTramadol._textoObs(
            '• ATENÇÃO: Síndrome serotoninérgica (ISRS, IMAO, triptanos, lítio)'),
        MedicamentoTramadol._textoObs(
            '• ATENÇÃO: Náusea (>10%), tontura, sudorese muito comuns'),
        MedicamentoTramadol._textoObs(
            '• Efeitos: constipação, cefaleia, sonolência, xerostomia'),
        MedicamentoTramadol._textoObs(
            '• Metabolizadores CYP2D6: ultrarrápidos (toxicidade), lentos (ineficaz)'),
        MedicamentoTramadol._textoObs(
            '• Interações: ISRS/IMAO (serotonina), bupropiona (convulsão), BDZ (sedação)'),
        MedicamentoTramadol._textoObs(
            '• Inibidores CYP2D6 (fluoxetina, paroxetina) reduzem analgesia'),
        MedicamentoTramadol._textoObs(
            '• Potencial dependência/tolerância (menor que opioides puros)'),
        MedicamentoTramadol._textoObs(
            '• Ajuste renal: ClCr <30 mL/min → intervalo 12h'),
        MedicamentoTramadol._textoObs(
            '• Ajuste hepático: hepatopatia grave é contraindicação'),
        MedicamentoTramadol._textoObs(
            '• Monitorar: dor, sedação, respiração, sinais convulsão/síndrome serotoninérgica'),
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
    String? textoDose;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
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
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade (máx ${doseMaxima?.toStringAsFixed(0)} $unidade/dose)';
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
      child: Text(
        texto,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
