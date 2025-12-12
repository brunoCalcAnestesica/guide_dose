import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoFenitoina {
  static const String nome = 'Fenitoína';
  static const String idBulario = 'fenitoina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/fenitoina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Fenitoína tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardFenitoina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardFenitoina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenitoina._textoObs(
            'Antiepiléptico - Estabilizador de membrana neuronal'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenitoina._linhaPreparo('Ampola 250mg/5mL (50mg/mL)', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenitoina._linhaPreparo('Solução pronta para uso IV',
            'Administrar diretamente ou diluir em 50-100mL SF 0,9%'),
        MedicamentoFenitoina._linhaPreparo(
            'Velocidade máxima', '50 mg/min adultos; 1-3 mg/kg/min crianças'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoFenitoina._linhaIndicacaoDoseCalculada(
            titulo: 'Status epilepticus (dose de ataque)',
            descricaoDose: '15-20 mg/kg IV em infusão lenta',
            unidade: 'mg',
            dosePorKgMinima: 15,
            dosePorKgMaxima: 20,
            peso: peso,
          ),
          MedicamentoFenitoina._linhaIndicacaoDoseCalculada(
            titulo: 'Prevenção convulsões em TCE/neurocirurgia',
            descricaoDose: '15-20 mg/kg IV em infusão lenta (dose de ataque)',
            unidade: 'mg',
            dosePorKgMinima: 15,
            dosePorKgMaxima: 20,
            peso: peso,
          ),
          MedicamentoFenitoina._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção anticonvulsivante (dose diária)',
            descricaoDose: '4-7 mg/kg/dia (dividido em 2-3 doses)',
            unidade: 'mg/dia',
            dosePorKgMinima: 4,
            dosePorKgMaxima: 7,
            peso: peso,
          ),
        ] else ...[
          MedicamentoFenitoina._linhaIndicacaoDoseCalculada(
            titulo: 'Status epilepticus pediátrico (dose de ataque)',
            descricaoDose: '15-20 mg/kg IV em infusão lenta',
            unidade: 'mg',
            dosePorKgMinima: 15,
            dosePorKgMaxima: 20,
            peso: peso,
          ),
          MedicamentoFenitoina._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção pediátrica (dose diária)',
            descricaoDose: '4-7 mg/kg/dia (dividido em 2-3 doses)',
            unidade: 'mg/dia',
            dosePorKgMinima: 4,
            dosePorKgMaxima: 7,
            peso: peso,
          ),
          MedicamentoFenitoina._linhaIndicacaoDoseCalculada(
            titulo: 'Neonatos (dose diária)',
            descricaoDose: '5-8 mg/kg/dia (dividido em 2-3 doses)',
            unidade: 'mg/dia',
            dosePorKgMinima: 5,
            dosePorKgMaxima: 8,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenitoina._textoObs('NÃO recomendado para infusão contínua'),
        MedicamentoFenitoina._textoObs('Uso exclusivo em bolus de carga'),
        MedicamentoFenitoina._textoObs(
            'Manutenção via oral ou IV intermitente'),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenitoina._textoObs('Início de ação IV: 10-30 minutos'),
        MedicamentoFenitoina._textoObs('Pico plasmático: 1-3 horas'),
        MedicamentoFenitoina._textoObs(
            'Meia-vida: 7-42 horas (cinética não linear)'),
        MedicamentoFenitoina._textoObs(
            'Estabiliza membranas neuronais hiperexcitáveis'),
        MedicamentoFenitoina._textoObs(
            'Bloqueia canais de sódio voltagem-dependentes'),
        MedicamentoFenitoina._textoObs(
            'Eficaz em crises tônico-clônicas e focais'),
        MedicamentoFenitoina._textoObs('NÃO eficaz em crises de ausência'),
        MedicamentoFenitoina._textoObs(
            'Níveis terapêuticos: 10-20 mcg/mL total'),
        MedicamentoFenitoina._textoObs('Níveis livres: 1-2 mcg/mL'),
        MedicamentoFenitoina._textoObs('Solução altamente alcalina (pH 12)'),
        MedicamentoFenitoina._textoObs('Risco de necrose por extravasamento'),
        MedicamentoFenitoina._textoObs(
            'Contraindicado via IM (necrose tecidual)'),
        MedicamentoFenitoina._textoObs('NUNCA administrar em bolus rápido'),
        MedicamentoFenitoina._textoObs('Monitorar PA, FC, FR durante infusão'),
        MedicamentoFenitoina._textoObs('Observar nistagmo, ataxia, disartria'),
        MedicamentoFenitoina._textoObs('Risco de hipotensão e bradicardia'),
        MedicamentoFenitoina._textoObs(
            'Risco de colapso cardiovascular se infundida rapidamente'),
        MedicamentoFenitoina._textoObs(
            'Acesso venoso de grande calibre obrigatório'),
        MedicamentoFenitoina._textoObs('Incompatível com soluções glicosadas'),
        MedicamentoFenitoina._textoObs('Apenas SF 0,9% compatível'),
        MedicamentoFenitoina._textoObs(
            'Ajustar dose em insuficiência hepática'),
        MedicamentoFenitoina._textoObs('Monitorar função hepática e renal'),
        MedicamentoFenitoina._textoObs(
            'Categoria D na gravidez (teratogênica)'),
        MedicamentoFenitoina._textoObs(
            'Induz enzimas CYP450 (interações múltiplas)'),
        MedicamentoFenitoina._textoObs('Contraindicado em bloqueio AV'),
        MedicamentoFenitoina._textoObs('Contraindicado em bradicardia sinusal'),
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
