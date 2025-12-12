import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoTerbutalina {
  static const String nome = 'Terbutalina';
  static const String idBulario = 'terbutalina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/terbutalina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  // Função para verificar se tem indicações para a faixa etária selecionada
  static bool _temIndicacoesParaFaixaEtaria() {
    // Terbutalina tem indicações para todas as faixas etárias
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
      conteudo: _buildCardTerbutalina(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardTerbutalina(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text(
          'Agonista beta-2 adrenérgico seletivo (SABA) - Broncodilatador e tocolítico',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTerbutalina._linhaPreparo('Spray inalatório: 250 mcg/dose', 'Bricanyl®'),
        MedicamentoTerbutalina._linhaPreparo('Ampola SC/IV: 0,5 mg/mL (1mL)', 'Uso hospitalar'),
        MedicamentoTerbutalina._linhaPreparo('Comprimidos: 2,5mg, 5mg', 'Oral'),
        MedicamentoTerbutalina._linhaPreparo('Solução oral: 0,3 mg/mL', 'Frasco 100mL'),
        MedicamentoTerbutalina._linhaPreparo('Início: 1-5 min (SC/IV), 5 min (inalação)', 'Rápido'),
        MedicamentoTerbutalina._linhaPreparo('Duração: 4-6h (inalação/SC), 8h (oral)', 'Meia-vida 3-6h'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTerbutalina._linhaPreparo('Nebulização: 0,25-0,5mg em 2-3mL SF 0,9%', ''),
        MedicamentoTerbutalina._linhaPreparo('SC: administrar direto (0,5 mg/mL)', 'Ampola pronta'),
        MedicamentoTerbutalina._linhaPreparo('IV (tocolítico): diluir em SF 0,9%', 'Bomba infusão'),
        MedicamentoTerbutalina._linhaPreparo('Inalação: spray dose fixa 250 mcg', 'Orientar técnica'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoTerbutalina._linhaIndicacaoDoseFixa(
            titulo: 'Broncoespasmo (inalação)',
            descricaoDose: '250 mcg (1 jato) a cada 4-6h (máx 1,5mg/dia)',
            doseFixa: '250 mcg/dose',
          ),
          MedicamentoTerbutalina._linhaIndicacaoDoseFixa(
            titulo: 'Broncoespasmo agudo (SC)',
            descricaoDose: '0,25mg SC a cada 4h (máx 0,5mg/dose)',
            doseFixa: '0,25mg',
          ),
          MedicamentoTerbutalina._linhaIndicacaoDoseFixa(
            titulo: 'Oral (asma persistente)',
            descricaoDose: '2,5-5mg VO 3x/dia',
            doseFixa: '2,5-5mg',
          ),
        ] else ...[
          MedicamentoTerbutalina._linhaIndicacaoDoseCalculada(
            titulo: 'Broncoespasmo pediátrico (SC)',
            descricaoDose: '0,005-0,01 mg/kg SC a cada 4-6h',
            unidade: 'mg',
            dosePorKgMinima: 0.005,
            dosePorKgMaxima: 0.01,
            peso: peso,
          ),
          MedicamentoTerbutalina._linhaIndicacaoDoseCalculada(
            titulo: 'Oral pediátrico (<12 anos)',
            descricaoDose: '0,075 mg/kg VO a cada 8h (máx 2,5mg)',
            unidade: 'mg',
            dosePorKg: 0.075,
            doseMaxima: 2.5,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoTerbutalina._textoObs('Agonista beta-2 seletivo - estimula receptores brônquicos e uterinos'),
        MedicamentoTerbutalina._textoObs('Aumenta AMPc intracelular - relaxamento musculatura lisa'),
        MedicamentoTerbutalina._textoObs('Broncodilatador de curta ação (SABA) - alívio sintomático'),
        MedicamentoTerbutalina._textoObs('Tocolítico - inibe contrações uterinas (3º trimestre)'),
        MedicamentoTerbutalina._textoObs('Efeitos beta-2: broncodilatação, tremores, taquicardia'),
        MedicamentoTerbutalina._textoObs('ATENÇÃO: Doses altas perdem seletividade (ativa beta-1 cardíaco)'),
        MedicamentoTerbutalina._textoObs('ATENÇÃO: Hipocalemia, hiperglicemia em doses altas'),
        MedicamentoTerbutalina._textoObs('ATENÇÃO: Edema pulmonar em tocolítico (monitorar saturação)'),
        MedicamentoTerbutalina._textoObs('Contraindicado: hipertireoidismo, arritmias graves, cardiomiopatia'),
        MedicamentoTerbutalina._textoObs('Interação: betabloqueadores antagonizam efeito'),
        MedicamentoTerbutalina._textoObs('Associar corticoide inalado em asma persistente'),
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
      child: Text(
        texto.startsWith('•') ? texto : '• $texto',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
