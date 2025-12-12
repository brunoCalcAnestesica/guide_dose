import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoHidroxicobalamina {
  static const String nome = 'Hidroxicobalamina';
  static const String idBulario = 'hidroxicobalamina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle
        .loadString('assets/medicamentos/hidroxicobalamina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Hidroxicobalamina tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardHidroxicobalamina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardHidroxicobalamina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHidroxicobalamina._textoObs(
            'Antídoto para intoxicação por cianeto - Derivado da vitamina B12'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHidroxicobalamina._linhaPreparo(
            'Frasco-ampola 2,5g liofilizado', ''),
        MedicamentoHidroxicobalamina._linhaPreparo(
            'Kit Cyanokit (2 frascos 2,5g)', 'Com diluente estéril + equipo'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHidroxicobalamina._linhaPreparo(
            'Reconstituir 2,5g', 'Adicionar 100mL do diluente fornecido'),
        MedicamentoHidroxicobalamina._linhaPreparo(
            'Agitar vigorosamente', '60 segundos até dissolução completa'),
        MedicamentoHidroxicobalamina._linhaPreparo(
            'Concentração final', '25 mg/mL (solução vermelho rubi)'),
        MedicamentoHidroxicobalamina._linhaPreparo(
            'Tempo de infusão', '15 minutos para cada 5g'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoHidroxicobalamina._linhaIndicacaoDoseFixa(
            titulo: 'Intoxicação por cianeto (dose inicial)',
            descricaoDose: '5g IV em 15 minutos',
            doseFixa: '5 g (2 frascos)',
          ),
          MedicamentoHidroxicobalamina._linhaIndicacaoDoseFixa(
            titulo: 'Dose adicional se necessário',
            descricaoDose: '5g IV em 15-30 minutos (máx total: 10g)',
            doseFixa: '5 g (2 frascos)',
          ),
        ] else ...[
          MedicamentoHidroxicobalamina._linhaIndicacaoDoseCalculada(
            titulo: 'Intoxicação por cianeto pediátrica (dose inicial)',
            descricaoDose: '70mg/kg IV em 15 minutos (máx 5g)',
            unidade: 'mg',
            dosePorKg: 70,
            peso: peso,
            doseMaxima: 5000,
          ),
          MedicamentoHidroxicobalamina._linhaIndicacaoDoseCalculada(
            titulo: 'Dose adicional pediátrica se necessário',
            descricaoDose: '70mg/kg IV (máx total: 140mg/kg ou 10g)',
            unidade: 'mg',
            dosePorKg: 70,
            peso: peso,
            doseMaxima: 5000,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHidroxicobalamina._textoObs('Início de ação: IMEDIATO'),
        MedicamentoHidroxicobalamina._textoObs('Pico de efeito: minutos'),
        MedicamentoHidroxicobalamina._textoObs('Meia-vida: 26-31 horas'),
        MedicamentoHidroxicobalamina._textoObs('Agente quelante do cianeto'),
        MedicamentoHidroxicobalamina._textoObs(
            'Liga-se ao cianeto formando cianocobalamina (B12)'),
        MedicamentoHidroxicobalamina._textoObs(
            'Cianocobalamina é não tóxica e excretada pelos rins'),
        MedicamentoHidroxicobalamina._textoObs(
            'Restaura respiração celular mitocondrial'),
        MedicamentoHidroxicobalamina._textoObs(
            'Dose adultos: 5g inicial, até 10g total'),
        MedicamentoHidroxicobalamina._textoObs(
            'Dose pediátrica: 70mg/kg, até 140mg/kg total'),
        MedicamentoHidroxicobalamina._textoObs(
            'Infusão em 15 minutos obrigatória'),
        MedicamentoHidroxicobalamina._textoObs(
            'Pode prolongar para 30min se instabilidade hemodinâmica'),
        MedicamentoHidroxicobalamina._textoObs(
            'NUNCA administrar em bolus rápido'),
        MedicamentoHidroxicobalamina._textoObs(
            'Coloração vermelho rubi da solução (normal)'),
        MedicamentoHidroxicobalamina._textoObs(
            'ESPERADO: pele e urina avermelhadas (até 10 dias)'),
        MedicamentoHidroxicobalamina._textoObs(
            'ESPERADO: mucosas avermelhadas'),
        MedicamentoHidroxicobalamina._textoObs(
            'Orientar paciente sobre coloração transitória'),
        MedicamentoHidroxicobalamina._textoObs(
            'Interfere em exames laboratoriais colorimétricos'),
        MedicamentoHidroxicobalamina._textoObs(
            'Interfere em gasometria (cooximetria)'),
        MedicamentoHidroxicobalamina._textoObs(
            'Informar laboratório sobre uso de hidroxicobalamina'),
        MedicamentoHidroxicobalamina._textoObs(
            'Usar APENAS diluente fornecido ou água para injeção'),
        MedicamentoHidroxicobalamina._textoObs(
            'Incompatível com SF 0,9% e SG 5%'),
        MedicamentoHidroxicobalamina._textoObs(
            'Incompatível com soluções alcalinas'),
        MedicamentoHidroxicobalamina._textoObs(
            'Após reconstituição: usar em 6h (proteger da luz)'),
        MedicamentoHidroxicobalamina._textoObs(
            'Monitorar PA (risco de hipertensão transitória)'),
        MedicamentoHidroxicobalamina._textoObs('Monitorar função renal'),
        MedicamentoHidroxicobalamina._textoObs(
            'Efeitos adversos: náusea, cefaleia, rash'),
        MedicamentoHidroxicobalamina._textoObs('Risco raro: anafilaxia'),
        MedicamentoHidroxicobalamina._textoObs(
            'Ter suporte avançado de vida disponível'),
        MedicamentoHidroxicobalamina._textoObs(
            'Categoria C na gravidez (usar em emergências)'),
        MedicamentoHidroxicobalamina._textoObs(
            'Contraindicado apenas em hipersensibilidade'),
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
    double? doseCalculada;
    String? textoDose;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
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
      textoDose =
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
