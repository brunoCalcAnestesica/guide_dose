import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAprepitanto {
  static const String nome = 'Aprepitanto';
  static const String idBulario = 'aprepitanto';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/aprepitanto.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Aprepitanto tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardAprepitanto(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    return _buildCardAprepitanto(
      context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
    );
  }


  static Widget _buildCardAprepitanto(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Antiemético - Antagonista do receptor NK1 (neurocinina-1)'),
        _textoObs('Bloqueia substância P no centro do vômito'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Cápsula 80mg', 'Emend®'),
        _linhaPreparo('Cápsula 125mg', 'Emend®'),
        _linhaPreparo('Kit 3 dias', '1 x 125mg + 2 x 80mg'),
        _linhaPreparo('Suspensão oral 125mg (pediátrico)', 'Emend®'),
        const SizedBox(height: 16),
        _infoMecanismo(),
        const SizedBox(height: 16),
        const Text('Indicações e Doses',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'Quimioterapia altamente emetogênica (3 dias)',
            descricaoDose: 'D1: 125mg VO 1h antes\nD2-D3: 80mg VO pela manhã',
            doseFixa: 'D1: 125mg → D2-D3: 80mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Quimioterapia moderadamente emetogênica',
            descricaoDose: '125mg VO 1h antes (dose única ou regime 3 dias)',
            doseFixa: '125mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'NVPO (prevenção pós-operatória)',
            descricaoDose: '40mg VO 3h antes da indução',
            doseFixa: '40mg',
          ),
        ] else ...[
          _linhaIndicacaoDoseCalculada(
            titulo: 'Pediátrico (6 meses - 12 anos)',
            descricaoDose: '3 mg/kg VO 1h antes da quimioterapia (máx 125mg)',
            unidade: 'mg',
            dosePorKg: 3,
            peso: peso,
            doseMaxima: 125,
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Pediátrico (>12 anos)',
            descricaoDose: 'Usar dose de adulto',
            doseFixa: 'D1: 125mg → D2-D3: 80mg',
          ),
        ],
        const SizedBox(height: 16),
        _regiemCombinado(),
        const SizedBox(height: 16),
        const Text('Farmacocinética',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Biodisponibilidade: 60-65%'),
        _textoObs('Pico plasmático: 4 horas'),
        _textoObs('Meia-vida: 9-13 horas'),
        _textoObs('Metabolismo: CYP3A4 (substrato e inibidor moderado)'),
        _textoObs('Excreção: Fecal (57%) e renal (45%)'),
        const SizedBox(height: 16),
        const Text('Interações Importantes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObsDestaque('Inibidor moderado de CYP3A4'),
        _textoObs('Aumenta níveis de dexametasona (reduzir dose em 50%)'),
        _textoObs('Aumenta níveis de metilprednisolona'),
        _textoObs('Reduz eficácia de contraceptivos orais'),
        _textoObs('Interação com warfarina (monitorar INR)'),
        _textoObs('Evitar com pimozida (risco de arritmia)'),
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Pode ser tomado com ou sem alimentos'),
        _textoObs('Eficaz para náusea tardia (D2-D5)'),
        _textoObs('Usar em combinação com 5-HT3 + corticoide'),
        _textoObs('Efeitos adversos: fadiga, soluços, constipação'),
        _textoObs('Categoria B na gravidez'),
        const SizedBox(height: 16),
        const Text('Contraindicações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Hipersensibilidade ao aprepitanto'),
        _textoObs('Uso concomitante com pimozida'),
        _textoObs('Uso concomitante com cisaprida'),
      ],
    );
  }

  static Widget _infoMecanismo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mecanismo de Ação:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 4),
          Text('• Bloqueia receptor NK1 no centro do vômito',
              style: TextStyle(fontSize: 12)),
          Text('• Impede ação da Substância P', style: TextStyle(fontSize: 12)),
          Text('• Eficaz na fase tardia da êmese (24-120h)',
              style: TextStyle(fontSize: 12)),
          Text('• Complementa antagonistas 5-HT3 (fase aguda)',
              style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static Widget _regiemCombinado() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Regime Antiemético Combinado (QT alta):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 8),
          Text('D1 (antes da quimioterapia):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text('• Aprepitanto 125mg VO', style: TextStyle(fontSize: 12)),
          Text('• Ondansetrona 8mg IV ou Granisetrona 1mg IV',
              style: TextStyle(fontSize: 12)),
          Text('• Dexametasona 12mg VO/IV (reduzida)',
              style: TextStyle(fontSize: 12)),
          SizedBox(height: 4),
          Text('D2-D3:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text('• Aprepitanto 80mg VO pela manhã',
              style: TextStyle(fontSize: 12)),
          Text('• Dexametasona 8mg VO 1x/dia', style: TextStyle(fontSize: 12)),
          SizedBox(height: 4),
          Text('D4:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text('• Dexametasona 8mg VO 1x/dia', style: TextStyle(fontSize: 12)),
        ],
      ),
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
                    const TextSpan(
                        text: ' | ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: marca,
                        style: const TextStyle(fontStyle: FontStyle.italic)),
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
          Text(titulo,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
                fontWeight: FontWeight.bold,
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
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
          if (textoDose != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
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

  static Widget _textoObsDestaque(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          Expanded(
            child: Text(texto,
                style: const TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
