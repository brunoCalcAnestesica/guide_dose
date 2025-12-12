import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoVecuronio {
  static const String nome = 'Vecurônio';
  static const String idBulario = 'vecuronio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/vecuronio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardVecuronio(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardVecuronio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVecuronio._textoObs('• Bloqueador neuromuscular não despolarizante - Ação intermediária - Esteroidal'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVecuronio._linhaPreparo('Frasco 4mg liofilizado', 'Norcuron®'),
        MedicamentoVecuronio._linhaPreparo('Frasco 10mg liofilizado', 'Norcuron®'),
        MedicamentoVecuronio._linhaPreparo('Início: 2-3 min | Pico: 3-5 min', 'Ação intermediária'),
        MedicamentoVecuronio._linhaPreparo('Duração: 25-40 min', 'Recuperação 25%: 45-65 min'),
        MedicamentoVecuronio._linhaPreparo('Meia-vida: 65-75 min', 'Metabolismo hepático'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVecuronio._linhaPreparo('Reconstituir pó com 5mL SF 0,9%', 'Concentração 1mg/mL'),
        MedicamentoVecuronio._linhaPreparo('Para infusão: 50mg em 50mL SF', 'Concentração 1mg/mL (1000 mcg/mL)'),
        MedicamentoVecuronio._linhaPreparo('Compatível: SF 0,9%, SG 5%, Ringer', 'Incompatível: bicarbonato'),
        MedicamentoVecuronio._linhaPreparo('Armazenar: 2-8°C refrigerado', 'Usar reconstituído em 24h'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoVecuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação orotraqueal eletiva',
            descricaoDose: '0,08-0,1 mg/kg IV bolus (20-30 seg)',
            unidade: 'mg',
            dosePorKgMinima: 0.08,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
          MedicamentoVecuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção bloqueio (doses adicionais)',
            descricaoDose: '0,01-0,015 mg/kg IV bolus a cada 15-25 min',
            unidade: 'mg',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.015,
            peso: peso,
          ),
        ] else ...[
          MedicamentoVecuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação neonato <1 mês',
            descricaoDose: '0,05-0,06 mg/kg IV bolus (maior sensibilidade)',
            unidade: 'mg',
            dosePorKgMinima: 0.05,
            dosePorKgMaxima: 0.06,
            peso: peso,
          ),
          MedicamentoVecuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação lactente 1-23 meses',
            descricaoDose: '0,08-0,1 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKgMinima: 0.08,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
          MedicamentoVecuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação criança 2-12 anos',
            descricaoDose: '0,1 mg/kg IV bolus (maior resistência)',
            unidade: 'mg',
            dosePorKg: 0.1,
            peso: peso,
          ),
          MedicamentoVecuronio._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção pediátrica',
            descricaoDose: '0,01-0,015 mg/kg IV bolus',
            unidade: 'mg',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.015,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVecuronio._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVecuronio._textoObs('• Antagonista competitivo receptores nicotínicos ACh - paralisia flácida'),
        MedicamentoVecuronio._textoObs('• Ação intermediária (25-40 min) - entre rocurônio e pancurônio'),
        MedicamentoVecuronio._textoObs('• Perfil cardiovascular estável - sem liberação histamina significativa'),
        MedicamentoVecuronio._textoObs('• Metabolismo hepático - metabólito 3-desacetilvecurônio (ativo)'),
        MedicamentoVecuronio._textoObs('• Excreção biliar (40-50%) + renal (30-40%)'),
        MedicamentoVecuronio._textoObs('• Indicação: intubação eletiva, manutenção bloqueio cirúrgico, ventilação UTI'),
        MedicamentoVecuronio._textoObs('• Neonatos: maior sensibilidade - dose menor (0,05-0,06 mg/kg)'),
        MedicamentoVecuronio._textoObs('• Crianças: maior resistência - dose maior (0,1 mg/kg)'),
        MedicamentoVecuronio._textoObs('• ATENÇÃO: Acúmulo em IR/hepatopatia (metabólito ativo) - bloqueio prolongado'),
        MedicamentoVecuronio._textoObs('• ATENÇÃO: Potencializado por anestésicos voláteis, aminoglicosídeos, magnésio, lítio'),
        MedicamentoVecuronio._textoObs('• ATENÇÃO: Bloqueio residual pós-op - monitorar TOF (alvo TOF >0,9)'),
        MedicamentoVecuronio._textoObs('• Monitorar: TOF contínuo (Train-of-Four), capnografia, SpO2'),
        MedicamentoVecuronio._textoObs('• Reversão: neostigmina 0,05 mg/kg ou sugammadex 2-4 mg/kg'),
        MedicamentoVecuronio._textoObs('• Vantagens: estabilidade CV, sem histamina, previsível'),
        MedicamentoVecuronio._textoObs('• Contraindicado: hipersensibilidade, alergia bloqueadores neuromusculares'),
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
    double? doseMaxima,
    required double peso,
  }) {
    String? textoDose;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    return ConversaoInfusaoSlider(
      peso: peso,
      opcoesConcentracoes: {
        '10mg em 10mL (1mg/mL)': 1.0,
        '50mg em 50mL (1mg/mL)': 1.0,
      },
      doseMin: isAdulto ? 0.8 : 1.0,
      doseMax: isAdulto ? 1.2 : 1.5,
      unidade: 'mcg/kg/min',
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
