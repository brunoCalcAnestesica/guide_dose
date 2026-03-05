import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoLidocaina {
  static const String nome = 'Lidocaína';
  static const String idBulario = 'lidocaina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/lidocaina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Lidocaína tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardLidocaina(
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

    return _buildCardLidocaina(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardLidocaina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    // Calcular doses máximas
    final doseSemVasoMax = (4.5 * peso).toStringAsFixed(0);
    final doseComVasoMax = (7.0 * peso).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLidocaina._textoObs(
            'Anestésico local tipo amida - Bloqueador de canais de sódio'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLidocaina._linhaPreparo('Solução 0,5% (5mg/mL)', ''),
        MedicamentoLidocaina._linhaPreparo('Solução 1% (10mg/mL)', ''),
        MedicamentoLidocaina._linhaPreparo('Solução 2% (20mg/mL)', ''),
        MedicamentoLidocaina._linhaPreparo(
            'Com vasoconstritor', 'Adrenalina 1:100.000 ou 1:200.000'),
        MedicamentoLidocaina._linhaPreparo('Frascos', '10mL, 20mL, 50mL'),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLidocaina._linhaPreparo(
            'Infiltração local', 'Pronta para uso'),
        MedicamentoLidocaina._linhaPreparo(
            'Aspiração prévia', 'Obrigatória (evitar injeção intravascular)'),
        MedicamentoLidocaina._linhaPreparo(
            'Identificação', 'Manter concentração na seringa'),
        MedicamentoLidocaina._linhaPreparo('Técnica asséptica', 'Sempre'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoLidocaina._linhaIndicacaoTexto(
            titulo: 'Cirurgias dermatológicas menores',
            descricaoDose: '0,5-2% infiltração local',
            textoCalculo:
                'Dose máxima: $doseSemVasoMax mg (sem vaso) ou $doseComVasoMax mg (com vaso)',
          ),
          MedicamentoLidocaina._linhaIndicacaoTexto(
            titulo: 'Anestesia de feridas/lacerações',
            descricaoDose: '1% infiltração perilesional',
            textoCalculo: 'Dose máxima: $doseSemVasoMax mg (4,5 mg/kg)',
          ),
          MedicamentoLidocaina._linhaIndicacaoTexto(
            titulo: 'Biópsias/excisões',
            descricaoDose: '1-2% infiltração local',
            textoCalculo: 'Volume conforme área (máx $doseComVasoMax mg)',
          ),
          MedicamentoLidocaina._linhaIndicacaoTexto(
            titulo: 'Procedimentos odontológicos',
            descricaoDose: '2% com adrenalina',
            textoCalculo: 'Dose máxima: $doseComVasoMax mg (7 mg/kg)',
          ),
        ] else ...[
          MedicamentoLidocaina._linhaIndicacaoDoseCalculada(
            titulo: 'Anestesia local pediátrica',
            descricaoDose: '1-4 mg/kg infiltração',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 4,
            peso: peso,
          ),
          MedicamentoLidocaina._linhaIndicacaoDoseCalculada(
            titulo: 'Com vasoconstritor (pediátrico)',
            descricaoDose: 'Até 5 mg/kg',
            unidade: 'mg',
            dosePorKg: 5,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLidocaina._textoObs(
            'Início de ação: 30 seg - 2 minutos (rápido)'),
        MedicamentoLidocaina._textoObs('Pico de ação: 5-15 minutos'),
        MedicamentoLidocaina._textoObs(
            'Duração sem vasoconstritor: 0,5-2 horas'),
        MedicamentoLidocaina._textoObs(
            'Duração com vasoconstritor: até 3 horas'),
        MedicamentoLidocaina._textoObs('Meia-vida: 1,5-2 horas'),
        MedicamentoLidocaina._textoObs('Ligação proteica: 60-80%'),
        MedicamentoLidocaina._textoObs(
            'Metabolização: hepática (CYP1A2, CYP3A4)'),
        MedicamentoLidocaina._textoObs('Excreção: renal'),
        MedicamentoLidocaina._textoObs(
            'Bloqueio reversível de canais de sódio'),
        MedicamentoLidocaina._textoObs(
            'Impede propagação do potencial de ação'),
        MedicamentoLidocaina._textoObs(
            'Bloqueio sensitivo rápido e reversível'),
        MedicamentoLidocaina._textoObs(
            'Mais rápido que bupivacaína/ropivacaína'),
        MedicamentoLidocaina._textoObs(
            'Ideal para procedimentos ambulatoriais rápidos'),
        MedicamentoLidocaina._textoObs(
            'DOSE MÁXIMA sem vasoconstritor: 4,5 mg/kg'),
        MedicamentoLidocaina._textoObs(
            'DOSE MÁXIMA com vasoconstritor: 7 mg/kg'),
        MedicamentoLidocaina._textoObs(
            'Adultos: máx 300mg sem vaso, 500mg com vaso'),
        MedicamentoLidocaina._textoObs('SEMPRE fazer aspiração prévia'),
        MedicamentoLidocaina._textoObs(
            'Evitar injeção intravascular (toxicidade)'),
        MedicamentoLidocaina._textoObs(
            'Vasoconstritor: reduz absorção sistêmica'),
        MedicamentoLidocaina._textoObs(
            'Vasoconstritor: prolonga duração em até 50%'),
        MedicamentoLidocaina._textoObs(
            'Vasoconstritor: reduz sangramento local'),
        MedicamentoLidocaina._textoObs(
            'Efeitos adversos: ardência, parestesias, tremores'),
        MedicamentoLidocaina._textoObs('Sinais precoces de toxicidade:'),
        MedicamentoLidocaina._textoObs('  - Zumbido, gosto metálico'),
        MedicamentoLidocaina._textoObs('  - Tontura, visão turva'),
        MedicamentoLidocaina._textoObs('  - Parestesias perioral'),
        MedicamentoLidocaina._textoObs('  - Agitação, confusão'),
        MedicamentoLidocaina._textoObs('Toxicidade severa (raro):'),
        MedicamentoLidocaina._textoObs('  - Convulsões'),
        MedicamentoLidocaina._textoObs('  - Arritmias cardíacas'),
        MedicamentoLidocaina._textoObs('  - Colapso circulatório'),
        MedicamentoLidocaina._textoObs('  - Parada cardiorrespiratória'),
        MedicamentoLidocaina._textoObs(
            'Tratamento toxicidade: lipidoterapia (Intralipid 20%)'),
        MedicamentoLidocaina._textoObs('EVITAR vasoconstritor em:'),
        MedicamentoLidocaina._textoObs(
            '  - Dedos, orelhas (tradicionalmente)*'),
        MedicamentoLidocaina._textoObs('  - Nariz, pênis (tradicionalmente)*'),
        MedicamentoLidocaina._textoObs(
            '  * Literatura recente questiona essa contraindicação'),
        MedicamentoLidocaina._textoObs('Contraindicado: infecção local'),
        MedicamentoLidocaina._textoObs('Contraindicado: alergia a amidas'),
        MedicamentoLidocaina._textoObs('Cautela em hepatopatia grave'),
        MedicamentoLidocaina._textoObs('Categoria B na gravidez (segura)'),
        MedicamentoLidocaina._textoObs('Segura na lactação'),
        MedicamentoLidocaina._textoObs('Compatível com SF 0,9%'),
        MedicamentoLidocaina._textoObs(
            'Incompatível com bicarbonato (precipitação)'),
        MedicamentoLidocaina._textoObs('Armazenar 15-30°C, proteger da luz'),
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

  static Widget _linhaIndicacaoTexto({
    required String titulo,
    required String descricaoDose,
    required String textoCalculo,
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
              textoCalculo,
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
