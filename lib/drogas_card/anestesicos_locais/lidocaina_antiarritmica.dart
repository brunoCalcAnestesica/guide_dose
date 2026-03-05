import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoLidocainaAntiarritmica {
  static const String nome = 'Lidocaína Antiarrítmica';
  static const String idBulario = 'lidocainaantiarritmica';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle
        .loadString('assets/medicamentos/lidocainaantiarritmica.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Lidocaína antiarrítmica tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardLidocainaAntiarritmica(
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

    return _buildCardLidocainaAntiarritmica(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardLidocainaAntiarritmica(
      BuildContext context,
      double peso,
      bool isAdulto,
      bool isFavorito,
      VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Antiarrítmico classe IB - Bloqueador de canais de sódio'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLidocainaAntiarritmica._linhaPreparo(
            'Ampola 2% (20mg/mL)', '2mL, 5mL, 10mL'),
        MedicamentoLidocainaAntiarritmica._linhaPreparo(
            'Frasco-ampola 1% (10mg/mL)', '20mL, 50mL, 100mL'),
        MedicamentoLidocainaAntiarritmica._linhaPreparo(
            'IMPORTANTE', 'Usar formulação SEM vasoconstritor'),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLidocainaAntiarritmica._linhaPreparo(
            'Bolus', 'Usar direto da ampola 20mg/mL ou diluir'),
        MedicamentoLidocainaAntiarritmica._linhaPreparo(
            'Infusão', '1000mg (50mL de 2%) em 500mL SF 0,9% = 2mg/mL'),
        MedicamentoLidocainaAntiarritmica._linhaPreparo(
            'Infusão alternativa', '500mg em 250mL SF 0,9% = 2mg/mL'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoLidocainaAntiarritmica._linhaIndicacaoDoseCalculada(
            titulo: 'Taquicardia ventricular monomórfica sustentada (bolus)',
            descricaoDose: '1-1,5 mg/kg IV em 2-3 minutos',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 1.5,
            peso: peso,
          ),
          MedicamentoLidocainaAntiarritmica._linhaIndicacaoDoseCalculada(
            titulo: 'Fibrilação ventricular recorrente (bolus)',
            descricaoDose: '1-1,5 mg/kg IV',
            unidade: 'mg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 1.5,
            peso: peso,
          ),
          MedicamentoLidocainaAntiarritmica._linhaIndicacaoDoseCalculada(
            titulo: 'Bolus adicional (se necessário)',
            descricaoDose:
                '0,5-0,75 mg/kg IV a cada 5-10min (máx 3 mg/kg total)',
            unidade: 'mg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 0.75,
            peso: peso,
            doseMaxima: 210, // 3 mg/kg para 70kg
          ),
          MedicamentoLidocainaAntiarritmica._linhaIndicacaoTexto(
            titulo: 'Extra-sístoles ventriculares (IAM)',
            descricaoDose: 'Bolus 1 mg/kg + infusão 1-4 mg/min',
            textoCalculo: 'Dose bolus: ${(1.0 * peso).toStringAsFixed(0)} mg',
          ),
        ] else ...[
          MedicamentoLidocainaAntiarritmica._linhaIndicacaoDoseCalculada(
            titulo: 'Taquicardia ventricular pediátrica (bolus)',
            descricaoDose: '1 mg/kg IV em bolus lento',
            unidade: 'mg',
            dosePorKg: 1,
            peso: peso,
          ),
          MedicamentoLidocainaAntiarritmica._linhaIndicacaoTexto(
            titulo: 'Infusão contínua pediátrica',
            descricaoDose: '20-50 mcg/kg/min',
            textoCalculo:
                '${(20 * peso).toStringAsFixed(0)}-${(50 * peso).toStringAsFixed(0)} mcg/min',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLidocainaAntiarritmica._buildInfoInfusao(peso, isAdulto),

        const SizedBox(height: 16),

        // Observações
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Início de ação IV: 30-90 segundos'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Pico de efeito: 1-5 minutos'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Duração bolus único: 10-20 minutos'),
        MedicamentoLidocainaAntiarritmica._textoObs('Meia-vida: 1,5-2 horas'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Meia-vida prolongada em ICC/hepatopatia: 3-4 horas'),
        MedicamentoLidocainaAntiarritmica._textoObs('Ligação proteica: 60-80%'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Metabolização: hepática (CYP1A2, CYP3A4)'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Metabólitos ativos: MEGX e GX (podem acumular)'),
        MedicamentoLidocainaAntiarritmica._textoObs('Excreção: renal (90%)'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Bloqueia canais de sódio em miocárdio ventricular'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Suprime automaticidade ventricular'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Efeito preferencial em tecido isquêmico'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'NÃO afeta condução AV significativamente'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Encurta período refratário efetivo'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Dose máxima bolus cumulativo: 3 mg/kg'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Infusão máxima adultos: 4 mg/min'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Infusão máxima pediátrica: 50 mcg/kg/min'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Monitorização ECG contínua obrigatória'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Ter suporte avançado de vida disponível'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Nível terapêutico: 1,5-5 mcg/mL'),
        MedicamentoLidocainaAntiarritmica._textoObs('Nível tóxico: >5 mcg/mL'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Sinais precoces de toxicidade:'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            '  - Zumbido, gosto metálico'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            '  - Parestesia perioral, tontura'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            '  - Visão turva, tremores'),
        MedicamentoLidocainaAntiarritmica._textoObs('Toxicidade severa:'),
        MedicamentoLidocainaAntiarritmica._textoObs('  - Convulsões'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            '  - Bradicardia, bloqueio AV'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            '  - Hipotensão, colapso cardiovascular'),
        MedicamentoLidocainaAntiarritmica._textoObs('  - Assistolia'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Tratamento toxicidade: lipidoterapia (Intralipid 20%)'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Reduzir dose 30-50% em hepatopatia'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Reduzir dose em ICC (↓ clearance)'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Cautela em acúmulo de metabólitos (IRC)'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Contraindicado: bloqueio AV 2º/3º grau sem marcapasso'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Contraindicado: síndrome do nó sinusal'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Contraindicado: bradicardia severa'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Compatível com SF 0,9% e SG 5%'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Incompatível com bicarbonato (precipitação)'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Categoria B na gravidez (segura em emergências)'),
        MedicamentoLidocainaAntiarritmica._textoObs(
            'Segura na lactação (uso agudo)'),
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

  static Widget _buildInfoInfusao(double peso, bool isAdulto) {
    if (isAdulto) {
      // Cálculos para adulto
      final mlHoraMin =
          ((1 * 60) / 2).toStringAsFixed(0); // 1 mg/min em mL/h com conc 2mg/mL
      final mlHoraMax = ((4 * 60) / 2).toStringAsFixed(0); // 4 mg/min em mL/h

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Preparo: 1000mg em 500mL SF 0,9% (2 mg/mL)'),
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Taxa de infusão: 1-4 mg/min'),
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Velocidade: $mlHoraMin-$mlHoraMax mL/h (30-120 mL/h)'),
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Dose típica inicial: 2 mg/min (60 mL/h)'),
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Ajustar conforme resposta e tolerância'),
        ],
      );
    } else {
      // Cálculos para pediatria
      final infusaoMinMcg = (20 * peso).toStringAsFixed(0); // mcg/min
      final infusaoMaxMcg = (50 * peso).toStringAsFixed(0); // mcg/min
      final infusaoMinMg = (20 * peso / 1000).toStringAsFixed(2); // mg/min
      final infusaoMaxMg = (50 * peso / 1000).toStringAsFixed(2); // mg/min

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Preparo: 500mg em 250mL SF 0,9% (2 mg/mL)'),
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Taxa pediátrica: 20-50 mcg/kg/min'),
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Para ${peso.toStringAsFixed(0)}kg: $infusaoMinMcg-$infusaoMaxMcg mcg/min ($infusaoMinMg-$infusaoMaxMg mg/min)'),
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Converter: mcg/min ÷ 1000 = mg/min, depois mg/min ÷ 2 = mL/h × 60'),
          MedicamentoLidocainaAntiarritmica._textoObs(
              'Ajustar conforme resposta clínica'),
        ],
      );
    }
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
