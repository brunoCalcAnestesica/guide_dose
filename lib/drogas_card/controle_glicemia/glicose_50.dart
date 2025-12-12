import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoGlicose50 {
  static const String nome = 'Glicose 50%';
  static const String idBulario = 'glicose50';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/glicose50.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Glicose 50% tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardGlicose50(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardGlicose50(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGlicose50._textoObs(
            'Agente hiperglicemiante - Repositor calórico - Antídoto para hipoglicemia'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGlicose50._linhaPreparo('Ampola 10mL (5g de glicose)', ''),
        MedicamentoGlicose50._linhaPreparo('Ampola 20mL (10g de glicose)', ''),
        MedicamentoGlicose50._linhaPreparo('Frasco 50mL (25g de glicose)', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGlicose50._linhaPreparo(
            'Adultos', 'Solução pronta para uso'),
        MedicamentoGlicose50._linhaPreparo('Neonatos/Lactentes',
            'Diluir 1:1 com SF 0,9% (glicose 25%) ou 1:4 (glicose 10%)'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoGlicose50._linhaIndicacaoDoseFixa(
            titulo: 'Hipoglicemia severa',
            descricaoDose: '25-50mL (12,5-25g) IV em bolus lento (2-5 min)',
            doseFixa: '25-50 mL (12,5-25 g)',
          ),
          MedicamentoGlicose50._linhaIndicacaoDoseFixa(
            titulo: 'Intoxicação por insulina/sulfonilureias',
            descricaoDose: '50mL (25g) IV, repetir conforme glicemia',
            doseFixa: '50 mL (25 g)',
          ),
          MedicamentoGlicose50._linhaIndicacaoDoseFixa(
            titulo: 'Coma hipoglicêmico',
            descricaoDose: '50mL (25g) IV em bolus lento',
            doseFixa: '50 mL (25 g)',
          ),
        ] else ...[
          MedicamentoGlicose50._linhaIndicacaoDoseCalculadaGlicose(
            titulo: 'Hipoglicemia pediátrica',
            descricaoDose:
                '0,5-1 g/kg IV (equivalente a 1-2 mL/kg de glicose 50%)',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoGlicose50._textoObs('Início de ação: IMEDIATO'),
        MedicamentoGlicose50._textoObs('Pico de efeito: 1-3 minutos'),
        MedicamentoGlicose50._textoObs(
            'Meia-vida: minutos (rapidamente metabolizada)'),
        MedicamentoGlicose50._textoObs('Fornece glicose exógena diretamente'),
        MedicamentoGlicose50._textoObs('Eleva rapidamente glicemia plasmática'),
        MedicamentoGlicose50._textoObs('Corrige sintomas neuroglicopênicos'),
        MedicamentoGlicose50._textoObs('Administrar LENTAMENTE (2-5 minutos)'),
        MedicamentoGlicose50._textoObs(
            'Usar acesso venoso calibroso ou central'),
        MedicamentoGlicose50._textoObs('RISCO: tromboflebite'),
        MedicamentoGlicose50._textoObs(
            'RISCO: necrose tecidual por extravasamento'),
        MedicamentoGlicose50._textoObs(
            'RISCO: hipoglicemia rebote (especialmente sulfonilureias)'),
        MedicamentoGlicose50._textoObs(
            'Monitorar glicemia capilar antes, durante e após'),
        MedicamentoGlicose50._textoObs(
            'Monitorar local da punção (dor, edema, eritema)'),
        MedicamentoGlicose50._textoObs(
            'Neonatos/Lactentes: DILUIR para glicose 10-25%'),
        MedicamentoGlicose50._textoObs(
            'Após reversão: garantir aporte contínuo de glicose'),
        MedicamentoGlicose50._textoObs(
            'Evitar hipoglicemia rebote (alimentação ou glicose EV)'),
        MedicamentoGlicose50._textoObs(
            'Dose máxima adultos: 50mL (25g) por bolus'),
        MedicamentoGlicose50._textoObs(
            'Dose máxima pediatria: 2mL/kg (1g/kg) por bolus'),
        MedicamentoGlicose50._textoObs('Monitorar eletrólitos (K+, Na+)'),
        MedicamentoGlicose50._textoObs(
            'Risco de hipocalemia (especialmente com insulina)'),
        MedicamentoGlicose50._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoGlicose50._textoObs('Incompatível com soluções alcalinas'),
        MedicamentoGlicose50._textoObs(
            'Contraindicado em hiperglicemia severa'),
        MedicamentoGlicose50._textoObs('Contraindicado em coma hiperosmolar'),
        MedicamentoGlicose50._textoObs('Cautela em insuficiência hepática'),
        MedicamentoGlicose50._textoObs('Categoria C na gravidez'),
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

  static Widget _linhaIndicacaoDoseCalculadaGlicose({
    required String titulo,
    required String descricaoDose,
    required double dosePorKgMinima,
    required double dosePorKgMaxima,
    required double peso,
  }) {
    // Calcular gramas de glicose
    double gramasMin = dosePorKgMinima * peso;
    double gramasMax = dosePorKgMaxima * peso;

    // Calcular mL de glicose 50% (0,5g/mL)
    double mlMin = gramasMin / 0.5;
    double mlMax = gramasMax / 0.5;

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
                  'Dose: ${gramasMin.toStringAsFixed(1)}–${gramasMax.toStringAsFixed(1)} g (${mlMin.toStringAsFixed(0)}–${mlMax.toStringAsFixed(0)} mL)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '⚠️ Diluir para glicose 25% ou 10% em neonatos/lactentes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
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
