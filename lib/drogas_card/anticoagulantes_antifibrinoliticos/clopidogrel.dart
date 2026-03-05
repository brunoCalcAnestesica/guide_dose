import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoClopidogrel {
  static const String nome = 'Clopidogrel';
  static const String idBulario = 'clopidogrel';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/clopidogrel.json');
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
      conteudo: _buildCardClopidogrel(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardClopidogrel(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardClopidogrel(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CLASSE
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Antiagregante plaquetário', 'Inibidor P2Y12 irreversível'),
        _linhaPreparo('Tienopiridina', 'Pró-droga'),

        // APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimido 75 mg', 'Manutenção'),
        _linhaPreparo('Comprimido 300 mg', 'Ataque'),

        // INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(
            titulo: 'SCA IAMSSST - Dose de ataque',
            descricaoDose: '300-600 mg VO',
            doseFixa: '300 mg (conservador) ou 600 mg (invasivo)',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'IAMCSST (fibrinólise) - Ataque',
            descricaoDose: '300 mg VO (<75 anos) ou 75 mg (≥75 anos)',
            doseFixa: '300 mg ou 75 mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'ICP primária - Ataque',
            descricaoDose: '600 mg VO',
            doseFixa: '600 mg',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Manutenção (DAPT)',
            descricaoDose: '75 mg VO 1x/dia por 12 meses (ou mais)',
            doseFixa: '75 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'AVC/AIT - Prevenção secundária',
            descricaoDose: '75 mg VO 1x/dia',
            doseFixa: '75 mg/dia',
          ),
          _linhaIndicacaoDoseFixa(
            titulo: 'Alergia ao AAS',
            descricaoDose: '75 mg VO 1x/dia (monoterapia)',
            doseFixa: '75 mg/dia',
          ),
        ] else ...[
          _textoObs('Uso pediátrico: dados limitados'),
          _textoObs('Doença de Kawasaki: considerar em casos refratários'),
        ],

        // OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('PRÓ-DROGA: requer ativação hepática (CYP2C19)'),
        _textoObs('Polimorfismo CYP2C19: ~30% são metabolizadores lentos'),
        _textoObs('INÍCIO DE AÇÃO: 2-6h (ataque), 3-7 dias (75 mg)'),
        _textoObs('Efeito IRREVERSÍVEL - suspender 5-7 dias antes cirurgia'),
        _textoObs('Omeprazol/Esomeprazol reduzem eficácia (CYP2C19)'),
        _textoObs('Preferir pantoprazol se necessário IBP'),
        _textoObs('DAPT = AAS + Clopidogrel'),
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
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(descricaoDose, style: const TextStyle(fontSize: 13)),
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13),
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
