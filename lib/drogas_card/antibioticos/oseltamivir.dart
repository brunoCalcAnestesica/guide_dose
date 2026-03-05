import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoOseltamivir {
  static const String nome = 'Oseltamivir';
  static const String idBulario = 'oseltamivir';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/oseltamivir.json');
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
      conteudo: _buildCardContent(context, peso, isAdulto),
    );
  }
  /// Retorna apenas o conteúdo interno do medicamento (sem o card expansível)
  /// Usado para navegação direta de Doses Rápidas
  static Widget buildConteudo(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardContent(
      context, peso, isAdulto,
    );
  }


  static Widget _buildCardContent(BuildContext context, double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Antiviral - inibidor da neuraminidase'),
        _textoObs('Virostático - impede liberação de vírions'),

        const SizedBox(height: 16),
        const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Cápsula 30mg, 45mg, 75mg', 'Tamiflu®'),
        _linhaPreparo('Suspensão oral 6mg/mL', ''),

        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          _linhaIndicacaoDoseFixa(titulo: 'TRATAMENTO Influenza', descricaoDose: '75mg VO 12/12h por 5 dias', doseFixa: '75mg VO 12/12h'),
          _linhaIndicacaoDoseFixa(titulo: 'Casos graves / UTI', descricaoDose: '150mg VO 12/12h por 10 dias (ou mais)', doseFixa: '150mg VO 12/12h'),
          _linhaIndicacaoDoseFixa(titulo: 'PROFILAXIA pós-exposição', descricaoDose: '75mg VO 1x/dia por 10 dias', doseFixa: '75mg VO 1x/dia'),
        ] else ...[
          _linhaIndicacaoDoseFixa(titulo: 'Pediátrico ≤15 kg', descricaoDose: '30mg VO 12/12h por 5 dias', doseFixa: '30mg 12/12h'),
          _linhaIndicacaoDoseFixa(titulo: 'Pediátrico 15-23 kg', descricaoDose: '45mg VO 12/12h por 5 dias', doseFixa: '45mg 12/12h'),
          _linhaIndicacaoDoseFixa(titulo: 'Pediátrico 23-40 kg', descricaoDose: '60mg VO 12/12h por 5 dias', doseFixa: '60mg 12/12h'),
          _linhaIndicacaoDoseFixa(titulo: 'Pediátrico >40 kg', descricaoDose: '75mg VO 12/12h por 5 dias', doseFixa: '75mg 12/12h'),
        ],

        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Espectro: Influenza A e B'),
        _textoObs('INICIAR em <48h do início dos sintomas (maior benefício)'),
        _textoObs('Pode iniciar >48h em casos graves ou hospitalizados'),
        _textoObs('Ajuste renal: ClCr 30-60 → 30mg 12/12h; ClCr 10-30 → 30mg 1x/dia'),
        _textoObs('Náusea e vômito: tomar com alimentos'),
        _textoObs('Via enteral: pode abrir cápsula ou usar suspensão'),
        _textoObs('Monitorar eventos neuropsiquiátricos (raro)'),
        _textoObs('Gestação: pode usar se indicado (benefício > risco)'),
      ],
    );
  }

  static Widget _linhaPreparo(String texto, String marca) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: RichText(text: TextSpan(style: const TextStyle(color: Colors.black87), children: [TextSpan(text: texto), if (marca.isNotEmpty) ...[const TextSpan(text: ' | ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: marca, style: const TextStyle(fontStyle: FontStyle.italic))]]))),
    ]));
  }

  static Widget _linhaIndicacaoDoseFixa({required String titulo, required String descricaoDose, required String doseFixa}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text(descricaoDose, style: const TextStyle(fontSize: 13)), const SizedBox(height: 4),
      Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade200)),
        child: Text('Dose: $doseFixa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13), textAlign: TextAlign.center)),
    ]));
  }

  static Widget _textoObs(String texto) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(texto, style: const TextStyle(fontSize: 13)))]));
  }
}
