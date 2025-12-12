import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPancuronio {
  static const String nome = 'Pancurônio';
  static const String idBulario = 'pancuronio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/pancuronio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardPancuronio(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardPancuronio(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPancuronio._textoObs('Bloqueador neuromuscular não despolarizante (aminosteroide), relaxante muscular esquelético'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPancuronio._linhaPreparo('Ampola 2 mg/2 mL (1 mg/mL)', 'Solução injetável'),
        MedicamentoPancuronio._linhaPreparo('Ampola 4 mg/2 mL (2 mg/mL)', 'Solução injetável'),
        MedicamentoPancuronio._linhaPreparo('Frasco-ampola 10 mg/5 mL (2 mg/mL)', 'Uso hospitalar'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPancuronio._linhaPreparo('Bolus IV: usar direto da ampola', '1-2 mg/mL concentração'),
        MedicamentoPancuronio._linhaPreparo('Infusão contínua: 20 mg em 100 mL SF 0,9%', '0,2 mg/mL = 200 mcg/mL'),
        MedicamentoPancuronio._linhaPreparo('Alternativa: 40 mg em 200 mL SF 0,9%', '0,2 mg/mL'),
        MedicamentoPancuronio._linhaPreparo('Estável 24h refrigerado, 12h temperatura ambiente', 'Proteger da luz'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPancuronio._buildConversorInfusao(peso, faixaEtaria),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPancuronio._textoObs('Bloqueador neuromuscular de longa duração (60-90 min)'),
        MedicamentoPancuronio._textoObs('ATENÇÃO: Usar somente sob anestesia/sedação profunda - paciente consciente = paralisia consciente'),
        MedicamentoPancuronio._textoObs('OBRIGATÓRIO: Monitorização neuromuscular TOF (train-of-four) contínua'),
        MedicamentoPancuronio._textoObs('Efeitos vagolíticos: taquicardia (↑FC 15-30 bpm), ↑PA (10-20%)'),
        MedicamentoPancuronio._textoObs('Antagonizar ao final: neostigmina 40-70 mcg/kg + atropina OU sugamadex 2-4 mg/kg'),
        MedicamentoPancuronio._textoObs('Onset: 2,5-3 min (intubação em 3-4 min)'),
        MedicamentoPancuronio._textoObs('Ajustar dose: idosos (-30-40%), insuficiência renal (-25-50%)'),
        MedicamentoPancuronio._textoObs('Risco miopatia prolongada: uso >48-72h em UTI (especialmente com corticoides)'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(String faixaEtaria, double peso) {
    List<Widget> indicacoes = [];

    switch (faixaEtaria) {
      case 'Neonato':
        indicacoes.addAll([
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação Orotraqueal',
            descricaoDose: 'Dose: 0,04-0,06 mg/kg IV bolus (neonatos mais sensíveis)',
            unidade: 'mg',
            dosePorKgMinima: 0.04,
            dosePorKgMaxima: 0.06,
            peso: peso,
          ),
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção Cirúrgica (doses incrementais)',
            descricaoDose: 'Dose: 0,01-0,02 mg/kg IV a cada 40-60 min',
            unidade: 'mg',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.02,
            peso: peso,
          ),
        ]);
        break;
      case 'Lactente':
      case 'Criança':
        indicacoes.addAll([
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação Orotraqueal',
            descricaoDose: 'Dose: 0,1-0,15 mg/kg IV bolus (maior Vd, clearance aumentado)',
            unidade: 'mg',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.15,
            peso: peso,
          ),
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção Cirúrgica',
            descricaoDose: 'Dose: 0,01-0,03 mg/kg IV a cada 30-45 min',
            unidade: 'mg',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.03,
            peso: peso,
          ),
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Relaxamento Prolongado (UTI)',
            descricaoDose: 'Bolus inicial: 0,06-0,1 mg/kg IV',
            unidade: 'mg',
            dosePorKgMinima: 0.06,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
        ]);
        break;
      case 'Adolescente':
      case 'Adulto':
        indicacoes.addAll([
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação Orotraqueal (Sequência Rápida ou Eletiva)',
            descricaoDose: 'Dose: 0,08-0,1 mg/kg IV bolus (intubação em 3-4 min)',
            unidade: 'mg',
            dosePorKgMinima: 0.08,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Relaxamento Muscular Intraoperatório',
            descricaoDose: 'Doses incrementais: 0,01-0,02 mg/kg IV a cada 40-60 min',
            unidade: 'mg',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.02,
            peso: peso,
          ),
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'UTI - Bloqueio Prolongado (SARA, Ventilação Controlada)',
            descricaoDose: 'Bolus inicial: 0,06-0,1 mg/kg IV',
            unidade: 'mg',
            dosePorKgMinima: 0.06,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Eletroconvulsoterapia (ECT)',
            descricaoDose: 'Dose: 0,04-0,06 mg/kg IV (bloqueio leve)',
            unidade: 'mg',
            dosePorKgMinima: 0.04,
            dosePorKgMaxima: 0.06,
            peso: peso,
          ),
        ]);
        break;
      case 'Idoso':
        indicacoes.addAll([
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação Orotraqueal (reduzir dose)',
            descricaoDose: 'Dose: 0,05-0,07 mg/kg IV (redução 30-40% - clearance reduzido)',
            unidade: 'mg',
            dosePorKgMinima: 0.05,
            dosePorKgMaxima: 0.07,
            peso: peso,
          ),
          MedicamentoPancuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção Cirúrgica',
            descricaoDose: 'Dose: 0,01 mg/kg IV a cada 50-70 min (duração prolongada)',
            unidade: 'mg',
            dosePorKg: 0.01,
            peso: peso,
          ),
        const SizedBox(height: 8),
          MedicamentoPancuronio._textoObs('• Idosos: ↑duração bloqueio, ↓clearance - monitorar TOF rigorosamente'),
          MedicamentoPancuronio._textoObs('• Risco aumentado bloqueio residual pós-operatório'),
        ]);
        break;
    }

    return indicacoes;
  }

  static Widget _buildConversorInfusao(double peso, String faixaEtaria) {
    final opcoesConcentracoes = {
      '10mg em 100mL SF 0,9% (0,1 mg/mL)': 0.1,
      '20mg em 100mL SF 0,9% (0,2 mg/mL)': 0.2,
      '20mg em 50mL SF 0,9% (0,4 mg/mL)': 0.4,
      '40mg em 100mL SF 0,9% (0,4 mg/mL)': 0.4,
      '40mg em 200mL SF 0,9% (0,2 mg/mL)': 0.2,
      '50mg em 100mL SF 0,9% (0,5 mg/mL)': 0.5,
      '100mg em 250mL SF 0,9% (0,4 mg/mL)': 0.4,
    };

    double doseMin;
    double doseMax;

    switch (faixaEtaria) {
      case 'Neonato':
        doseMin = 0.01;
        doseMax = 0.05;
        break;
      case 'Lactente':
      case 'Criança':
        doseMin = 0.02;
        doseMax = 0.08;
        break;
      case 'Adolescente':
      case 'Adulto':
        doseMin = 0.01;
        doseMax = 0.12;
        break;
      case 'Idoso':
        doseMin = 0.005;
        doseMax = 0.04;
        break;
      default:
        doseMin = 0.01;
        doseMax = 0.05;
    }

    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: opcoesConcentracoes,
      unidade: 'mg/kg/h',
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
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(2)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose = '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
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
