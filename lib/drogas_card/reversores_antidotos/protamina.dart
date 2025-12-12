import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoProtamina {
  static const String nome = 'Protamina';
  static const String idBulario = 'protamina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/protamina.json');
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
      conteudo: _buildCardProtamina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardProtamina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoProtamina._textoObs('Antagonista da heparina - Agente neutralizante de anticoagulante'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoProtamina._linhaPreparo('Ampola 50mg/5mL (10mg/mL)', 'Solução injetável'),
        MedicamentoProtamina._linhaPreparo('Frasco-ampola 250mg/25mL (10mg/mL)', 'Cirurgia cardíaca'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoProtamina._linhaPreparo('50mg em 50mL SF 0,9%', '1 mg/mL para infusão lenta'),
        MedicamentoProtamina._linhaPreparo('50mg em 100mL SF 0,9%', '0,5 mg/mL para infusão muito lenta'),
        MedicamentoProtamina._linhaPreparo('Pode usar direto da ampola', 'Diluir em soro para controle velocidade'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoProtamina._linhaIndicacaoDoseFixa(
            titulo: 'Reversão heparina não fracionada (HNF)',
            descricaoDose: '1mg protamina neutraliza ~100 UI heparina (últimas 2h)',
            doseFixa: '1 mg = 100 UI',
          ),
          MedicamentoProtamina._linhaIndicacaoDoseFixa(
            titulo: 'Pós-cirurgia cardiovascular (CEC)',
            descricaoDose: 'Calcular: dose heparina total ÷ 100 = mg protamina',
            doseFixa: 'Conforme heparina',
          ),
          MedicamentoProtamina._linhaIndicacaoDoseFixa(
            titulo: 'Hemorragia por heparina',
            descricaoDose: 'Dose conforme tempo desde heparina: <30min: 100%, 30-60min: 50%, 60-120min: 25%',
            doseFixa: 'Ajustar pelo tempo',
          ),
          MedicamentoProtamina._linhaIndicacaoDoseFixa(
            titulo: 'Reversão parcial HBPM (enoxaparina)',
            descricaoDose: '1mg protamina neutraliza 1mg enoxaparina (60-70% efeito anti-Xa)',
            doseFixa: '1 mg = 1 mg HBPM',
          ),
        ] else ...[
          MedicamentoProtamina._linhaIndicacaoDoseCalculada(
            titulo: 'Reversão heparina pediátrica',
            descricaoDose: '1mg protamina neutraliza ~100 UI heparina',
            unidade: 'mg',
            dosePorKg: 1.0,
            doseMaxima: 50,
            peso: peso,
          ),
          MedicamentoProtamina._linhaIndicacaoDoseFixa(
            titulo: 'Cálculo dose pediátrica',
            descricaoDose: 'Dose heparina (UI nas últimas 2h) ÷ 100 = mg protamina',
            doseFixa: 'Conforme heparina',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoProtamina._textoObs('Antagonista específico da heparina - reverte anticoagulação'),
        MedicamentoProtamina._textoObs('Onset imediato (≤5 min). Duração: 2 horas'),
        MedicamentoProtamina._textoObs('ATENÇÃO: Administrar IV lento (máx 5mg/min, total ≥10 min)'),
        MedicamentoProtamina._textoObs('Dose máxima: 50mg/dose (doses maiores: fracionar)'),
        MedicamentoProtamina._textoObs('RISCO: Hipotensão, bradicardia, anafilaxia (derivado peixe)'),
        MedicamentoProtamina._textoObs('Contraindicado: alergia peixe, uso prévio insulina NPH/protamina'),
        MedicamentoProtamina._textoObs('Ter adrenalina, anti-histamínico, corticoide disponíveis'),
        MedicamentoProtamina._textoObs('Excesso: efeito anticoagulante paradoxal (inibe plaquetas, fator V)'),
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
