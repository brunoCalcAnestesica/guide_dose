import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoTiossulfatoSodio {
  static const String nome = 'Tiossulfato de Sódio';
  static const String idBulario = 'tiossulfato_sodio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/tiossulfato_sodio.json');
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
      conteudo: _buildCardTiossulfatoSodio(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardTiossulfatoSodio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTiossulfatoSodio._textoObs('• Antídoto intoxicação cianeto - Agente quelante - Neuroprotetor'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTiossulfatoSodio._linhaPreparo('Ampola 10mL (2,5g) a 25%', 'Concentração 250mg/mL'),
        MedicamentoTiossulfatoSodio._linhaPreparo('Ampola 50mL (12,5g) a 25%', 'Concentração 250mg/mL'),
        MedicamentoTiossulfatoSodio._linhaPreparo('Início: imediato | Pico: minutos', 'Ação antídoto rápida'),
        MedicamentoTiossulfatoSodio._linhaPreparo('Meia-vida: 15-20 min (inicial)', 'Até 200 min (eliminação terminal)'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTiossulfatoSodio._linhaPreparo('Pronto para uso (solução 25%)', 'Pode usar direto da ampola'),
        MedicamentoTiossulfatoSodio._linhaPreparo('Pode diluir em SF 0,9% ou SG 5%', 'Para controle velocidade'),
        MedicamentoTiossulfatoSodio._linhaPreparo('Ex: 12,5g (50mL) em 100mL SF', 'Concentração 83mg/mL'),
        MedicamentoTiossulfatoSodio._linhaPreparo('Infusão lenta OBRIGATÓRIA: ≥10 min', 'Risco hipotensão'),
        MedicamentoTiossulfatoSodio._linhaPreparo('Incompatível: soluções ácidas, nitrito', 'Fazer flushing entre drogas'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoTiossulfatoSodio._linhaIndicacaoDoseFixa(
            titulo: 'Intoxicação por cianeto',
            descricaoDose: '12,5g IV em infusão lenta ≥10 min (sempre associar hidroxicobalamina)',
            doseFixa: '12,5 g',
          ),
          MedicamentoTiossulfatoSodio._linhaIndicacaoDoseFixa(
            titulo: 'Calcifilaxia (insuficiência renal terminal)',
            descricaoDose: '25g IV 3x/semana após hemodiálise (off-label)',
            doseFixa: '25 g',
          ),
        ] else ...[
          MedicamentoTiossulfatoSodio._linhaIndicacaoDoseCalculada(
            titulo: 'Intoxicação por cianeto pediátrica',
            descricaoDose: '400 mg/kg IV lento ≥10 min (máx 12,5g) + hidroxicobalamina',
            unidade: 'mg',
            dosePorKg: 400.0,
            doseMaxima: 12500.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTiossulfatoSodio._textoObs('• Doador de enxofre para rodanase - converte cianeto (CN⁻) em tiocianato (SCN⁻)'),
        MedicamentoTiossulfatoSodio._textoObs('• Tiocianato é 100x menos tóxico - excretado por rins'),
        MedicamentoTiossulfatoSodio._textoObs('• SEMPRE associar hidroxicobalamina (antídoto primário cianeto)'),
        MedicamentoTiossulfatoSodio._textoObs('• Quelante metais pesados (platina, ouro, arsênico, mercúrio, bismuto)'),
        MedicamentoTiossulfatoSodio._textoObs('• Uso oncológico: protege rim de toxicidade cisplatina'),
        MedicamentoTiossulfatoSodio._textoObs('• ATENÇÃO: Infusão lenta obrigatória ≥10 min (risco hipotensão severa)'),
        MedicamentoTiossulfatoSodio._textoObs('• ATENÇÃO: Sobrecarga volêmica em renais/cardiopatas (25g = 100mL líquido)'),
        MedicamentoTiossulfatoSodio._textoObs('• ATENÇÃO: Acúmulo tiocianato em IR - neurotóxico (considerar hemodiálise)'),
        MedicamentoTiossulfatoSodio._textoObs('• Contraindicado: hipervolemia não controlada, ICC descompensada'),
        MedicamentoTiossulfatoSodio._textoObs('• Monitorar: PA contínua (hipotensão transitória), sinais hipervolemia'),
        MedicamentoTiossulfatoSodio._textoObs('• Monitorar tiocianato se uso prolongado (neurotoxicidade >100 mcg/mL)'),
        MedicamentoTiossulfatoSodio._textoObs('• Efeitos: náusea, vômito, rubor, gosto metálico, dor local'),
        MedicamentoTiossulfatoSodio._textoObs('• Incompatível nitrito de sódio - administrar separado com flushing'),
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade (máx ${doseMaxima?.toStringAsFixed(0)} $unidade)';
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
