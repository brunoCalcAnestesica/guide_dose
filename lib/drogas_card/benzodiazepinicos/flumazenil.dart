import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoFlumazenil {
  static const String nome = 'Flumazenil';
  static const String idBulario = 'flumazenil';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/flumazenil.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Flumazenil tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardFlumazenil(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardFlumazenil(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFlumazenil._textoObs(
            'Antagonista de benzodiazepínicos - Antídoto específico'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFlumazenil._linhaPreparo('Ampola 0,5mg/5mL (0,1mg/mL)', ''),
        MedicamentoFlumazenil._linhaPreparo('Ampola 1mg/10mL (0,1mg/mL)', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFlumazenil._linhaPreparo(
            'Solução pronta para uso', 'Administrar em bolus lento'),
        MedicamentoFlumazenil._linhaPreparo(
            'Infusão contínua', '5mg (5 amp 1mg) em 50mL SF 0,9% = 0,1mg/mL'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoFlumazenil._linhaIndicacaoDoseFixa(
            titulo: 'Reversão sedação pós-procedimento (dose inicial)',
            descricaoDose: '0,2mg IV em 15 segundos',
            doseFixa: '0,2 mg',
          ),
          MedicamentoFlumazenil._linhaIndicacaoDoseFixa(
            titulo: 'Doses adicionais (se necessário)',
            descricaoDose: '0,1mg IV a cada 60 segundos (máx total: 1mg)',
            doseFixa: '0,1 mg',
          ),
          MedicamentoFlumazenil._linhaIndicacaoDoseFixa(
            titulo: 'Intoxicação aguda (dose inicial)',
            descricaoDose: '0,3mg IV em 30 segundos',
            doseFixa: '0,3 mg',
          ),
          MedicamentoFlumazenil._linhaIndicacaoDoseFixa(
            titulo: 'Intoxicação - doses adicionais',
            descricaoDose: '0,1mg IV a cada 60 segundos (máx total: 2mg)',
            doseFixa: '0,1 mg',
          ),
        ] else ...[
          MedicamentoFlumazenil._linhaIndicacaoDoseCalculada(
            titulo: 'Pediatria >1 ano (dose inicial)',
            descricaoDose: '0,01mg/kg (máx 0,2mg) IV em 15 segundos',
            unidade: 'mg',
            dosePorKg: 0.01,
            peso: peso,
            doseMaxima: 0.2,
          ),
          MedicamentoFlumazenil._linhaIndicacaoDoseCalculada(
            titulo: 'Pediatria - doses adicionais',
            descricaoDose: '0,01mg/kg (máx 0,1mg) a cada 60 segundos',
            unidade: 'mg',
            dosePorKg: 0.01,
            peso: peso,
            doseMaxima: 0.1,
          ),
          MedicamentoFlumazenil._linhaIndicacaoDoseCalculada(
            titulo: 'Dose total máxima pediátrica',
            descricaoDose: '0,05mg/kg ou 1mg (o que for menor)',
            unidade: 'mg',
            dosePorKg: 0.05,
            peso: peso,
            doseMaxima: 1.0,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoFlumazenil._textoObs('Início de ação: 1-2 minutos'),
        MedicamentoFlumazenil._textoObs('Pico de efeito: 6-10 minutos'),
        MedicamentoFlumazenil._textoObs('Duração: 30-75 minutos'),
        MedicamentoFlumazenil._textoObs('Meia-vida: 40-80 minutos'),
        MedicamentoFlumazenil._textoObs(
            'Antagonista competitivo específico GABA-A'),
        MedicamentoFlumazenil._textoObs(
            'Reverte APENAS efeitos de benzodiazepínicos'),
        MedicamentoFlumazenil._textoObs(
            'NÃO reverte opioides, barbitúricos ou álcool'),
        MedicamentoFlumazenil._textoObs(
            'Duração menor que maioria dos benzodiazepínicos'),
        MedicamentoFlumazenil._textoObs(
            'Risco de ressedação (especialmente diazepam, clonazepam)'),
        MedicamentoFlumazenil._textoObs(
            'Monitorar por pelo menos 2 horas após última dose'),
        MedicamentoFlumazenil._textoObs(
            'Repetir doses de 0,1mg se ressedação (conforme dose máxima)'),
        MedicamentoFlumazenil._textoObs(
            'Administrar em bolus LENTO (evitar náusea/vômito)'),
        MedicamentoFlumazenil._textoObs(
            'Monitorar sinais vitais continuamente'),
        MedicamentoFlumazenil._textoObs(
            'RISCO DE CONVULSÕES em dependentes crônicos'),
        MedicamentoFlumazenil._textoObs(
            'RISCO DE CONVULSÕES em intoxicação mista com tricíclicos'),
        MedicamentoFlumazenil._textoObs(
            'Pode precipitar síndrome de abstinência aguda'),
        MedicamentoFlumazenil._textoObs('Ter suporte avançado disponível'),
        MedicamentoFlumazenil._textoObs('Ter anticonvulsivantes disponíveis'),
        MedicamentoFlumazenil._textoObs(
            'Efeitos adversos: náusea, vômito, agitação, ansiedade'),
        MedicamentoFlumazenil._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoFlumazenil._textoObs('Incompatível com soluções alcalinas'),
        MedicamentoFlumazenil._textoObs('Não requer ajuste renal'),
        MedicamentoFlumazenil._textoObs(
            'Cautela em insuficiência hepática grave'),
        MedicamentoFlumazenil._textoObs('Categoria C na gravidez'),
        MedicamentoFlumazenil._textoObs(
            'Contraindicado em epilepsia não controlada'),
        MedicamentoFlumazenil._textoObs(
            'Contraindicado em dependência crônica de BZD'),
        MedicamentoFlumazenil._textoObs(
            'Contraindicado em intoxicação mista com tricíclicos'),
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
        // Para doses do tipo mg/kg/h, mostramos apenas o valor
        textoDose = '${dosePorKg.toStringAsFixed(2)} $unidade';
      } else {
        // Para doses totais (mg), calculamos multiplicando pelo peso
        doseCalculada = dosePorKg * peso;
        if (doseMaxima != null && doseCalculada > doseMaxima) {
          doseCalculada = doseMaxima;
        }
        textoDose = '${doseCalculada.toStringAsFixed(2)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      if (isDosePorKg) {
        // Para doses do tipo mg/kg/h, mostramos apenas o intervalo
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
