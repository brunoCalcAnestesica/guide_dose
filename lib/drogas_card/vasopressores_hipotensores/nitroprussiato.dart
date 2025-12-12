import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoNitroprussiato {
  static const String nome = 'Nitroprussiato de Sódio';
  static const String idBulario = 'nitroprussiato';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/nitroprussiato.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    // Verificar se há indicações para a faixa etária selecionada
    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardNitroprussiato(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Todas as faixas etárias têm indicação
    return true;
  }

  static Widget _buildCardNitroprussiato(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNitroprussiato._textoObs(
            'Vasodilatador - Nitrovasodilatador potente'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNitroprussiato._linhaPreparo('Ampola 25mg/mL (2mL)', ''),
        MedicamentoNitroprussiato._linhaPreparo('Frasco-ampola 50mg', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNitroprussiato._linhaPreparo(
            '50mg em 250mL SG 5%', '200 mcg/mL'),
        MedicamentoNitroprussiato._linhaPreparo(
            '25mg em 250mL SG 5%', '100 mcg/mL'),
        MedicamentoNitroprussiato._linhaPreparo(
            '100mg em 250mL SG 5%', '400 mcg/mL'),
        MedicamentoNitroprussiato._linhaPreparo(
            'Proteger da luz', 'Fotossensível'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),

        const SizedBox(height: 16),

        // Infusão Contínua
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNitroprussiato._buildConversorInfusao(peso, faixaEtaria),

        const SizedBox(height: 16),

        // Observações
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNitroprussiato._textoObs(
            'Vasodilatador arterial e venoso de ação rápida'),
        MedicamentoNitroprussiato._textoObs(
            'Efeito anti-hipertensivo potente e imediato'),
        MedicamentoNitroprussiato._textoObs(
            'Monitorizar pressão arterial constantemente'),
        MedicamentoNitroprussiato._textoObs(
            'Risco de toxicidade por cianeto em doses >10 mcg/kg/min'),
        MedicamentoNitroprussiato._textoObs(
            'Monitorizar cianeto e tiocianato séricos'),
        MedicamentoNitroprussiato._textoObs(
            'FOTOSSENSÍVEL - proteger da luz durante infusão'),
        MedicamentoNitroprussiato._textoObs(
            'Usar com cautela em insuficiência renal ou hepática'),
        MedicamentoNitroprussiato._textoObs('Meia-vida curta (2-10 minutos)'),
        MedicamentoNitroprussiato._textoObs(
            'Metabolização em cianeto e tiocianato'),
        MedicamentoNitroprussiato._textoObs(
            'Suspender se sinais de toxicidade por cianeto'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(
      String faixaEtaria, double peso) {
    List<Widget> widgets = [];

    switch (faixaEtaria) {
      case 'Neonato':
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Crise hipertensiva',
          descricaoDose: '0,1-2 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 2,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial severa',
          descricaoDose: '0,5-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        break;

      case 'Lactente':
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Crise hipertensiva',
          descricaoDose: '0,1-2 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 2,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial severa',
          descricaoDose: '0,5-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca aguda',
          descricaoDose: '0,3-1,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 1.5,
          peso: peso,
        ));
        break;

      case 'Criança':
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Crise hipertensiva',
          descricaoDose: '0,1-2 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 2,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial severa',
          descricaoDose: '0,5-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca aguda',
          descricaoDose: '0,3-1,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 1.5,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Pós-operatório cardiovascular',
          descricaoDose: '0,5-3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 3,
          peso: peso,
        ));
        break;

      case 'Adolescente':
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Crise hipertensiva',
          descricaoDose: '0,1-2 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 2,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial severa',
          descricaoDose: '0,5-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca aguda',
          descricaoDose: '0,3-1,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 1.5,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Pós-operatório cardiovascular',
          descricaoDose: '0,5-3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 3,
          peso: peso,
        ));
        break;

      case 'Adulto':
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Crise hipertensiva',
          descricaoDose: '0,1-2 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 2,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial severa',
          descricaoDose: '0,5-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca aguda',
          descricaoDose: '0,3-1,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 1.5,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Pós-operatório cardiovascular',
          descricaoDose: '0,5-3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 3,
          peso: peso,
        ));
        break;

      case 'Idoso':
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Crise hipertensiva',
          descricaoDose: '0,05-1,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 1.5,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial severa',
          descricaoDose: '0,3-0,8 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.8,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca aguda',
          descricaoDose: '0,2-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.2,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        widgets.add(MedicamentoNitroprussiato._linhaIndicacaoDoseCalculada(
          titulo: 'Pós-operatório cardiovascular',
          descricaoDose: '0,3-2 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 2,
          peso: peso,
        ));
        break;
    }

    return widgets;
  }

  static Widget _buildConversorInfusao(double peso, String faixaEtaria) {
    final opcoesConcentracoes = {
      '25mg em 250mL (100 mcg/mL)': 100.0,
      '50mg em 250mL (200 mcg/mL)': 200.0,
      '100mg em 250mL (400 mcg/mL)': 400.0,
    };

    double doseMin;
    double doseMax;

    // Ajustar faixas conforme faixa etária e indicações
    switch (faixaEtaria) {
      case 'Neonato':
        doseMin = 0.1;
        doseMax = 2.0;
        break;
      case 'Lactente':
        doseMin = 0.1;
        doseMax = 2.0;
        break;
      case 'Criança':
        doseMin = 0.1;
        doseMax = 3.0;
        break;
      case 'Adolescente':
        doseMin = 0.1;
        doseMax = 3.0;
        break;
      case 'Adulto':
        doseMin = 0.1;
        doseMax = 3.0;
        break;
      case 'Idoso':
        doseMin = 0.05;
        doseMax = 2.0;
        break;
      default:
        doseMin = 0.1;
        doseMax = 3.0;
    }

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mcg/kg/min',
      doseMin: doseMin,
      doseMax: doseMax,
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

    // Remover "/kg" da unidade após o cálculo com peso
    String unidadeCalculada = unidade?.replaceAll('/kg', '') ?? '';

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(2)} $unidadeCalculada';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(2)}-${doseMax.toStringAsFixed(2)} $unidadeCalculada';
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
