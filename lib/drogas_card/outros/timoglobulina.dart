import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoTimoglobulina {
  static const String nome = 'Timoglobulina';
  static const String idBulario = 'timoglobulina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/timoglobulina.json');
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
      conteudo: _buildCardTimoglobulina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardTimoglobulina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTimoglobulina._textoObs('• Imunossupressor - Imunoglobulina policlonal antilinfócito T (coelho)'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTimoglobulina._linhaPreparo('Frasco 25mg pó liofilizado', 'Thymoglobuline®'),
        MedicamentoTimoglobulina._linhaPreparo('Meia-vida: 2-3 dias (até 30 dias)', 'Variável conforme depleção'),
        MedicamentoTimoglobulina._linhaPreparo('Duração efeito: semanas a meses', 'Imunossupressão prolongada'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTimoglobulina._linhaPreparo('Reconstituir 25mg em 5mL água injetável', 'Concentração 5mg/mL'),
        MedicamentoTimoglobulina._linhaPreparo('Diluir em 50-500mL SF 0,9% ou SG 5%', 'Conforme volume paciente'),
        MedicamentoTimoglobulina._linhaPreparo('Usar filtro 0,2 micra OBRIGATÓRIO', 'Previne partículas'),
        MedicamentoTimoglobulina._linhaPreparo('Infusão IV lenta: 4-6 horas', 'NUNCA bolus'),
        MedicamentoTimoglobulina._linhaPreparo('Proteger da luz', 'Fotossensível'),
        MedicamentoTimoglobulina._linhaPreparo('Armazenamento: 2-8°C', 'Validade 24h após diluição'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTimoglobulina._linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia rejeição transplante (indução)',
          descricaoDose: '1,5 mg/kg/dia IV por 3-5 dias (pós-transplante imediato)',
          unidade: 'mg',
          dosePorKg: 1.5,
          peso: peso,
        ),
        MedicamentoTimoglobulina._linhaIndicacaoDoseCalculada(
          titulo: 'Tratamento rejeição aguda transplante',
          descricaoDose: '1,5 mg/kg/dia IV por 7-14 dias (conforme resposta)',
          unidade: 'mg',
          dosePorKg: 1.5,
          peso: peso,
        ),
        MedicamentoTimoglobulina._linhaIndicacaoDoseCalculada(
          titulo: 'Aplasia medular severa',
          descricaoDose: '2,5-3,5 mg/kg/dia IV por 5 dias consecutivos',
          unidade: 'mg',
          dosePorKgMinima: 2.5,
          dosePorKgMaxima: 3.5,
          peso: peso,
        ),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTimoglobulina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTimoglobulina._textoObs('• Anticorpos policlonais anti-linfócitos T (CD2, CD3, CD4, CD8, CD25, HLA-DR)'),
        MedicamentoTimoglobulina._textoObs('• Depleção profunda linfócitos T - imunossupressão intensa'),
        MedicamentoTimoglobulina._textoObs('• PRÉ-MEDICAÇÃO OBRIGATÓRIA: corticoide + anti-histamínico + antitérmico'),
        MedicamentoTimoglobulina._textoObs('• Síndrome liberação citocinas comum (febre, calafrios, hipotensão)'),
        MedicamentoTimoglobulina._textoObs('• Risco infecções oportunistas (CMV, EBV, fungos) - monitorar PCR viral'),
        MedicamentoTimoglobulina._textoObs('• Risco doença linfoproliferativa pós-transplante (PTLD)'),
        MedicamentoTimoglobulina._textoObs('• Mielossupressão - hemograma diário obrigatório'),
        MedicamentoTimoglobulina._textoObs('• Contraindicado: infecções ativas, leucopenia <2000/mm³, plaquetas <50.000/mm³'),
        MedicamentoTimoglobulina._textoObs('• Monitorar: sinais vitais, hemograma, função renal/hepática'),
        MedicamentoTimoglobulina._textoObs('• Não ajustar dose em insuficiência renal/hepática'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calculadora para infusão em 5 horas (ajustar conforme protocolo 4-6h)',
          style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        ConversaoInfusaoSlider(
          peso: peso,
          opcoesConcentracoes: {
            '25mg em 100mL (0,25mg/mL)': 0.25,
            '25mg em 50mL (0,5mg/mL)': 0.5,
            '50mg em 50mL (1,0mg/mL)': 1.0,
          },
          doseMin: 0.25,
          doseMax: 0.7,
          unidade: 'mg/kg/h',
        ),
        const SizedBox(height: 8),
        const Text(
          'Doses: 0,3 mg/kg/h (1,5mg/kg em 5h) | 0,5 mg/kg/h (2,5mg/kg em 5h) | 0,7 mg/kg/h (3,5mg/kg em 5h)',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
        ),
      ],
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
