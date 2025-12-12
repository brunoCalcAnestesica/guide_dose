import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoEtomidato {
  static const String nome = 'Etomidato';
  static const String idBulario = 'etomidato';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/etomidato.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardEtomidato(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardEtomidato(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEtomidato._textoObs(
            'Anestésico geral IV - Hipnótico de ação ultracurta'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEtomidato._linhaPreparo(
            'Ampola 2mg/mL (10mL = 20mg)', 'Hypnomidate®, Amidate®'),
        MedicamentoEtomidato._linhaPreparo(
            'Ampola 2mg/mL (20mL = 40mg)', 'Hypnomidate®, Amidate®'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEtomidato._linhaPreparo(
            'Solução pronta para uso', 'Administrar sem diluição'),
        MedicamentoEtomidato._linhaPreparo(
            'Diluição opcional em SF 0,9% ou SG 5%',
            'Para reduzir dor na injeção (0,2-1 mg/mL)'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoEtomidato._linhaIndicacaoDoseCalculada(
            titulo: 'Indução de anestesia geral',
            descricaoDose: '0,2-0,6 mg/kg IV em bolus lento (30-60 segundos)',
            unidade: 'mg',
            dosePorKgMinima: 0.2,
            dosePorKgMaxima: 0.6,
            peso: peso,
          ),
          MedicamentoEtomidato._linhaIndicacaoDoseCalculada(
            titulo: 'Sequência rápida de intubação (SRI)',
            descricaoDose: '0,3 mg/kg IV em bolus único',
            unidade: 'mg',
            dosePorKg: 0.3,
            peso: peso,
          ),
          MedicamentoEtomidato._linhaIndicacaoDoseCalculada(
            titulo: 'Cardioversão elétrica',
            descricaoDose: '0,15-0,3 mg/kg IV',
            unidade: 'mg',
            dosePorKgMinima: 0.15,
            dosePorKgMaxima: 0.3,
            peso: peso,
          ),
        ] else ...[
          MedicamentoEtomidato._linhaIndicacaoDoseCalculada(
            titulo: 'Indução pediátrica',
            descricaoDose: '0,2-0,4 mg/kg IV em bolus lento (30-60 segundos)',
            unidade: 'mg',
            dosePorKgMinima: 0.2,
            dosePorKgMaxima: 0.4,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEtomidato._textoObs('NÃO recomendado para infusão contínua'),
        MedicamentoEtomidato._textoObs('Uso exclusivo em bolus'),
        MedicamentoEtomidato._textoObs(
            'Infusão prolongada causa supressão adrenal sustentada'),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoEtomidato._textoObs('Início de ação: 30-60 segundos'),
        MedicamentoEtomidato._textoObs('Duração do efeito: 3-5 minutos'),
        MedicamentoEtomidato._textoObs('Meia-vida terminal: 2,9-5,3 horas'),
        MedicamentoEtomidato._textoObs(
            'Mínima depressão cardiovascular e respiratória'),
        MedicamentoEtomidato._textoObs('Excelente estabilidade hemodinâmica'),
        MedicamentoEtomidato._textoObs('Ideal para pacientes em choque'),
        MedicamentoEtomidato._textoObs('NÃO possui efeito analgésico'),
        MedicamentoEtomidato._textoObs('Dor intensa na injeção (até 80%)'),
        MedicamentoEtomidato._textoObs('Mioclonias frequentes (até 60%)'),
        MedicamentoEtomidato._textoObs(
            'Supressão adrenal por 6-24h após dose única'),
        MedicamentoEtomidato._textoObs(
            'Contraindicado em insuficiência adrenal'),
        MedicamentoEtomidato._textoObs('Cuidado em sepse/choque séptico'),
        MedicamentoEtomidato._textoObs('Não requer ajuste renal ou hepático'),
        MedicamentoEtomidato._textoObs('Considerar pré-medicação com opioides'),
        MedicamentoEtomidato._textoObs('Administrar em veia de bom calibre'),
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

    // Se a unidade contém "/kg", não multiplicamos pelo peso (a dose já é por kg)
    bool isDosePorKg = unidade?.contains('/kg') ?? false;

    if (dosePorKg != null) {
      if (isDosePorKg) {
        // Para doses do tipo mcg/kg/min, mostramos apenas o valor
        textoDose = '${dosePorKg.toStringAsFixed(1)} $unidade';
      } else {
        // Para doses totais (mg, mcg), calculamos multiplicando pelo peso
        doseCalculada = dosePorKg * peso;
        if (doseMaxima != null && doseCalculada > doseMaxima) {
          doseCalculada = doseMaxima;
        }
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      if (isDosePorKg) {
        // Para doses do tipo mcg/kg/min, mostramos apenas o intervalo
        textoDose =
            '${dosePorKgMinima.toStringAsFixed(1)}–${dosePorKgMaxima.toStringAsFixed(1)} $unidade';
      } else {
        // Para doses totais, calculamos multiplicando pelo peso
        double doseMin = dosePorKgMinima * peso;
        double doseMax = dosePorKgMaxima * peso;
        if (doseMaxima != null) {
          doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
        }
        textoDose =
            '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
      }
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
