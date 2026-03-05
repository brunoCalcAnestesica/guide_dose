import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoSuccinilcolina {
  static const String nome = 'Succinilcolina';
  static const String idBulario = 'succinilcolina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/succinilcolina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  // Função para verificar se tem indicações para a faixa etária selecionada
  static bool _temIndicacoesParaFaixaEtaria() {
    // Succinilcolina tem indicações para todas as faixas etárias
    return true;
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final isFavorito = favoritos.contains(nome);
    // Verificar se deve mostrar o card para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria()) {
      return const SizedBox.shrink();
    }

    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardSuccinilcolina(
        context,
        peso,
        faixaEtaria,
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

    return _buildCardSuccinilcolina(
      context,
      peso,
      faixaEtaria,
      isFavorito,
      () => onToggleFavorito(nome),
    );
  }

  static Widget _buildCardSuccinilcolina(BuildContext context, double peso,
      String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isNeonato = faixaEtaria == 'Neonato' || faixaEtaria == 'Lactente';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSuccinilcolina._textoObs(
            'Bloqueador neuromuscular DESPOLARIZANTE - Ultra curta duração'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSuccinilcolina._linhaPreparo(
            'Ampola 100mg/5mL (20mg/mL)', 'Anectine®, Quelicin®'),
        MedicamentoSuccinilcolina._linhaPreparo(
            'Início: 30-60 seg (IV), 2-3 min (IM)', 'Ultra rápido'),
        MedicamentoSuccinilcolina._linhaPreparo(
            'Duração: 4-6 minutos', 'Ultra curta - meia-vida 47 seg'),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSuccinilcolina._linhaPreparo(
            'Pronto uso - NÃO diluir', 'Administrar diretamente'),
        MedicamentoSuccinilcolina._linhaPreparo(
            'Se necessário: diluir em SF 0,9%', 'Ajuste volume pediátrico'),
        MedicamentoSuccinilcolina._linhaPreparo('NUNCA infusão contínua',
            'Risco hipercalemia + bloqueio prolongado'),
        MedicamentoSuccinilcolina._linhaPreparo(
            'Armazenamento: 2-8°C refrigerado', 'Proteger da luz'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoSuccinilcolina._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação orotraqueal (sequência rápida)',
            descricaoDose: '1-1,5 mg/kg IV bolus rápido',
            unidade: 'mg',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 1.5,
            peso: peso,
          ),
          MedicamentoSuccinilcolina._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação IM (sem acesso IV)',
            descricaoDose: '3-4 mg/kg IM (emergência sem IV)',
            unidade: 'mg',
            dosePorKgMinima: 3.0,
            dosePorKgMaxima: 4.0,
            peso: peso,
          ),
          MedicamentoSuccinilcolina._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção (não recomendado rotina)',
            descricaoDose: '0,04-0,1 mg/kg IV se necessário',
            unidade: 'mg',
            dosePorKgMinima: 0.04,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
        ] else if (isNeonato) ...[
          MedicamentoSuccinilcolina._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação neonato/lactente (IV)',
            descricaoDose: '2 mg/kg IV bolus rápido',
            unidade: 'mg',
            dosePorKg: 2.0,
            peso: peso,
          ),
          MedicamentoSuccinilcolina._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação neonato/lactente (IM)',
            descricaoDose: '4-5 mg/kg IM (sem IV)',
            unidade: 'mg',
            dosePorKgMinima: 4.0,
            dosePorKgMaxima: 5.0,
            peso: peso,
          ),
        ] else ...[
          MedicamentoSuccinilcolina._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação pediátrica (criança/adolescente)',
            descricaoDose: '1-2 mg/kg IV bolus rápido',
            unidade: 'mg',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 2.0,
            peso: peso,
          ),
          MedicamentoSuccinilcolina._linhaIndicacaoDoseCalculada(
            titulo: 'Intubação pediátrica IM (sem IV)',
            descricaoDose: '4-5 mg/kg IM (emergência)',
            unidade: 'mg',
            dosePorKgMinima: 4.0,
            dosePorKgMaxima: 5.0,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSuccinilcolina._textoObs(
            'PADRÃO OURO para sequência rápida intubação (onset 30-60 seg)'),
        MedicamentoSuccinilcolina._textoObs(
            'Bloqueador DESPOLARIZANTE - fasciculações antes bloqueio total'),
        MedicamentoSuccinilcolina._textoObs(
            'Duração ultra curta (4-6 min) - metabolizado por butirilcolinesterase'),
        MedicamentoSuccinilcolina._textoObs(
            'Não há antídoto - reversão depende da metabolização'),
        MedicamentoSuccinilcolina._textoObs(
            'Suporte ventilatório obrigatório até recuperação (4-10 min típico)'),
        MedicamentoSuccinilcolina._textoObs(
            'Monitorar: SatO2, capnografia, TOF, ECG (bradicardia/arritmias)'),
        MedicamentoSuccinilcolina._textoObs(
            'Doses IM: 3-5x dose IV (absorção lenta - onset 2-3 min)'),
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
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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
