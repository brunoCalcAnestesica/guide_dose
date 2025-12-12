import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoSoroFisiologico {
  static const String nome = 'Soro Fisiológico';
  static const String idBulario = 'sorofisiologico';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/sorofisiologico.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  // Função para verificar se tem indicações para a faixa etária selecionada
  static bool _temIndicacoesParaFaixaEtaria() {
    // Soro fisiológico tem indicações para todas as faixas etárias
    return true;
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    // Verificar se deve mostrar o card para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria()) {
      return const SizedBox.shrink();
    }

    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardSoroFisiologico(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardSoroFisiologico(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isNeonato = faixaEtaria == 'Neonato';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSoroFisiologico._textoObs('Solução eletrolítica isotônica (NaCl 0,9%) - Hidratação parenteral e diluente universal'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSoroFisiologico._linhaPreparo('Bolsa/frasco 100mL, 250mL, 500mL, 1000mL', '9 mg/mL = 0,9%'),
        MedicamentoSoroFisiologico._linhaPreparo('Ampola 5mL, 10mL, 20mL', 'Irrigação, diluição'),
        MedicamentoSoroFisiologico._linhaPreparo('Osmolaridade: 308 mOsm/L', 'Isotônico (≈ plasma 300)'),
        MedicamentoSoroFisiologico._linhaPreparo('Composição: 154 mEq Na⁺/L, 154 mEq Cl⁻/L', 'Concentração fisiológica'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSoroFisiologico._linhaPreparo('Pronto uso - NÃO diluir', 'Já isotônico'),
        MedicamentoSoroFisiologico._linhaPreparo('Conectar equipo ou bomba infusão', 'Programar mL/h'),
        MedicamentoSoroFisiologico._linhaPreparo('Aquecer grandes volumes (>500mL)', 'Ideal 37°C - evitar hipotermia'),
        MedicamentoSoroFisiologico._linhaPreparo('Diluente: adicionar medicamento direto', 'Compatível maioria fármacos'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoSoroFisiologico._linhaIndicacaoDoseCalculada(
            titulo: 'Hidratação de manutenção (adulto)',
            descricaoDose: '30-40 mL/kg/dia (típico 2.000-3.000 mL/dia)',
            unidade: 'mL/dia',
            dosePorKgMinima: 30.0,
            dosePorKgMaxima: 40.0,
            peso: peso,
          ),
          MedicamentoSoroFisiologico._linhaIndicacaoDoseCalculada(
            titulo: 'Reposição de perdas',
            descricaoDose: '20-30 mL/kg (1.500-2.000 mL)',
            unidade: 'mL',
            dosePorKgMinima: 20.0,
            dosePorKgMaxima: 30.0,
            peso: peso,
          ),
          MedicamentoSoroFisiologico._linhaIndicacaoDoseFixa(
            titulo: 'Expansão volêmica (hipotensão, choque)',
            descricaoDose: '500-1.000 mL IV rápido (15-30 min). Repetir se necessário',
            doseFixa: '500-1.000 mL',
          ),
          MedicamentoSoroFisiologico._linhaIndicacaoDoseFixa(
            titulo: 'KVO - Manter veia pérvea',
            descricaoDose: '20-50 mL/h (keep vein open - sem hidratação significativa)',
            doseFixa: '20-50 mL/h',
          ),
        ] else if (isNeonato) ...[
          MedicamentoSoroFisiologico._linhaIndicacaoDoseCalculada(
            titulo: 'Hidratação de manutenção (neonato)',
            descricaoDose: '60-80 mL/kg/dia',
            unidade: 'mL/dia',
            dosePorKgMinima: 60.0,
            dosePorKgMaxima: 80.0,
            peso: peso,
          ),
          MedicamentoSoroFisiologico._linhaIndicacaoDoseCalculada(
            titulo: 'Expansão volêmica neonatal',
            descricaoDose: '10 mL/kg IV lento (30 min)',
            unidade: 'mL',
            dosePorKg: 10.0,
            peso: peso,
          ),
        ] else ...[
          MedicamentoSoroFisiologico._linhaIndicacaoDoseCalculadaHolliday(
            titulo: 'Hidratação de manutenção (pediátrico - Holliday-Segar)',
            descricaoDose: '100 mL/kg (0-10kg) + 50 mL/kg (10-20kg) + 20 mL/kg (>20kg)',
            peso: peso,
          ),
          MedicamentoSoroFisiologico._linhaIndicacaoDoseCalculada(
            titulo: 'Expansão volêmica pediátrica',
            descricaoDose: '10-20 mL/kg IV rápido (máx 500 mL)',
            unidade: 'mL',
            dosePorKgMinima: 10.0,
            dosePorKgMaxima: 20.0,
            doseMaxima: 500,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSoroFisiologico._textoObs('Indicação: Hidratação de manutenção contínua'),
        if (isAdulto) ...[
          MedicamentoSoroFisiologico._linhaPreparo('Velocidade manutenção: 80-125 mL/h', 'Típico adulto (2-3 L/dia)'),
          MedicamentoSoroFisiologico._linhaPreparo('Velocidade rápida: 500-1.000 mL/h', 'Expansão volêmica (emergência)'),
        ] else if (isNeonato) ...[
          MedicamentoSoroFisiologico._linhaPreparo('Velocidade neonato: 2,5-3,5 mL/kg/h', 'Conforme 60-80 mL/kg/dia'),
        ] else ...[
          MedicamentoSoroFisiologico._linhaPreparo('Velocidade pediátrica: conforme Holliday-Segar ÷ 24h', 'Exemplo 20kg: 1.500 mL/dia ≈ 60 mL/h'),
        ],
        MedicamentoSoroFisiologico._linhaPreparo('Monitorar balanço hídrico (entrada/saída)', 'Diurese >0,5 mL/kg/h'),
        MedicamentoSoroFisiologico._linhaPreparo('Auscultar pulmões (sobrecarga volêmica)', 'Estertoração = edema'),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSoroFisiologico._textoObs('SF 0,9% = ISOTÔNICO (308 mOsm/L ≈ plasma 300) - não altera células, não causa hemólise'),
        MedicamentoSoroFisiologico._textoObs('Diluente universal - compatível maioria medicamentos IV (verificar bula específica)'),
        MedicamentoSoroFisiologico._textoObs('Expansão volêmica transitória (30-60 min) - depois redistribui interstício'),
        MedicamentoSoroFisiologico._textoObs('ATENÇÃO: Acidose hiperclorêmica - volumes grandes (>3-4 L) ↑Cl⁻ 154 mEq/L'),
        MedicamentoSoroFisiologico._textoObs('Preferir Ringer Lactato se reposição >2L (menos acidose)'),
        MedicamentoSoroFisiologico._textoObs('Fórmula Holliday-Segar: 100 mL/kg (0-10kg) + 50 mL/kg (10-20kg) + 20 mL/kg (>20kg)'),
        MedicamentoSoroFisiologico._textoObs('KVO (keep vein open): 20-50 mL/h - manter veia pérvea sem hidratar'),
        MedicamentoSoroFisiologico._textoObs('Aquecer volumes >500 mL (evitar hipotermia) - ideal 37°C'),
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
                'Volume calculado: $textoDose',
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

  // Cálculo específico Holliday-Segar para pediátrico
  static Widget _linhaIndicacaoDoseCalculadaHolliday({
    required String titulo,
    required String descricaoDose,
    required double peso,
  }) {
    double volumeDia;
    if (peso <= 10) {
      volumeDia = 100 * peso;
    } else if (peso <= 20) {
      volumeDia = (100 * 10) + (50 * (peso - 10));
    } else {
      volumeDia = (100 * 10) + (50 * 10) + (20 * (peso - 20));
    }

    final volumeHora = volumeDia / 24;

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
            child: Column(
              children: [
                Text(
                  'Volume diário: ${volumeDia.toStringAsFixed(0)} mL/dia',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Velocidade: ${volumeHora.toStringAsFixed(0)} mL/h',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '• $texto',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
