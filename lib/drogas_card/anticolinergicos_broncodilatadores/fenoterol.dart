import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoFenoterol {
  static const String nome = 'Fenoterol';
  static const String idBulario = 'fenoterol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/fenoterol.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Fenoterol tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardFenoterol(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardFenoterol(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenoterol._textoObs(
            'Agonista beta-2 adrenérgico seletivo (SABA) - Broncodilatador de curta duração'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenoterol._linhaPreparo(
            'Solução inalatória 0,5mg/mL (20mL)', ''),
        MedicamentoFenoterol._linhaPreparo('Aerossol MDI 100mcg/jato', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenoterol._linhaPreparo(
            'Nebulização', 'Diluir 0,5-1mL da solução em 2-3mL SF 0,9%'),
        MedicamentoFenoterol._linhaPreparo('Aerossol MDI',
            'Agitar bem antes do uso, usar espaçador se possível'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoFenoterol._linhaIndicacaoDoseFixa(
            titulo: 'Broncoespasmo agudo (nebulização)',
            descricaoDose:
                '0,5-1mL (500-1000mcg) diluído em 2-3mL SF 0,9%, a cada 4-6h',
            doseFixa: '0,5-1 mL (500-1000 mcg)',
          ),
          MedicamentoFenoterol._linhaIndicacaoDoseFixa(
            titulo: 'Aerossol MDI',
            descricaoDose:
                '1-2 jatos (100-200mcg) a cada 4-6h (máx 8 jatos/dia)',
            doseFixa: '1-2 jatos (100-200 mcg)',
          ),
          MedicamentoFenoterol._linhaIndicacaoDoseFixa(
            titulo: 'Exacerbação asmática grave',
            descricaoDose:
                '1mL (1000mcg) nebulização a cada 20min na 1ª hora, depois a cada 4-6h',
            doseFixa: '1 mL (1000 mcg)',
          ),
        ] else ...[
          MedicamentoFenoterol._linhaIndicacaoDoseCalculada(
            titulo: 'Pediatria <6 anos (nebulização)',
            descricaoDose: '0,05mL/kg (máx 0,5mL) diluído em 2-3mL SF 0,9%',
            unidade: 'mL',
            dosePorKg: 0.05,
            peso: peso,
            doseMaxima: 0.5,
          ),
          MedicamentoFenoterol._linhaIndicacaoDoseFixa(
            titulo: 'Pediatria 6-12 anos (nebulização)',
            descricaoDose:
                '0,5mL (250mcg) diluído em 2-3mL SF 0,9%, a cada 4-6h',
            doseFixa: '0,5 mL (250 mcg)',
          ),
          MedicamentoFenoterol._linhaIndicacaoDoseFixa(
            titulo: 'Pediatria >12 anos (nebulização)',
            descricaoDose:
                '0,5-1mL (250-500mcg) diluído em 2-3mL SF 0,9%, a cada 4-6h',
            doseFixa: '0,5-1 mL (250-500 mcg)',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFenoterol._textoObs('Início de ação: 5 minutos'),
        MedicamentoFenoterol._textoObs('Pico de efeito: 15-60 minutos'),
        MedicamentoFenoterol._textoObs('Duração: 3-6 horas'),
        MedicamentoFenoterol._textoObs('Meia-vida: 2-3 horas'),
        MedicamentoFenoterol._textoObs(
            'Estimula receptores beta-2 na musculatura brônquica'),
        MedicamentoFenoterol._textoObs(
            'Promove relaxamento e broncodilatação rápida'),
        MedicamentoFenoterol._textoObs('Reduz resistência das vias aéreas'),
        MedicamentoFenoterol._textoObs('Melhora função pulmonar (VEF1)'),
        MedicamentoFenoterol._textoObs(
            'Dose máxima nebulização: 4mL/dia (2000mcg/dia)'),
        MedicamentoFenoterol._textoObs(
            'Dose máxima aerossol: 8 jatos/dia (800mcg/dia)'),
        MedicamentoFenoterol._textoObs(
            'Compatível com ipratrópio na nebulização'),
        MedicamentoFenoterol._textoObs(
            'Compatível com budesonida na nebulização'),
        MedicamentoFenoterol._textoObs('Incompatível com soluções alcalinas'),
        MedicamentoFenoterol._textoObs(
            'Monitorar FC, PA e potássio em uso contínuo'),
        MedicamentoFenoterol._textoObs(
            'Efeitos adversos: tremores, taquicardia, palpitações'),
        MedicamentoFenoterol._textoObs('Risco de hipocalemia transitória'),
        MedicamentoFenoterol._textoObs(
            'Risco de broncoespasmo paradoxal (raro)'),
        MedicamentoFenoterol._textoObs('Betabloqueadores antagonizam o efeito'),
        MedicamentoFenoterol._textoObs(
            'Risco de arritmias com anestésicos halogenados'),
        MedicamentoFenoterol._textoObs(
            'Não usar isolado em exacerbações graves'),
        MedicamentoFenoterol._textoObs(
            'Associar ipratrópio ou corticoide em crises graves'),
        MedicamentoFenoterol._textoObs(
            'Contraindicado em cardiomiopatia hipertrófica'),
        MedicamentoFenoterol._textoObs(
            'Contraindicado em arritmias não controladas'),
        MedicamentoFenoterol._textoObs('Categoria C na gravidez'),
        MedicamentoFenoterol._textoObs('Pode causar taquicardia fetal'),
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

    // Se a unidade contém "/kg", não multiplicamos pelo peso (a dose já é por kg)
    bool isDosePorKg = unidade?.contains('/kg') ?? false;

    if (dosePorKg != null) {
      if (isDosePorKg) {
        // Para doses do tipo mcg/kg/min, mostramos apenas o valor
        textoDose = '${dosePorKg.toStringAsFixed(2)} $unidade';
      } else {
        // Para doses totais (mg, mcg, mL), calculamos multiplicando pelo peso
        doseCalculada = dosePorKg * peso;
        if (doseMaxima != null && doseCalculada > doseMaxima) {
          doseCalculada = doseMaxima;
        }
        textoDose = '${doseCalculada.toStringAsFixed(2)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      if (isDosePorKg) {
        // Para doses do tipo mcg/kg/min, mostramos apenas o intervalo
        textoDose =
            '${dosePorKgMinima.toStringAsFixed(2)}–${dosePorKgMaxima.toStringAsFixed(2)} $unidade';
      } else {
        // Para doses totais, calculamos multiplicando pelo peso
        double doseMin = dosePorKgMinima * peso;
        double doseMax = dosePorKgMaxima * peso;
        if (doseMaxima != null) {
          doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
        }
        textoDose =
            '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
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
