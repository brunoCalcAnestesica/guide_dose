import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoBupivacaina {
  static const String nome = 'Bupivacaína';
  static const String idBulario = 'bupivacaina_infiltracao';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/bupivacaina_infiltracao.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Verificar se há indicações para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink(); // Não exibe o card se não há indicações
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardBupivacaina(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Bupivacaína tem indicações para todas as faixas etárias
    switch (faixaEtaria) {
      case 'Recém-nascido':
        // Uso em procedimentos cirúrgicos específicos
        return true;
      case 'Lactente':
      case 'Criança':
      case 'Adolescente':
      case 'Adulto':
      case 'Idoso':
        return true;
      default:
        return false;
    }
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    if (isAdulto) {
      return [
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Infiltração cirúrgica',
          descricaoDose: '0,25-0,5% - Dose máxima: 2 mg/kg',
          unidade: 'mg',
          doseMaxima: 2 * peso,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Infiltração com vasoconstritor',
          descricaoDose: '0,25-0,5% + adrenalina - Dose máxima: 3 mg/kg',
          unidade: 'mg',
          doseMaxima: 3 * peso,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Analgesia pós-operatória',
          descricaoDose: '0,25% - 20-30 mL (100-150 mg)',
          unidade: 'mg',
          doseFixa: 100,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Procedimentos odontológicos',
          descricaoDose: '0,25-0,5% - 5-10 mL conforme área',
          unidade: 'mg',
          doseMinima: 25,
          doseMaxima: 50,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Cateter peridural - Infusão',
          descricaoDose: '0,125-0,25% - 0,1-0,4 mg/kg/h',
          unidade: 'mg/h',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.4,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Cateter peridural - Bolus intermitente',
          descricaoDose: '0,125-0,25% - 5-15 mL a cada 4-8h',
          unidade: 'mg',
          doseMinima: 6.25,
          doseMaxima: 37.5,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Cateter bloqueio periférico - Infusão',
          descricaoDose: '0,125-0,25% - 0,1-0,3 mg/kg/h',
          unidade: 'mg/h',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ),
      ];
    } else {
      // Pediatria
      return [
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Infiltração pediátrica',
          descricaoDose: '0,25% - 1,25-2,5 mg/kg',
          unidade: 'mg',
          dosePorKgMinima: 1.25,
          dosePorKgMaxima: 2.5,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Procedimentos cirúrgicos pediátricos',
          descricaoDose: '0,25% - 1,25-2 mg/kg (máximo 2 mg/kg)',
          unidade: 'mg',
          dosePorKgMinima: 1.25,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Analgesia pós-operatória pediátrica',
          descricaoDose: '0,25% - 1-2 mg/kg diluído',
          unidade: 'mg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Cateter peridural pediátrico - Infusão',
          descricaoDose: '0,125% - 0,1-0,2 mg/kg/h',
          unidade: 'mg/h',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Cateter peridural pediátrico - Bolus',
          descricaoDose: '0,125-0,25% - 0,1-0,2 mg/kg a cada 6-8h',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
        MedicamentoBupivacaina._linhaIndicacaoDoseCalculada(
          titulo: 'Cateter bloqueio periférico pediátrico',
          descricaoDose: '0,125% - 0,1-0,2 mg/kg/h',
          unidade: 'mg/h',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
      ];
    }
  }

  static Widget _buildCardBupivacaina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Anestésico local do tipo amida, bloqueador de canais de sódio'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBupivacaina._linhaPreparo('Solução 0,25% - 10 mL, 20 mL, 50 mL', 'Sem vasoconstritor'),
        MedicamentoBupivacaina._linhaPreparo('Solução 0,5% - 10 mL, 20 mL, 50 mL', 'Sem vasoconstritor'),
        MedicamentoBupivacaina._linhaPreparo('Solução 0,75% - 10 mL, 20 mL', 'Sem vasoconstritor'),
        MedicamentoBupivacaina._linhaPreparo('Solução com adrenalina 1:200.000', 'Vasoconstritor'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBupivacaina._linhaPreparo('Infiltração local: pronta para uso', 'Não diluir - manter identificação'),
        MedicamentoBupivacaina._linhaPreparo('0,125%: 1 mL 0,5% + 3 mL SF = 4 mL', 'Concentração final 0,125%'),
        MedicamentoBupivacaina._linhaPreparo('0,25%: 1 mL 0,5% + 1 mL SF = 2 mL', 'Concentração final 0,25%'),
        MedicamentoBupivacaina._linhaPreparo('0,125%: 2 mL 0,25% + 2 mL SF = 4 mL', 'Alternativa para 0,125%'),
        MedicamentoBupivacaina._linhaPreparo('Cateter peridural: usar 0,125-0,25%', 'Diluir conforme fórmula acima'),
        MedicamentoBupivacaina._linhaPreparo('Cateter bloqueio periférico: usar 0,125%', 'Preferir concentração menor'),
        MedicamentoBupivacaina._linhaPreparo('Aspiração obrigatória antes da injeção', 'Evitar via intravascular'),
        MedicamentoBupivacaina._linhaPreparo('Técnica asséptica obrigatória', 'Injeção lenta e fracionada'),
        MedicamentoBupivacaina._linhaPreparo('Não misturar com soluções alcalinas', 'pH >6,5 causa precipitação'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua para Cateteres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBupivacaina._buildConversorInfusaoCateteres(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoBupivacaina._textoObs('Anestésico local de maior potência e cardiotoxicidade'),
        MedicamentoBupivacaina._textoObs('Duração: 4-12 horas (infiltração única)'),
        MedicamentoBupivacaina._textoObs('Alta lipossolubilidade - penetração rápida em fibras nervosas'),
        MedicamentoBupivacaina._textoObs('Bloqueio uso-dependente - maior eficácia em fibras ativas'),
        MedicamentoBupivacaina._textoObs('Monitorização por 30 min após administração'),
        MedicamentoBupivacaina._textoObs('Ter protocolo de lipidoterapia disponível'),
        MedicamentoBupivacaina._textoObs('Contraindicado: via intravascular, hipersensibilidade a amidas'),
        MedicamentoBupivacaina._textoObs('Cuidado com toxicidade sistêmica em doses altas'),
        MedicamentoBupivacaina._textoObs('Incompatível com bicarbonato de sódio'),
        MedicamentoBupivacaina._textoObs('Cateteres: monitorização rigorosa de sinais de toxicidade'),
        MedicamentoBupivacaina._textoObs('Peridural: doses menores para evitar bloqueio motor excessivo'),
        MedicamentoBupivacaina._textoObs('Bloqueio periférico: preferir concentrações mais baixas'),
        MedicamentoBupivacaina._textoObs('Bolus intermitente: avaliar resposta antes de repetir dose'),
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
    double? doseMinima,
    double? doseMaxima,
    double? doseFixa,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;
    bool doseLimite = false;

    if (doseFixa != null) {
      textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMinima != null && doseCalculada < doseMinima) {
        doseCalculada = doseMinima;
        doseLimite = true;
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
        doseLimite = true;
      }
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null && doseMin < doseMinima) {
        doseMin = doseMinima;
        doseLimite = true;
      }
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
        doseLimite = true;
      }
      // Verificar se dose mínima não ultrapassou a máxima
      if (doseMin > doseMax) doseMin = doseMax;
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(1)}–${doseMaxima.toStringAsFixed(1)} $unidade';
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
                color: doseLimite ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: doseLimite ? Colors.orange.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Dose calculada: $textoDose',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: doseLimite ? Colors.orange.shade700 : Colors.blue.shade700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (doseLimite) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Dose limitada por segurança',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildConversorInfusaoCateteres(double peso, bool isAdulto) {
    if (isAdulto) {
      // Infusão contínua para cateteres em adultos
      final opcoesConcentracoes = {
        '0,125% (1,25 mg/mL)': 1.25,
        '0,25% (2,5 mg/mL)': 2.5,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoBupivacaina._textoObs('Cateter peridural: 0,1-0,4 mg/kg/h'),
          MedicamentoBupivacaina._textoObs('Cateter bloqueio periférico: 0,1-0,3 mg/kg/h'),
          MedicamentoBupivacaina._textoObs('Monitorização rigorosa obrigatória'),
          const SizedBox(height: 12),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mg/kg/h',
            doseMin: 0.1,
            doseMax: 0.4,
          ),
        ],
      );
    } else {
      // Infusão contínua para cateteres em pediatria
      final opcoesConcentracoes = {
        '0,125% (1,25 mg/mL)': 1.25,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoBupivacaina._textoObs('Cateter peridural pediátrico: 0,1-0,2 mg/kg/h'),
          MedicamentoBupivacaina._textoObs('Cateter bloqueio periférico pediátrico: 0,1-0,2 mg/kg/h'),
          MedicamentoBupivacaina._textoObs('Preferir concentração 0,125% em pediatria'),
          MedicamentoBupivacaina._textoObs('Monitorização intensiva obrigatória'),
          const SizedBox(height: 12),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mg/kg/h',
            doseMin: 0.1,
            doseMax: 0.2,
          ),
        ],
      );
    }
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