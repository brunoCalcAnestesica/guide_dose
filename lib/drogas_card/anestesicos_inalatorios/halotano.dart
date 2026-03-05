import 'package:flutter/material.dart';
import '../drogas.dart' show buildMedicamentoExpansivel;
import '../../shared_data.dart';

class MedicamentoHalotano {
  static const String nome = 'Halotano';
  static const String idBulario = 'halotano';

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isPediatrico = !isAdulto;

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardHalotano(
        context,
        peso,
        isAdulto,
        isPediatrico,
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
    final isPediatrico = !isAdulto;

    return _buildCardHalotano(
      context,
      peso,
      isAdulto,
      isPediatrico,
      isFavorito,
      () => onToggleFavorito(nome),
    );
  }

  static Widget _buildCardHalotano(
      BuildContext context,
      double peso,
      bool isAdulto,
      bool isPediatrico,
      bool isFavorito,
      VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CLASSE
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Anestésico inalatório', 'Hidrocarboneto halogenado'),
        _linhaPreparo('Em DESUSO', 'Substituído por agentes mais seguros'),

        // 2. APRESENTAÇÃO
        const SizedBox(height: 16),
        const Text('Apresentação',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Líquido volátil', 'Frasco 125-250 mL'),
        _linhaPreparo('Vaporizador específico', 'Calibrado para halotano'),

        // 3. PROPRIEDADES
        const SizedBox(height: 16),
        const Text('Propriedades Farmacológicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('CAM (adulto)', '0.75%'),
        _linhaPreparo('CAM (pediátrico)', '0.87-1.1%'),
        _linhaPreparo('Coeficiente sangue/gás', '2.5 (mais solúvel)'),
        _linhaPreparo('Coeficiente óleo/gás', '224'),

        // 4. INDICAÇÕES CLÍNICAS
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaIndicacaoDoseFixa(
          titulo: 'Indução inalatória - Adulto',
          descricaoDose: '2-4% em O2 ou O2/N2O',
        ),
        _linhaIndicacaoDoseFixa(
          titulo: 'Manutenção - Adulto',
          descricaoDose: '0.5-1.5% em O2/N2O ou O2/ar',
        ),
        _linhaIndicacaoDoseFixa(
          titulo: 'Indução pediátrica',
          descricaoDose: '2-4% (odor não irritante)',
        ),
        _linhaIndicacaoDoseFixa(
          titulo: 'Manutenção pediátrica',
          descricaoDose: '0.5-2% (ajustar por idade)',
        ),

        // 5. OBSERVAÇÕES
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('⚠️ HEPATOTOXICIDADE: hepatite fulminante (rara mas grave)'),
        _textoObs('⚠️ ARRITMOGÊNICO: sensibiliza miocárdio às catecolaminas'),
        _textoObs('⚠️ HIPERTERMIA MALIGNA: gatilho conhecido'),
        _textoObs('VANTAGEM histórica: odor agradável para indução'),
        _textoObs('NÃO USAR: se hepatite prévia por halotano'),
        _textoObs('SUBSTITUTOS: Sevoflurano, Desflurano, Isoflurano'),
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
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              descricaoDose,
              style: TextStyle(
                color: Colors.orange.shade700,
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
