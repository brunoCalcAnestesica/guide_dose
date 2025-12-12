import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoFenobarbital {
  static const String nome = 'Fenobarbital';
  static const String idBulario = 'fenobarbital';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/fenobarbital.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Fenobarbital tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardFenobarbital(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardFenobarbital(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenobarbital._textoObs(
            'Barbitúrico - Antiepiléptico de ação prolongada'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenobarbital._linhaPreparo('Ampola 200mg/mL', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenobarbital._linhaPreparo(
            'Diluir em 5-10mL SF 0,9%', 'Para cada 200mg'),
        MedicamentoFenobarbital._linhaPreparo(
            'Velocidade máxima', '50-60 mg/min (ideal 30-50 mg/min)'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoFenobarbital._linhaIndicacaoDoseCalculada(
            titulo: 'Status epilepticus (dose de ataque)',
            descricaoDose: '10-20 mg/kg IV em infusão lenta',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 20,
            peso: peso,
            doseMaxima: 1400,
          ),
          MedicamentoFenobarbital._linhaIndicacaoDoseCalculada(
            titulo: 'Crises epilépticas generalizadas/focais (dose de ataque)',
            descricaoDose: '10-20 mg/kg IV em infusão lenta',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 20,
            peso: peso,
            doseMaxima: 1400,
          ),
          MedicamentoFenobarbital._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção (dose diária total)',
            descricaoDose:
                '1-3 mg/kg/dia VO, IV ou IM (dose única ou dividida)',
            unidade: 'mg/dia',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 3,
            peso: peso,
            doseMaxima: 300,
          ),
        ] else ...[
          MedicamentoFenobarbital._linhaIndicacaoDoseCalculada(
            titulo: 'Crises neonatais (dose de ataque inicial)',
            descricaoDose: '20 mg/kg IV em bolus lento',
            unidade: 'mg',
            dosePorKg: 20,
            peso: peso,
          ),
          MedicamentoFenobarbital._linhaIndicacaoDoseCalculada(
            titulo: 'Dose adicional neonatal (se necessário)',
            descricaoDose: '5-10 mg/kg IV (dose máxima total: 40 mg/kg)',
            unidade: 'mg',
            dosePorKgMinima: 5,
            dosePorKgMaxima: 10,
            peso: peso,
          ),
          MedicamentoFenobarbital._linhaIndicacaoDoseCalculada(
            titulo: 'Crises pediátricas (dose de ataque)',
            descricaoDose: '15-20 mg/kg IV em dose única',
            unidade: 'mg',
            dosePorKgMinima: 15,
            dosePorKgMaxima: 20,
            peso: peso,
          ),
          MedicamentoFenobarbital._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção neonatal/pediátrica (dose diária total)',
            descricaoDose:
                '3-5 mg/kg/dia VO, IV ou IM (dose única ou dividida em 1-2x)',
            unidade: 'mg/dia',
            dosePorKgMinima: 3,
            dosePorKgMaxima: 5,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenobarbital._textoObs(
            'NÃO recomendado para infusão contínua'),
        MedicamentoFenobarbital._textoObs('Uso em bolus de ataque'),
        MedicamentoFenobarbital._textoObs(
            'Manutenção via oral, IV ou IM intermitente'),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenobarbital._textoObs('Início de ação IV: 5 minutos'),
        MedicamentoFenobarbital._textoObs('Pico de efeito: 30 minutos'),
        MedicamentoFenobarbital._textoObs(
            'Meia-vida: adultos 53-118h; neonatos até 180h'),
        MedicamentoFenobarbital._textoObs(
            'Agonista GABA-A (aumenta influxo de cloro)'),
        MedicamentoFenobarbital._textoObs('Reduz excitabilidade neuronal'),
        MedicamentoFenobarbital._textoObs(
            'Droga de primeira linha em neonatos'),
        MedicamentoFenobarbital._textoObs(
            'Eficaz em crises tônico-clônicas e focais'),
        MedicamentoFenobarbital._textoObs('Níveis terapêuticos: 15-40 mcg/mL'),
        MedicamentoFenobarbital._textoObs('Infusão IV lenta obrigatória'),
        MedicamentoFenobarbital._textoObs(
            'Monitorar PA, FC, FR e nível de consciência'),
        MedicamentoFenobarbital._textoObs('Risco de depressão respiratória'),
        MedicamentoFenobarbital._textoObs(
            'Risco de hipotensão em infusão rápida'),
        MedicamentoFenobarbital._textoObs(
            'IM possível mas doloroso e irritativo'),
        MedicamentoFenobarbital._textoObs(
            'Incompatível com soluções glicosadas'),
        MedicamentoFenobarbital._textoObs(
            'Incompatível com bicarbonato de sódio'),
        MedicamentoFenobarbital._textoObs('Apenas SF 0,9% compatível'),
        MedicamentoFenobarbital._textoObs('Indutor potente de enzimas CYP450'),
        MedicamentoFenobarbital._textoObs(
            'Múltiplas interações medicamentosas'),
        MedicamentoFenobarbital._textoObs(
            'Reduz eficácia de anticoncepcionais'),
        MedicamentoFenobarbital._textoObs(
            'Potencializa depressão do SNC com outros sedativos'),
        MedicamentoFenobarbital._textoObs(
            'Ajustar dose em insuficiência hepática/renal'),
        MedicamentoFenobarbital._textoObs(
            'Categoria D na gravidez (teratogênico)'),
        MedicamentoFenobarbital._textoObs('Risco de dependência física'),
        MedicamentoFenobarbital._textoObs(
            'Desmame lento obrigatório (evitar abstinência)'),
        MedicamentoFenobarbital._textoObs('Contraindicado em porfiria aguda'),
        MedicamentoFenobarbital._textoObs(
            'Contraindicado em insuficiência respiratória severa'),
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
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
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
            '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
