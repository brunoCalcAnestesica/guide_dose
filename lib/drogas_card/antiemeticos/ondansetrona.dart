import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoOndansetrona {
  static const String nome = 'Ondansetrona';
  static const String idBulario = 'ondansetrona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/ondansetrona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardOndansetrona(
        context,
        peso,
        faixaEtaria,
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

    return _buildCardOndansetrona(
      context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardOndansetrona(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOndansetrona._textoObs('Antiemético, antagonista seletivo dos receptores 5-HT3 de serotonina'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOndansetrona._linhaPreparo('Comprimidos 4 mg, 8 mg', 'Uso oral'),
        MedicamentoOndansetrona._linhaPreparo('Comprimidos orodispersíveis 4 mg, 8 mg', 'Dissolvem na língua'),
        MedicamentoOndansetrona._linhaPreparo('Solução oral 4 mg/5 mL', 'Frasco 50 mL'),
        MedicamentoOndansetrona._linhaPreparo('Ampola 2 mg/mL (2 mL, 4 mL)', 'IV/IM'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOndansetrona._linhaPreparo('IV bolus: administrar lento 2-5 min', 'Direto da ampola'),
        MedicamentoOndansetrona._linhaPreparo('IV infusão: diluir em 50-100 mL SF 0,9% ou SG 5%', 'Infundir 15-30 min'),
        MedicamentoOndansetrona._linhaPreparo('IM: injeção profunda', 'Deltóide ou glúteo'),
        MedicamentoOndansetrona._linhaPreparo('VO: 30-60 min antes quimio/radioterapia', 'Com ou sem alimento'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOndansetrona._buildInfusaoContinua(peso, faixaEtaria),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoOndansetrona._textoObs('Antiemético de primeira linha em quimioterapia emetogênica'),
        MedicamentoOndansetrona._textoObs('ATENÇÃO: Dose única IV máxima 16 mg (risco prolongamento QTc/arritmias)'),
        MedicamentoOndansetrona._textoObs('Monitorar ECG em pacientes com risco cardiovascular'),
        MedicamentoOndansetrona._textoObs('Efeito colateral mais comum: cefaleia (9-27%) e constipação (6-11%)'),
        MedicamentoOndansetrona._textoObs('Sinergismo com dexametasona e aprepitante em quimio altamente emetogênica'),
        MedicamentoOndansetrona._textoObs('Contraindicado com apomorfina (hipotensão grave)'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Neonato':
      case 'Lactente':
        indicacoes.addAll([
          MedicamentoOndansetrona._linhaIndicacaoDoseCalculada(
            titulo: 'NVPO (>1 mês)',
            descricaoDose: 'Dose: 0,1 mg/kg IV dose única (máx 4 mg)',
            unidade: 'mg',
            dosePorKg: 0.1,
            doseMaxima: 4.0,
            peso: peso,
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseCalculada(
            titulo: 'Quimioterapia (>6 meses)',
            descricaoDose: 'Dose: 0,15 mg/kg IV (máx 8 mg) pré-quimio',
            unidade: 'mg',
            dosePorKg: 0.15,
            doseMaxima: 8.0,
            peso: peso,
          ),
        ]);
        break;
      case 'Criança':
        indicacoes.addAll([
          MedicamentoOndansetrona._linhaIndicacaoDoseCalculada(
            titulo: 'NVPO',
            descricaoDose: 'Dose: 0,1 mg/kg IV dose única (máx 4 mg)',
            unidade: 'mg',
            dosePorKg: 0.1,
            doseMaxima: 4.0,
            peso: peso,
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseCalculada(
            titulo: 'Quimioterapia altamente emetogênica',
            descricaoDose: 'Dose: 0,15 mg/kg IV (máx 8 mg) pré-quimio, repetir 4h e 8h',
            unidade: 'mg',
            dosePorKg: 0.15,
            doseMaxima: 8.0,
            peso: peso,
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'Quimioterapia moderada (VO)',
            descricaoDose: '4 mg VO 3x/dia (iniciando 30 min pré-quimio)',
            doseFixa: '4 mg 3x/dia',
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'Radioterapia',
            descricaoDose: '4 mg VO 3x/dia (1-2h antes da sessão)',
            doseFixa: '4 mg 3x/dia',
          ),
        ]);
        break;
      case 'Adolescente':
        indicacoes.addAll([
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'NVPO',
            descricaoDose: '4 mg IV/IM dose única (pré-indução ou pós-op)',
            doseFixa: '4 mg',
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'Quimioterapia altamente emetogênica',
            descricaoDose: '24 mg VO dose única 30 min pré-quimio OU 8 mg IV + 8 mg 8h depois',
            doseFixa: '8-24 mg',
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'Quimioterapia moderada',
            descricaoDose: '8 mg VO 2x/dia por 1-2 dias',
            doseFixa: '8 mg 2x/dia',
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'Radioterapia',
            descricaoDose: '8 mg VO 3x/dia (dose única: 1-2h antes, frações múltiplas: continuar 1-2 dias)',
            doseFixa: '8 mg 3x/dia',
          ),
        ]);
        break;
      case 'Adulto':
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'NVPO (prevenção)',
            descricaoDose: '4 mg IV/IM dose única (pré-indução anestésica)',
            doseFixa: '4 mg',
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'NVPO (tratamento)',
            descricaoDose: '4 mg IV/IM dose única (pós-operatório)',
            doseFixa: '4 mg',
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'NVPO profilaxia oral',
            descricaoDose: '16 mg VO dose única 1h pré-anestesia',
            doseFixa: '16 mg',
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'Quimioterapia altamente emetogênica',
            descricaoDose: '24 mg VO dose única 30 min pré-quimio OU 8 mg IV + 8 mg IV 8h depois + 8 mg VO 12/12h por 1-2 dias',
            doseFixa: '8-24 mg',
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'Quimioterapia moderadamente emetogênica',
            descricaoDose: '8 mg VO 2x/dia (dose 1: 30 min pré-quimio, dose 2: 8h depois) por 1-2 dias',
            doseFixa: '8 mg 2x/dia',
          ),
          MedicamentoOndansetrona._linhaIndicacaoDoseFixa(
            titulo: 'Radioterapia corporal total ou abdominal',
            descricaoDose: '8 mg VO 3x/dia. Fração única: 1-2h antes. Frações múltiplas: continuar 1-2 dias pós',
            doseFixa: '8 mg 3x/dia',
          ),
        ]);
        break;
    }

    return indicacoes;
  }

  static Widget _buildInfusaoContinua(double peso, String faixaEtaria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicamentoOndansetrona._textoObs('• Quimioterapia altamente emetogênica: 1 mg/h IV contínua por até 24h'),
        MedicamentoOndansetrona._textoObs('• Preparo: 32 mg em 100 mL SF 0,9% (0,32 mg/mL) a 3,1 mL/h'),
        MedicamentoOndansetrona._textoObs('• Uso restrito: geralmente preferir doses intermitentes'),
        MedicamentoOndansetrona._textoObs('• Monitorar ECG continuamente durante infusão prolongada'),
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
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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
