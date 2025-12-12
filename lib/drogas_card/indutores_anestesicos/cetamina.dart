import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCetamina {
  static const String nome = 'Cetamina';
  static const String idBulario = 'cetamina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/cetamina.json');
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
      conteudo: _buildCardCetamina(
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
    // Cetamina tem indicações para todas as faixas etárias
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
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica IV',
          descricaoDose: '1-2 mg/kg IV',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica IM',
          descricaoDose: '4-6 mg/kg IM',
          unidade: 'mg',
          dosePorKgMinima: 4,
          dosePorKgMaxima: 6,
          peso: peso,
        ),
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação para procedimentos',
          descricaoDose: '0,25-0,5 mg/kg IV ou 2-4 mg/kg IM',
          unidade: 'mg',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Analgesia IV',
          descricaoDose: '0,1-0,3 mg/kg IV bolus',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ),
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção anestésica IV',
          descricaoDose: '0,5-2 mg/kg IV bolus ou infusão',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Depressão resistente (off-label)',
          descricaoDose: '0,5 mg/kg IV infundido em 40 min',
          unidade: 'mg',
          dosePorKg: 0.5,
          peso: peso,
        ),
      ];
    } else {
      // Pediatria
      return [
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica pediátrica IV',
          descricaoDose: '1-2 mg/kg IV',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          peso: peso,
        ),
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica pediátrica IM',
          descricaoDose: '4-6 mg/kg IM',
          unidade: 'mg',
          dosePorKgMinima: 4,
          dosePorKgMaxima: 6,
          peso: peso,
        ),
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pediátrica',
          descricaoDose: '0,25-0,5 mg/kg IV ou 2-4 mg/kg IM',
          unidade: 'mg',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoCetamina._linhaIndicacaoDoseCalculada(
          titulo: 'Analgesia pediátrica',
          descricaoDose: '0,1-0,3 mg/kg IV bolus',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ),
        if (faixaEtaria == 'Recém-nascido') ...[
          MedicamentoCetamina._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação neonatal',
            descricaoDose: '0,5-1 mg/kg IV',
            unidade: 'mg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1,
            peso: peso,
          ),
        ],
      ];
    }
  }

  static Widget _buildCardCetamina(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Anestésico geral dissociativo, antagonista não competitivo de receptores NMDA'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCetamina._linhaPreparo('Ampolas 50 mg/mL (2 mL, 5 mL, 10 mL)', 'Pronta para uso'),
        MedicamentoCetamina._linhaPreparo('Frascos-ampola 500 mg/10 mL (50 mg/mL)', 'Para reconstituição'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCetamina._linhaPreparo('Pronta para uso - bolus IV, IM ou SC', 'Utilizar diretamente da ampola'),
        MedicamentoCetamina._linhaPreparo('Infusão contínua: 50 mg + 50 mL SF', 'Resulta em 1 mg/mL'),
        MedicamentoCetamina._linhaPreparo('Infusão contínua: 100 mg + 50 mL SF', 'Resulta em 2 mg/mL'),
        MedicamentoCetamina._linhaPreparo('Infusão contínua: 50 mg + 100 mL SF', 'Resulta em 0,5 mg/mL'),
        MedicamentoCetamina._linhaPreparo('Infusão pediátrica: 25 mg + 50 mL SF', 'Resulta em 0,5 mg/mL'),
        MedicamentoCetamina._linhaPreparo('Infusão pediátrica: 25 mg + 100 mL SF', 'Resulta em 0,25 mg/mL'),
        MedicamentoCetamina._linhaPreparo('Preparações sob técnica asséptica', 'Usar imediatamente após preparo'),
        MedicamentoCetamina._linhaPreparo('Incompatível com soluções alcalinas', 'Bicarbonato de sódio, hemoderivados'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCetamina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCetamina._textoObs('Anestésico dissociativo - mantém reflexos protetores de via aérea'),
        MedicamentoCetamina._textoObs('Antagonista não competitivo dos receptores NMDA'),
        MedicamentoCetamina._textoObs('Potente efeito analgésico e sedativo com amnésia'),
        MedicamentoCetamina._textoObs('Efeito simpaticomimético - aumenta PA, FC e débito cardíaco'),
        MedicamentoCetamina._textoObs('Broncodilatação potente - útil em asma grave e broncoespasmo'),
        MedicamentoCetamina._textoObs('Início IV: 30-60 segundos | IM: 3-5 minutos | SC: 5-10 minutos'),
        MedicamentoCetamina._textoObs('Meia-vida: 2-4 horas | Volume de distribuição: 2-3 L/kg'),
        MedicamentoCetamina._textoObs('Ligação proteica: 20-50% | Excreção renal: ~90%'),
        MedicamentoCetamina._textoObs('Metabolização hepática via CYP3A4, CYP2B6, CYP2C9'),
        MedicamentoCetamina._textoObs('Mantém drive respiratório e tônus muscular'),
        MedicamentoCetamina._textoObs('Útil em pacientes hemodinamicamente instáveis'),
        MedicamentoCetamina._textoObs('Categoria B na gestação - segura em emergências obstétricas'),
        MedicamentoCetamina._textoObs('Potencializa efeitos de depressores do SNC'),
        MedicamentoCetamina._textoObs('Emergence delirium (agitação, alucinações)'),
        MedicamentoCetamina._textoObs('Hipersalivação, náusea, vômito, nistagmo'),
        MedicamentoCetamina._textoObs('Aumento da pressão intracraniana e intraocular'),
        MedicamentoCetamina._textoObs('Monitorização contínua obrigatória'),
        MedicamentoCetamina._textoObs('Ter sempre material para via aérea disponível'),
        MedicamentoCetamina._textoObs('Considerar pré-medicação com benzodiazepínicos'),
        MedicamentoCetamina._textoObs('CONTRAINDICADO: hipertensão severa, aneurismas, glaucoma'),
        MedicamentoCetamina._textoObs('CONTRAINDICADO: psicose ativa, angina instável'),
        MedicamentoCetamina._textoObs('Medicamento sujeito a controle especial (Portaria 344/98)'),
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
        textoDose = '${doseFixa.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
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
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
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
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
      } else if (doseMin < 1) {
        textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(0)} $unidade';
      } else {
        textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
      }
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
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
        '50 mg em 50 mL SF (1 mg/mL)': 1.0,
        '100 mg em 50 mL SF (2 mg/mL)': 2.0,
        '50 mg em 100 mL SF (0,5 mg/mL)': 0.5,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoCetamina._textoObs('Infusão contínua: 0,5-2 mg/kg/h para manutenção'),
          MedicamentoCetamina._textoObs('Analgesia contínua: 0,1-0,5 mg/kg/h'),
          MedicamentoCetamina._textoObs('Monitorização contínua obrigatória'),
          MedicamentoCetamina._textoObs('Bomba de infusão obrigatória'),
          MedicamentoCetamina._textoObs('Suporte de via aérea disponível'),
          const SizedBox(height: 12),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mg/kg/h',
            doseMin: 0.1,
            doseMax: 2.0,
          ),
        ],
      );
    } else {
      // Pediatria - infusão contínua
      final opcoesConcentracoes = {
        '25 mg em 50 mL SF (0,5 mg/mL)': 0.5,
        '50 mg em 50 mL SF (1 mg/mL)': 1.0,
        '25 mg em 100 mL SF (0,25 mg/mL)': 0.25,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoCetamina._textoObs('Infusão contínua pediátrica: 0,1-1,5 mg/kg/h'),
          MedicamentoCetamina._textoObs('Analgesia contínua: 0,1-0,3 mg/kg/h'),
          MedicamentoCetamina._textoObs('Monitorização contínua obrigatória'),
          MedicamentoCetamina._textoObs('Bomba de infusão obrigatória'),
          MedicamentoCetamina._textoObs('Suporte de via aérea disponível'),
          const SizedBox(height: 12),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mg/kg/h',
            doseMin: 0.1,
            doseMax: 1.5,
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