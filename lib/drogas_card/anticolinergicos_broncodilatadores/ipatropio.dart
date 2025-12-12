import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoIpatropio {
  static const String nome = 'Ipatrópio';
  static const String idBulario = 'ipratropio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/ipratropio.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Ipratrópio tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardIpatropio(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardIpatropio(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoIpatropio._textoObs(
            'Anticolinérgico - Broncodilatador - Antagonista muscarínico'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoIpatropio._linhaPreparo('Spray inalatório 20mcg/dose', ''),
        MedicamentoIpatropio._linhaPreparo(
            'Solução nebulização 0,25mg/mL (2mL = 0,5mg)', ''),
        MedicamentoIpatropio._linhaPreparo('Spray nasal 21mcg/dose', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoIpatropio._linhaPreparo(
            'Spray inalatório', 'Pronto para uso - agitar antes'),
        MedicamentoIpatropio._linhaPreparo(
            'Nebulização', 'Diluir solução em 2-3mL SF 0,9% se necessário'),
        MedicamentoIpatropio._linhaPreparo('Spray nasal', 'Pronto para uso'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoIpatropio._linhaIndicacaoDoseFixa(
            titulo: 'DPOC (bronquite crônica, enfisema)',
            descricaoDose:
                'Nebulização: 0,5mg (2mL) 3-4x/dia ou Spray: 2-4 inalações (40-80mcg) 3-4x/dia',
            doseFixa: '0,5 mg (2 mL) nebulização',
          ),
          MedicamentoIpatropio._linhaIndicacaoDoseFixa(
            titulo: 'Broncoespasmo agudo (exacerbação)',
            descricaoDose:
                '0,5mg nebulização a cada 20min na 1ª hora, depois 0,5mg a cada 4-6h',
            doseFixa: '0,5 mg (2 mL)',
          ),
          MedicamentoIpatropio._linhaIndicacaoDoseFixa(
            titulo: 'Asma brônquica (adjuvante)',
            descricaoDose: '0,5mg nebulização associado com beta-2 agonista',
            doseFixa: '0,5 mg (2 mL)',
          ),
        ] else ...[
          MedicamentoIpatropio._linhaIndicacaoDoseFixa(
            titulo: 'Broncoespasmo pediátrico <12 anos',
            descricaoDose:
                '0,25mg (1mL) nebulização 3-4x/dia ou a cada 20min na exacerbação',
            doseFixa: '0,25 mg (1 mL)',
          ),
          MedicamentoIpatropio._linhaIndicacaoDoseFixa(
            titulo: 'Broncoespasmo pediátrico >12 anos',
            descricaoDose: '0,5mg (2mL) nebulização 3-4x/dia',
            doseFixa: '0,5 mg (2 mL)',
          ),
          MedicamentoIpatropio._linhaIndicacaoDoseFixa(
            titulo: 'Lactentes (<1 ano)',
            descricaoDose: '0,125-0,25mg nebulização 3x/dia',
            doseFixa: '0,125-0,25 mg (0,5-1 mL)',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoIpatropio._textoObs('Início de ação: 15-30 minutos'),
        MedicamentoIpatropio._textoObs('Pico de efeito: 1-2 horas'),
        MedicamentoIpatropio._textoObs('Duração: 4-6 horas'),
        MedicamentoIpatropio._textoObs('Meia-vida: 1,6-2 horas'),
        MedicamentoIpatropio._textoObs(
            'Antagonista receptores muscarínicos (M1, M2, M3)'),
        MedicamentoIpatropio._textoObs('Bloqueia acetilcolina'),
        MedicamentoIpatropio._textoObs('Relaxa musculatura lisa brônquica'),
        MedicamentoIpatropio._textoObs('Reduz secreção de muco'),
        MedicamentoIpatropio._textoObs(
            'Inibe broncoconstrição mediada pelo sistema parassimpático'),
        MedicamentoIpatropio._textoObs(
            'Absorção sistêmica mínima (<10%) por via inalatória'),
        MedicamentoIpatropio._textoObs(
            'Efeitos anticolinérgicos sistêmicos mínimos'),
        MedicamentoIpatropio._textoObs(
            'Primeira linha em DPOC (mais eficaz que beta-2 agonistas)'),
        MedicamentoIpatropio._textoObs(
            'Na asma: usar como adjuvante aos beta-2 agonistas'),
        MedicamentoIpatropio._textoObs(
            'Efeito sinérgico com salbutamol/fenoterol'),
        MedicamentoIpatropio._textoObs(
            'Compatível com salbutamol e corticoides na mesma nebulização'),
        MedicamentoIpatropio._textoObs('Dose máxima: 2mg/dia (nebulização)'),
        MedicamentoIpatropio._textoObs(
            'Dose máxima spray: 320mcg/dia (16 inalações)'),
        MedicamentoIpatropio._textoObs(
            'Efeitos adversos: boca seca, gosto amargo'),
        MedicamentoIpatropio._textoObs('Pode causar tosse, irritação'),
        MedicamentoIpatropio._textoObs('Raramente: visão turva, midríase'),
        MedicamentoIpatropio._textoObs(
            'CUIDADO: evitar contato com os olhos (spray)'),
        MedicamentoIpatropio._textoObs(
            'Risco de glaucoma agudo se spray atingir olhos'),
        MedicamentoIpatropio._textoObs('Pode causar retenção urinária (raro)'),
        MedicamentoIpatropio._textoObs(
            'Contraindicado em glaucoma de ângulo fechado'),
        MedicamentoIpatropio._textoObs(
            'Contraindicado em hipertrofia prostática grave'),
        MedicamentoIpatropio._textoObs(
            'Compatível com SF 0,9% para nebulização'),
        MedicamentoIpatropio._textoObs(
            'NÃO usar água destilada (pode causar broncoespasmo)'),
        MedicamentoIpatropio._textoObs('Categoria B na gravidez (seguro)'),
        MedicamentoIpatropio._textoObs('Seguro na lactação'),
        MedicamentoIpatropio._textoObs(
            'Não requer ajuste em insuficiência renal ou hepática'),
        MedicamentoIpatropio._textoObs('Orientar técnica inalatória correta'),
        MedicamentoIpatropio._textoObs('Agitar bem antes de usar (spray)'),
        MedicamentoIpatropio._textoObs(
            'Usar espaçador em crianças <5 anos (spray)'),
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

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
