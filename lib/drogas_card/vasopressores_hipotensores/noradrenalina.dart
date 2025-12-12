import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoNoradrenalina {
  static const String nome = 'Noradrenalina';
  static const String idBulario = 'noradrenalina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/noradrenalina.json');
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
      conteudo: _buildCardNoradrenalina(
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

  static Widget _buildCardNoradrenalina(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNoradrenalina._textoObs('Vasopressor - Catecolamina'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNoradrenalina._linhaPreparo('Ampola 1mg/mL (4mL)', ''),
        MedicamentoNoradrenalina._linhaPreparo('Ampola 1mg/mL (1mL)', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNoradrenalina._linhaPreparo(
            '8mg em 250mL SG 5%', '32 mcg/mL'),
        MedicamentoNoradrenalina._linhaPreparo(
            '16mg em 250mL SG 5%', '64 mcg/mL'),
        MedicamentoNoradrenalina._linhaPreparo(
            '32mg em 250mL SG 5%', '128 mcg/mL'),

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
        MedicamentoNoradrenalina._buildConversorInfusao(peso, faixaEtaria),

        const SizedBox(height: 16),

        // Observações
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNoradrenalina._textoObs(
            'Vasopressor de ação rápida e potente'),
        MedicamentoNoradrenalina._textoObs(
            'Efeito vasoconstritor periférico e inotrópico positivo'),
        MedicamentoNoradrenalina._textoObs(
            'Monitorar PA, FC e perfusão periférica constantemente'),
        MedicamentoNoradrenalina._textoObs(
            'RISCO: isquemia periférica e necrose tecidual'),
        MedicamentoNoradrenalina._textoObs(
            'Usar com cautela em doença vascular periférica'),
        MedicamentoNoradrenalina._textoObs(
            'Pode causar bradicardia reflexa em altas doses'),
        MedicamentoNoradrenalina._textoObs(
            'Administrar via central sempre que possível'),
        MedicamentoNoradrenalina._textoObs(
            'Meia-vida muito curta (1-2 minutos)'),
        MedicamentoNoradrenalina._textoObs(
            'Interage com IMAOs e antidepressivos tricíclicos'),
        MedicamentoNoradrenalina._textoObs(
            'Extravasamento: risco de necrose - infiltrar com fentolamina'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(
      String faixaEtaria, double peso) {
    List<Widget> widgets = [];

    switch (faixaEtaria) {
      case 'Neonato':
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico',
          descricaoDose: '0,01-0,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão refratária',
          descricaoDose: '0,05-0,3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ));
        break;

      case 'Lactente':
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico',
          descricaoDose: '0,01-0,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão refratária',
          descricaoDose: '0,05-0,3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Parada cardíaca',
          descricaoDose: '0,1-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        break;

      case 'Criança':
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico',
          descricaoDose: '0,01-0,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão refratária',
          descricaoDose: '0,05-0,3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Parada cardíaca',
          descricaoDose: '0,1-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Suporte hemodinâmico',
          descricaoDose: '0,05-3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 3,
          peso: peso,
        ));
        break;

      case 'Adolescente':
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico',
          descricaoDose: '0,01-0,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão refratária',
          descricaoDose: '0,05-0,3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Parada cardíaca',
          descricaoDose: '0,1-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Suporte hemodinâmico',
          descricaoDose: '0,05-3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 3,
          peso: peso,
        ));
        break;

      case 'Adulto':
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico',
          descricaoDose: '0,01-0,5 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão refratária',
          descricaoDose: '0,05-0,3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Parada cardíaca',
          descricaoDose: '0,1-1 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 1,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Suporte hemodinâmico',
          descricaoDose: '0,05-3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 3,
          peso: peso,
        ));
        break;

      case 'Idoso':
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico',
          descricaoDose: '0,01-0,3 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão refratária',
          descricaoDose: '0,03-0,2 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.03,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Parada cardíaca',
          descricaoDose: '0,05-0,8 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 0.8,
          peso: peso,
        ));
        widgets.add(MedicamentoNoradrenalina._linhaIndicacaoDoseCalculada(
          titulo: 'Suporte hemodinâmico',
          descricaoDose: '0,03-2 mcg/kg/min IV infusão',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.03,
          dosePorKgMaxima: 2,
          peso: peso,
        ));
        break;
    }

    return widgets;
  }

  static Widget _buildConversorInfusao(double peso, String faixaEtaria) {
    final opcoesConcentracoes = {
      '8mg em 250mL (32 mcg/mL)': 32.0,
      '16mg em 250mL (64 mcg/mL)': 64.0,
      '32mg em 250mL (128 mcg/mL)': 128.0,
    };

    double doseMin;
    double doseMax;

    // Ajustar faixas conforme faixa etária e indicações
    switch (faixaEtaria) {
      case 'Neonato':
        doseMin = 0.01;
        doseMax = 0.5;
        break;
      case 'Lactente':
        doseMin = 0.01;
        doseMax = 1.0;
        break;
      case 'Criança':
        doseMin = 0.01;
        doseMax = 3.0;
        break;
      case 'Adolescente':
        doseMin = 0.01;
        doseMax = 3.0;
        break;
      case 'Adulto':
        doseMin = 0.01;
        doseMax = 3.0;
        break;
      case 'Idoso':
        doseMin = 0.01;
        doseMax = 2.0;
        break;
      default:
        doseMin = 0.01;
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
