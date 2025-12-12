import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoVasopressina {
  static const String nome = 'Vasopressina';
  static const String idBulario = 'vasopressina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/vasopressina.json');
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
      conteudo: _buildCardVasopressina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardVasopressina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVasopressina._textoObs('• Hormônio antidiurético sintético - Vasopressor não catecolaminérgico - Agonista V1a/V2/V3'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVasopressina._linhaPreparo('Frasco 20U/mL (1mL)', 'Pitressin® / Vasopressin®'),
        MedicamentoVasopressina._linhaPreparo('Início: 15-20 min', 'Meia-vida: 10-35 min'),
        MedicamentoVasopressina._linhaPreparo('Metabolismo: hepático + renal', 'Peptidases'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVasopressina._linhaPreparo('Diluir 20U (1 frasco) em 100mL SF', 'Concentração 0,2 U/mL'),
        MedicamentoVasopressina._linhaPreparo('Ou 40U em 100mL SF', 'Concentração 0,4 U/mL'),
        MedicamentoVasopressina._linhaPreparo('Compatível: SF 0,9%, SG 5%', 'Incompatível: bicarbonato'),
        MedicamentoVasopressina._linhaPreparo('Acesso central preferível', 'Usar bomba de infusão'),
        MedicamentoVasopressina._linhaPreparo('Armazenar: 2-8°C', 'Proteger da luz'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoVasopressina._linhaIndicacaoDoseFixa(
            titulo: 'Parada cardiorrespiratória (PCR)',
            descricaoDose: '40 U IV bolus (dose única - alternativa adrenalina)',
            doseFixa: '40 U',
          ),
          MedicamentoVasopressina._linhaIndicacaoDoseFixa(
            titulo: 'Hemorragia digestiva (varizes esofágicas)',
            descricaoDose: '20 U IV bolus seguido de 0,2-0,4 U/min infusão contínua',
            doseFixa: '20 U bolus',
          ),
        ] else ...[
          MedicamentoVasopressina._textoObs('• Uso pediátrico apenas em infusão contínua (ver seção específica)'),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVasopressina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVasopressina._textoObs('• Agonista V1a (vasoconstrição), V2 (retenção água), V3 (liberação ACTH)'),
        MedicamentoVasopressina._textoObs('• Vasoconstrição potente esplâncnica, hepática, cutânea - poupa circulação coronariana'),
        MedicamentoVasopressina._textoObs('• Sensibiliza receptores α - potencializa catecolaminas (efeito sinérgico noradrenalina)'),
        MedicamentoVasopressina._textoObs('• Indicação principal: choque séptico refratário (adjuvante noradrenalina)'),
        MedicamentoVasopressina._textoObs('• NUNCA primeira linha - usar se noradrenalina >0,5 mcg/kg/min'),
        MedicamentoVasopressina._textoObs('• ATENÇÃO: Isquemia digital, mesentérica, cutânea (vasoconstrição intensa)'),
        MedicamentoVasopressina._textoObs('• ATENÇÃO: Hiponatremia (efeito V2 - retenção água) - monitorar Na+'),
        MedicamentoVasopressina._textoObs('• ATENÇÃO: Bradicardia (barorreflexo) - monitorar FC'),
        MedicamentoVasopressina._textoObs('• ATENÇÃO: Necrose extravasamento - acesso central obrigatório'),
        MedicamentoVasopressina._textoObs('• Monitorar: PA invasiva, ECG, perfusão periférica, débito urinário, Na+'),
        MedicamentoVasopressina._textoObs('• Vantagens: não ↑ consumo O2 miocárdico, eficaz em betabloqueio, sem taquifilaxia'),
        MedicamentoVasopressina._textoObs('• Contraindicado: doença coronariana ativa, arteriopatia periférica grave, isquemia mesentérica'),
        MedicamentoVasopressina._textoObs('• Reduz fluxo esplâncnico - útil hemorragia varicosa mas risco isquemia intestinal'),
        MedicamentoVasopressina._textoObs('• Uso PCR: dose única 40U substitui 1ª ou 2ª dose adrenalina (sem vantagem comprovada)'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: {
        '20U em 100mL (0,2 U/mL)': 0.2,
        '40U em 100mL (0,4 U/mL)': 0.4,
      },
      doseMin: isAdulto ? 0.01 : 0.0003,
      doseMax: isAdulto ? 0.04 : 0.002,
      unidade: isAdulto ? 'U/min' : 'U/kg/min',
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
