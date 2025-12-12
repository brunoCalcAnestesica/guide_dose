import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCisatracurio {
  static const String nome = 'Cisatracúrio';
  static const String idBulario = 'cisatracurio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/cisatracurio.json');
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
      conteudo: _buildCardCisatracurio(
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
    // Cisatracúrio tem indicações para todas as faixas etárias
    switch (faixaEtaria) {
      case 'Recém-nascido':
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
        MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
          titulo: 'Intubação orotraqueal',
          descricaoDose: '0,15-0,2 mg/kg IV em bolus',
          unidade: 'mg',
          dosePorKgMinima: 0.15,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
        MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção - bolus adicionais',
          descricaoDose: '0,03 mg/kg IV bolus',
          unidade: 'mg',
          dosePorKg: 0.03,
          peso: peso,
        ),
        MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção - infusão contínua',
          descricaoDose: '1-3 mcg/kg/min IV contínua',
          unidade: 'mcg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 3,
          peso: peso,
        ),
        MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
          titulo: 'Ventilação mecânica prolongada',
          descricaoDose: '1-2 mcg/kg/min IV contínua',
          unidade: 'mcg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
      ];
    } else {
      // Pediatria
      return [
        if (faixaEtaria == 'Recém-nascido') ...[
          MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
            titulo: 'Recém-nascido - intubação (dados limitados)',
            descricaoDose: '0,15 mg/kg IV bolus (usar com cautela)',
            unidade: 'mg',
            dosePorKg: 0.15,
            peso: peso,
          ),
        ] else if (faixaEtaria == 'Lactente') ...[
          MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
            titulo: 'Lactente - intubação',
            descricaoDose: '0,15 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKg: 0.15,
            peso: peso,
          ),
          MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
            titulo: 'Lactente - infusão contínua',
            descricaoDose: '1,5-2,5 mcg/kg/min IV contínua',
            unidade: 'mcg',
            dosePorKgMinima: 1.5,
            dosePorKgMaxima: 2.5,
            peso: peso,
          ),
        ] else if (faixaEtaria == 'Criança') ...[
          MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
            titulo: 'Criança - intubação',
            descricaoDose: '0,1-0,15 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.15,
            peso: peso,
          ),
          MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
            titulo: 'Criança - infusão contínua',
            descricaoDose: '1-2 mcg/kg/min IV contínua',
            unidade: 'mcg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 2,
            peso: peso,
          ),
        ] else if (faixaEtaria == 'Adolescente') ...[
          MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
            titulo: 'Adolescente - intubação',
            descricaoDose: '0,15-0,2 mg/kg IV em bolus',
            unidade: 'mg',
            dosePorKgMinima: 0.15,
            dosePorKgMaxima: 0.2,
            peso: peso,
          ),
          MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
            titulo: 'Adolescente - manutenção',
            descricaoDose: '0,03 mg/kg IV bolus adicionais',
            unidade: 'mg',
            dosePorKg: 0.03,
            peso: peso,
          ),
          MedicamentoCisatracurio._linhaIndicacaoDoseCalculada(
            titulo: 'Adolescente - infusão contínua',
            descricaoDose: '1-3 mcg/kg/min IV contínua',
            unidade: 'mcg',
            dosePorKgMinima: 1,
            dosePorKgMaxima: 3,
            peso: peso,
          ),
        ],
      ];
    }
  }

  static Widget _buildCardCisatracurio(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Bloqueador neuromuscular não despolarizante, de ação intermediária, benzilisoquinolínico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCisatracurio._linhaPreparo('Ampolas 2 mg/mL (5 mL, 10 mL)', 'Pronto para uso'),
        MedicamentoCisatracurio._linhaPreparo('Concentração: 2 mg/mL', 'Para uso EV exclusivamente'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCisatracurio._linhaPreparo('Pronto para uso - bolus IV', 'Administrar lentamente em 20-30 segundos'),
        MedicamentoCisatracurio._linhaPreparo('Infusão contínua: 100 mg + 100 mL SF', 'Resulta em 1 mg/mL (1000 mcg/mL)'),
        MedicamentoCisatracurio._linhaPreparo('Infusão contínua: 50 mg + 100 mL SF', 'Resulta em 0,5 mg/mL (500 mcg/mL)'),
        MedicamentoCisatracurio._linhaPreparo('Infusão contínua: 20 mg + 100 mL SF', 'Resulta em 0,2 mg/mL (200 mcg/mL)'),
        MedicamentoCisatracurio._linhaPreparo('Preparações sob técnica asséptica', 'Usar imediatamente após preparo'),
        MedicamentoCisatracurio._linhaPreparo('Incompatível com soluções alcalinas', 'Bicarbonato de sódio'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCisatracurio._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCisatracurio._textoObs('Bloqueador neuromuscular não despolarizante de ação intermediária'),
        MedicamentoCisatracurio._textoObs('Antagonista competitivo dos receptores nicotínicos da acetilcolina'),
        MedicamentoCisatracurio._textoObs('Degradação espontânea por reação de Hofmann (não enzimática)'),
        MedicamentoCisatracurio._textoObs('NÃO induz liberação significativa de histamina'),
        MedicamentoCisatracurio._textoObs('Seguro em disfunção hepática ou renal'),
        MedicamentoCisatracurio._textoObs('Início: 2-3 min | Pico: 3-5 min | Duração: 40-60 min'),
        MedicamentoCisatracurio._textoObs('Recuperação 25%: 45-65 min | Meia-vida: 22-30 min'),
        MedicamentoCisatracurio._textoObs('Volume de distribuição: 0,11-0,16 L/kg'),
        MedicamentoCisatracurio._textoObs('Ligação às proteínas: 15%'),
        MedicamentoCisatracurio._textoObs('Metabolização: 77% reação de Hofmann, 23% hepática'),
        MedicamentoCisatracurio._textoObs('Excreção: renal 16-30%, biliar até 10%'),
        MedicamentoCisatracurio._textoObs('Monitorização neuromuscular (TOF) obrigatória'),
        MedicamentoCisatracurio._textoObs('Suporte ventilatório até reversão completa'),
        MedicamentoCisatracurio._textoObs('Categoria B na gestação - usar se necessário'),
        MedicamentoCisatracurio._textoObs('Potencializado por anestésicos voláteis'),
        MedicamentoCisatracurio._textoObs('Potencializado por aminoglicosídeos, magnésio, lítio'),
        MedicamentoCisatracurio._textoObs('Efeito reduzido por anticonvulsivantes crônicos'),
        MedicamentoCisatracurio._textoObs('Prolongado em hipotermia e acidose grave'),
        MedicamentoCisatracurio._textoObs('Menor risco de hipotensão e broncoespasmo'),
        MedicamentoCisatracurio._textoObs('Bradicardia, hipotensão leve transitória'),
        MedicamentoCisatracurio._textoObs('Reações anafiláticas raras (<0,1%)'),
        MedicamentoCisatracurio._textoObs('Armazenar refrigerado (2-8°C)'),
        MedicamentoCisatracurio._textoObs('Estável 24h após diluição se refrigerado'),
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
      if (doseFixa < 1) {
        textoDose = '${doseFixa.toStringAsFixed(2)} $unidade';
      } else {
        textoDose = '${doseFixa.toStringAsFixed(1)} $unidade';
      }
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
      if (doseCalculada < 1) {
        textoDose = '${doseCalculada.toStringAsFixed(2)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      }
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
      if (doseMin < 1 && doseMax < 1) {
        textoDose = '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
      } else if (doseMin < 1) {
        textoDose = '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
      }
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    if (isAdulto) {
      // Infusão contínua para adultos
      final opcoesConcentracoes = {
        '100 mg em 100 mL SF (1000 mcg/mL)': 1000.0,
        '50 mg em 100 mL SF (500 mcg/mL)': 500.0,
        '20 mg em 100 mL SF (200 mcg/mL)': 200.0,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoCisatracurio._textoObs('Infusão contínua: 1-3 mcg/kg/min para manutenção'),
          MedicamentoCisatracurio._textoObs('Ventilação prolongada: 1-2 mcg/kg/min'),
          MedicamentoCisatracurio._textoObs('Monitorização neuromuscular (TOF) obrigatória'),
          MedicamentoCisatracurio._textoObs('Bomba de infusão volumétrica obrigatória'),
          MedicamentoCisatracurio._textoObs('Suporte ventilatório até reversão completa'),
          const SizedBox(height: 12),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mcg/kg/min',
            doseMin: 1.0,
            doseMax: 3.0,
          ),
        ],
      );
    } else {
      // Pediatria - infusão contínua
      final opcoesConcentracoes = {
        '50 mg em 100 mL SF (500 mcg/mL)': 500.0,
        '20 mg em 100 mL SF (200 mcg/mL)': 200.0,
        '10 mg em 100 mL SF (100 mcg/mL)': 100.0,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoCisatracurio._textoObs('Infusão contínua pediátrica: 1-2,5 mcg/kg/min'),
          MedicamentoCisatracurio._textoObs('Monitorização neuromuscular (TOF) obrigatória'),
          MedicamentoCisatracurio._textoObs('Bomba de infusão volumétrica obrigatória'),
          MedicamentoCisatracurio._textoObs('Suporte ventilatório até reversão completa'),
          const SizedBox(height: 12),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mcg/kg/min',
            doseMin: 1.0,
            doseMax: 2.5,
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