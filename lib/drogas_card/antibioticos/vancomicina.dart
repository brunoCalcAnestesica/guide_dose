import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoVancomicina {
  static const String nome = 'Vancomicina';
  static const String idBulario = 'vancomicina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/vancomicina.json');
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
      conteudo: _buildCardVancomicina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardVancomicina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVancomicina._textoObs('• Antibiótico glicopeptídeo - Bactericida tempo-dependente - Inibe parede celular'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVancomicina._linhaPreparo('Frasco 500mg, 1g, 2g liofilizado', 'Vancocin® / Norvan®'),
        MedicamentoVancomicina._linhaPreparo('Pico: 1-2h | Duração: 8-12h', 'Meia-vida: 4-6h'),
        MedicamentoVancomicina._linhaPreparo('Ligação proteica: 30-55%', 'Excreção renal >90%'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVancomicina._linhaPreparo('Reconstituir 1g em 10mL água estéril', 'Concentração 100mg/mL'),
        MedicamentoVancomicina._linhaPreparo('Diluir em 100-250mL SF 0,9% ou SG 5%', 'Concentração final ≤5mg/mL'),
        MedicamentoVancomicina._linhaPreparo('Infusão ≥60 min OBRIGATÓRIA', 'Evitar síndrome homem vermelho'),
        MedicamentoVancomicina._linhaPreparo('Incompatível: aminoglicosídeos, soluções alcalinas', 'Via exclusiva'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoVancomicina._linhaIndicacaoDoseCalculada(
            titulo: 'Infecções graves por MRSA (bacteremia, pneumonia, endocardite)',
            descricaoDose: '15-20 mg/kg IV a cada 8-12h (AUC alvo 400-600)',
            unidade: 'mg',
            dosePorKgMinima: 15.0,
            dosePorKgMaxima: 20.0,
            peso: peso,
          ),
          MedicamentoVancomicina._linhaIndicacaoDoseCalculada(
            titulo: 'Meningite bacteriana (S. pneumoniae resistente)',
            descricaoDose: '15-20 mg/kg IV a cada 8-12h + monitorar níveis',
            unidade: 'mg',
            dosePorKgMinima: 15.0,
            dosePorKgMaxima: 20.0,
            peso: peso,
          ),
          MedicamentoVancomicina._linhaIndicacaoDoseFixa(
            titulo: 'Profilaxia cirúrgica (alérgico beta-lactâmico)',
            descricaoDose: '1g IV 60-120 min antes incisão (repetir se >2h cirurgia)',
            doseFixa: '1 g',
          ),
        ] else ...[
          MedicamentoVancomicina._linhaIndicacaoDoseCalculada(
            titulo: 'Infecções graves pediátricas (MRSA)',
            descricaoDose: '10-15 mg/kg IV a cada 6-12h (ajustar por idade/função renal)',
            unidade: 'mg',
            dosePorKgMinima: 10.0,
            dosePorKgMaxima: 15.0,
            peso: peso,
          ),
          MedicamentoVancomicina._linhaIndicacaoDoseCalculada(
            titulo: 'Neonatos (ajustar por idade pós-natal)',
            descricaoDose: '10-15 mg/kg IV a cada 12-24h (monitorar níveis)',
            unidade: 'mg',
            dosePorKgMinima: 10.0,
            dosePorKgMaxima: 15.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVancomicina._buildTextoInfusao(),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoVancomicina._textoObs('• Liga D-Ala-D-Ala peptidoglicano - impede síntese parede celular gram+'),
        MedicamentoVancomicina._textoObs('• Espectro: MRSA, Streptococcus, Enterococcus (exceto VRE), cocos gram+'),
        MedicamentoVancomicina._textoObs('• Farmacodinâmica: AUC/MIC >400 (infecções graves), vale 15-20 mg/L'),
        MedicamentoVancomicina._textoObs('• Indicação principal: MRSA (endocardite, pneumonia, bacteremia, osteomielite)'),
        MedicamentoVancomicina._textoObs('• ATENÇÃO: Infusão ≥60 min OBRIGATÓRIA (síndrome homem vermelho)'),
        MedicamentoVancomicina._textoObs('• ATENÇÃO: Nefrotoxicidade (doses >30 mg/kg/dia, uso >7 dias)'),
        MedicamentoVancomicina._textoObs('• ATENÇÃO: Ototoxicidade (altas doses, uso aminoglicosídeos)'),
        MedicamentoVancomicina._textoObs('• Monitorar: níveis séricos (vale pré-dose 4ª-5ª dose), função renal, audição'),
        MedicamentoVancomicina._textoObs('• Ajuste renal: ClCr <50 → intervalo 24h; ClCr <10 → 48-72h'),
        MedicamentoVancomicina._textoObs('• Interações: aminoglicosídeos, furosemida, anfotericina B (nefrotoxicidade)'),
        MedicamentoVancomicina._textoObs('• Síndrome homem vermelho: rash, rubor, prurido, hipotensão (infusão rápida)'),
        MedicamentoVancomicina._textoObs('• Contraindicado: IM (necrose), infusão rápida, hipersensibilidade'),
        MedicamentoVancomicina._textoObs('• Gravidez categoria B - seguro infecções graves maternas'),
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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

  static Widget _buildTextoInfusao() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Infusão contínua (uso crítico - UTI)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dose ataque: 15-25 mg/kg IV em 1-2h',
            style: TextStyle(fontSize: 12),
          ),
          const Text(
            'Manutenção: 30-40 mg/kg/dia em infusão contínua 24h',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vantagens: níveis séricos estáveis, melhor AUC/MIC',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const Text(
            'Indicação: infecções graves, MIC alta, pacientes críticos',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const Text(
            'Monitorar: níveis séricos 12-24h, ajustar por AUC',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
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
