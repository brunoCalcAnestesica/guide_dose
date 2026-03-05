import 'package:flutter/material.dart';
import '../drogas.dart' show buildMedicamentoExpansivel;
import '../../shared_data.dart';

class MedicamentoEtoricoxibe {
  static const String nome = 'Etoricoxibe';
  static const String idBulario = 'etoricoxibe';

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';

    // Etoricoxibe: uso apenas em adultos (>16 anos)
    if (!isAdulto) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardEtoricoxibe(
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
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';

    return _buildCardEtoricoxibe(
      context,
      peso,
      isAdulto,
      isFavorito,
      () => onToggleFavorito(nome),
    );
  }

  static Widget _buildCardEtoricoxibe(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('AINE', 'Anti-inflamatório não esteroidal'),
        _linhaPreparo('Inibidor seletivo COX-2', 'Alta seletividade COX-2'),

        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Comprimidos 60 mg', 'Arcoxia®'),
        _linhaPreparo('Comprimidos 90 mg', 'Arcoxia®'),
        _linhaPreparo('Comprimidos 120 mg', 'Arcoxia®'),

        // 3. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaIndicacaoDoseFixa(
          titulo: 'Osteoartrite - Adulto',
          descricaoDose: '60 mg VO 1x/dia',
        ),
        _linhaIndicacaoDoseFixa(
          titulo: 'Artrite Reumatoide - Adulto',
          descricaoDose: '90 mg VO 1x/dia',
        ),
        _linhaIndicacaoDoseFixa(
          titulo: 'Espondilite Anquilosante - Adulto',
          descricaoDose: '90 mg VO 1x/dia',
        ),
        _linhaIndicacaoDoseFixa(
          titulo: 'Gota aguda - Adulto',
          descricaoDose: '120 mg VO 1x/dia (máx 8 dias)',
        ),
        _linhaIndicacaoDoseFixa(
          titulo: 'Dor aguda pós-operatória - Adulto',
          descricaoDose: '90-120 mg VO 1x/dia (máx 8 dias)',
        ),
        _linhaIndicacaoDoseFixa(
          titulo: 'Dismenorreia primária - Adulto',
          descricaoDose: '120 mg VO 1x/dia (máx 5 dias)',
        ),

        // 4. OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Início: 1h | Pico: 1-2h | Meia-vida: 22h'),
        _textoObs('COX-2 ALTAMENTE SELETIVO: menor risco GI'),
        _textoObs('RISCO CV: aumentado - menor dose pelo menor tempo'),
        _textoObs('CI: HAS não controlada, IC classe III-IV'),
        _textoObs('CI: DAC, AVC/AIT prévio, cirurgia cardíaca'),
        _textoObs('NÃO usar em gestação, lactação, <16 anos'),
      ],
    );
  }

  static Widget _linhaIndicacaoDoseFixa({
    required String titulo,
    required String descricaoDose,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              descricaoDose,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
